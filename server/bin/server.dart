import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:limit_breaker_local_api/database/local_database_initializer.dart';
import 'package:limit_breaker_local_api/http/cors.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

/// Inicializa o banco, registra as rotas e inicia a API local na porta 8080.
Future<void> main() async {
  final url = Platform.environment['DATABASE_URL'];
  if (url == null || url.isEmpty) throw StateError('Defina DATABASE_URL.');
  await LocalDatabaseInitializer.ensureCreated(url);
  final db = await Connection.openFromUrl(
    url.contains('?') ? '$url&sslmode=disable' : '$url?sslmode=disable',
  );
  final api = _Api(db);
  final router = Router()
    ..get('/health', api.health)
    ..post('/auth/register', api.register)
    ..post('/auth/login', api.login)
    ..get('/me', api.me)
    ..post('/onboarding', api.saveOnboarding)
    ..get('/workout-suggestions', api.listWorkoutSuggestions)
    ..post('/workout-suggestions', api.createWorkoutSuggestion)
    ..get('/workouts', api.listWorkouts)
    ..post('/workouts', api.createWorkout)
    ..get('/admin/exercises', api.adminExercises)
    ..get('/admin/categories', api.adminCategories)
    ..post('/admin/exercises', api.createExercise)
    ..patch('/admin/exercises/<id>', api.renameExercise)
    ..delete('/admin/exercises/<id>', api.deleteExercise)
    ..get('/admin/users', api.adminUsers)
    ..patch('/admin/users/<id>', api.updateUser)
    ..post('/admin/events', api.createEvent)
    ..patch('/admin/events/<id>/start', api.startEvent)
    ..patch('/admin/events/<id>/finish', api.finishEvent);
  final handler = const Pipeline()
      .addMiddleware(corsMiddleware)
      .addMiddleware(logRequests())
      .addHandler(router.call);
  final server = await shelf_io.serve(
    handler,
    InternetAddress.loopbackIPv4,
    8080,
  );
  stdout.writeln('API local em http://${server.address.host}:${server.port}');
}

/// Implementa os endpoints da API e concentra o acesso autenticado ao banco.
class _Api {
  /// Recebe a conexão PostgreSQL usada por todos os endpoints da API.
  _Api(this.db);
  final Connection db;

  /// Confirma que a API consegue consultar o banco de dados.
  Future<Response> health(Request _) async {
    await db.execute('select 1');
    return _ok({'database': 'connected'});
  }

  /// Valida o cadastro, cria o perfil e armazena a senha com hash BCrypt.
  Future<Response> register(Request request) async {
    final body = await _body(request);
    if (body == null) return _bad('Dados inválidos.');
    final username = _text(body['username'], 3, 30);
    final email = _text(body['email'], 5, 320)?.toLowerCase();
    final displayName = _text(body['displayName'], 2, 50);
    final password = _text(body['password'], 8, 128);
    final age = _int(body['age'], 13, 120);
    final height = _number(body['heightCm'], 80, 250);
    final weight = _number(body['weightKg'], 20, 400);
    if (username == null ||
        email == null ||
        !email.contains('@') ||
        displayName == null ||
        password == null ||
        age == null ||
        height == null ||
        weight == null)
      return _bad('Confira os campos do cadastro.');
    try {
      final profile = await db.runTx((tx) async {
        final inserted = await tx.execute(
          Sql.named(
            'insert into app_profiles (email, display_name, age, height_cm, weight_kg) values (@email, @name, @age, @height, @weight) returning id::text as id, email, display_name',
          ),
          parameters: {
            'email': email,
            'name': displayName,
            'age': age,
            'height': height,
            'weight': weight,
          },
        );
        final account = await tx.execute(
          Sql.named(
            'insert into users (profile_id, username, display_name, password_hash) values (@id, @username, @name, @hash) returning id::text as user_id, user_type::text as user_type',
          ),
          parameters: {
            'id': inserted.first[0],
            'username': username.toLowerCase(),
            'name': displayName,
            'hash': BCrypt.hashpw(password, BCrypt.gensalt()),
          },
        );
        return {
          ...inserted.first.toColumnMap(),
          ...account.first.toColumnMap(),
        };
      });
      return _ok({
        ...profile,
        'user_type': profile['user_type'],
        'token': await _session(
          userId: profile['user_id'].toString(),
          profileId: profile['id'].toString(),
        ),
      }, status: 201);
    } on ServerException catch (_) {
      return _conflict('E-mail ou nome de usuário já cadastrado.');
    }
  }

  /// Valida as credenciais e cria uma sessão para a conta autenticada.
  Future<Response> login(Request request) async {
    final body = await _body(request);
    final identifier = _text(body?['identifier'], 3, 320)?.toLowerCase();
    final password = _text(body?['password'], 8, 128);
    if (identifier == null || password == null)
      return _bad('Informe acesso e senha.');
    final result = await db.execute(
      Sql.named(
        'select u.id as user_id, u.user_type::text as user_type, u.is_active, u.profile_id, u.password_hash, p.id as profile_id_result, p.email, p.display_name from users u left join app_profiles p on p.id = u.profile_id where u.username = @value or p.email = @value limit 1',
      ),
      parameters: {'value': identifier},
    );
    if (result.isEmpty ||
        !BCrypt.checkpw(
          password,
          result.first.toColumnMap()['password_hash'] as String,
        ))
      return _unauthorized();
    final profile = result.first.toColumnMap();
    if (profile['is_active'] != true) return _unauthorized();
    return _ok({
      'id': profile['user_id'].toString(),
      'email': profile['email']?.toString(),
      'display_name': profile['display_name']?.toString(),
      'user_type': profile['user_type'].toString(),
      'token': await _session(
        userId: profile['user_id'].toString(),
        profileId: profile['profile_id']?.toString(),
      ),
    });
  }

  /// Retorna os dados básicos do perfil vinculado à sessão atual.
  Future<Response> me(Request request) async {
    final id = await _profileId(request);
    if (id == null) return _unauthorized();
    final result = await db.execute(
      Sql.named(
        'select id, email, display_name, age, height_cm, weight_kg from app_profiles where id = @id',
      ),
      parameters: {'id': id},
    );
    return result.isEmpty ? _unauthorized() : _ok(result.first.toColumnMap());
  }

  /// Persiste as preferências e respostas do onboarding do perfil autenticado.
  Future<Response> saveOnboarding(Request request) async {
    final profileId = await _profileId(request);
    final body = await _body(request);
    if (profileId == null) return _unauthorized();
    if (body == null) return _bad('Dados do onboarding inválidos.');

    final goal = _text(body['goal'], 3, 40);
    final sports = body['sports'];
    final activityBaseline = _text(body['activityBaseline'], 3, 20);
    final familyStatus = _text(body['familyStatus'], 3, 20);
    final limitationStatus = _text(body['limitationStatus'], 3, 20);
    final requiresGentleTraining = body['requiresGentleTraining'];
    final consentVersion = _text(body['consentVersion'], 1, 50);
    const goals = {
      'gain_muscle',
      'lose_fat',
      'conditioning',
      'sports_performance',
      'health',
      'maintain_fitness',
    };
    const sportValues = {
      'strength',
      'running',
      'cycling',
      'swimming',
      'football',
      'martial_arts',
    };
    const disclosureValues = {'no_problem', 'reported'};
    if (!goals.contains(goal) ||
        sports is! List ||
        sports.length != 3 ||
        sports.any(
          (sport) => sport is! String || !sportValues.contains(sport),
        ) ||
        sports.toSet().length != 3 ||
        !const {'active', 'sedentary'}.contains(activityBaseline) ||
        !disclosureValues.contains(familyStatus) ||
        !disclosureValues.contains(limitationStatus) ||
        requiresGentleTraining is! bool ||
        consentVersion == null) {
      return _bad('Confira as respostas do onboarding.');
    }

    final hasConcern =
        familyStatus == 'reported' || limitationStatus == 'reported';
    final trainingProfile = requiresGentleTraining
        ? 4
        : hasConcern
        ? 3
        : activityBaseline == 'sedentary'
        ? 2
        : 1;
    await db.runTx((tx) async {
      await tx.execute(
        Sql.named(
          'update app_profiles set goal = @goal, primary_sport = @primary, secondary_sport = @secondary, tertiary_sport = @tertiary, onboarding_completed_at = now(), updated_at = now() where id = @profile',
        ),
        parameters: {
          'profile': profileId,
          'goal': goal,
          'primary': sports[0],
          'secondary': sports[1],
          'tertiary': sports[2],
        },
      );
      final assessment = await tx.execute(
        Sql.named(
          'insert into health_assessments (profile_id, activity_baseline, requires_gentle_training, training_profile, consent_version) values (@profile, @baseline, @gentle, @trainingProfile, @consent) on conflict (profile_id) do update set activity_baseline = excluded.activity_baseline, requires_gentle_training = excluded.requires_gentle_training, training_profile = excluded.training_profile, consent_version = excluded.consent_version, updated_at = now() returning id',
        ),
        parameters: {
          'profile': profileId,
          'baseline': activityBaseline,
          'gentle': requiresGentleTraining,
          'trainingProfile': trainingProfile,
          'consent': consentVersion,
        },
      );
      final assessmentId = assessment.first[0];
      await tx.execute(
        Sql.named('delete from health_disclosures where assessment_id = @id'),
        parameters: {'id': assessmentId},
      );
      for (final disclosure in [
        (kind: 'family', question: 'family_history', status: familyStatus),
        (
          kind: 'personal',
          question: 'physical_limitation',
          status: limitationStatus,
        ),
      ]) {
        await tx.execute(
          Sql.named(
            'insert into health_disclosures (assessment_id, disclosure_kind, question_id, status, description) values (@assessment, @kind, @question, @status, @description)',
          ),
          parameters: {
            'assessment': assessmentId,
            'kind': disclosure.kind,
            'question': disclosure.question,
            'status': disclosure.status,
            'description': disclosure.status == 'reported'
                ? 'Detalhes serão informados posteriormente.'
                : null,
          },
        );
      }
    });
    return _ok({'training_profile': trainingProfile});
  }

  /// Lista as sugestões já geradas para o perfil autenticado.
  Future<Response> listWorkoutSuggestions(Request request) async {
    final profileId = await _profileId(request);
    if (profileId == null) return _unauthorized();
    final rows = await db.execute(
      Sql.named(
        'select id::text as id, training_style, muscle_group, training_profile, suggestion, created_at::text as created_at from workout_suggestions where profile_id = @profile order by created_at desc',
      ),
      parameters: {'profile': profileId},
    );
    return _ok({'items': rows.map((row) => row.toColumnMap()).toList()});
  }

  /// Gera uma rotina pré-definida adequada ao perfil e a persiste no banco.
  Future<Response> createWorkoutSuggestion(Request request) async {
    final profileId = await _profileId(request);
    final body = await _body(request);
    if (profileId == null) return _unauthorized();
    final category = _text(body?['category'], 3, 20);
    if (!const {
      'strength',
      'running',
      'cycling',
      'swimming',
    }.contains(category)) {
      return _bad('Modalidade inválida para sugestão.');
    }
    final assessment = await db.execute(
      Sql.named(
        'select training_profile from health_assessments where profile_id = @profile',
      ),
      parameters: {'profile': profileId},
    );
    if (assessment.isEmpty) {
      return _bad('Conclua o onboarding antes de solicitar uma sugestão.');
    }
    final trainingProfile = assessment.first[0] as int;
    final suggestion = _predefinedSuggestion(category!, trainingProfile);
    final inserted = await db.execute(
      Sql.named(
        'insert into workout_suggestions (profile_id, training_style, muscle_group, training_profile, suggestion) values (@profile, @style, @muscle, @trainingProfile, cast(@suggestion as jsonb)) returning id::text as id, created_at::text as created_at',
      ),
      parameters: {
        'profile': profileId,
        'style': category,
        'muscle': category == 'strength' ? 'upper_body' : 'general',
        'trainingProfile': trainingProfile,
        'suggestion': jsonEncode(suggestion),
      },
    );
    return _ok({
      ...inserted.first.toColumnMap(),
      'training_style': category,
      'training_profile': trainingProfile,
      'suggestion': suggestion,
    }, status: 201);
  }

  /// Lista os treinos registrados pelo perfil autenticado.
  Future<Response> listWorkouts(Request request) async {
    final id = await _profileId(request);
    if (id == null) return _unauthorized();
    final rows = await db.execute(
      Sql.named(
        'select id, category, performed_at, duration_seconds, distance_meters from workout_sessions where profile_id = @id order by performed_at desc',
      ),
      parameters: {'id': id},
    );
    return _ok({'items': rows.map((row) => row.toColumnMap()).toList()});
  }

  /// Valida e grava uma sessão de treino, incluindo exercícios e séries.
  Future<Response> createWorkout(Request request) async {
    final profileId = await _profileId(request);
    final body = await _body(request);
    if (profileId == null) return _unauthorized();
    final category = _text(body?['category'], 3, 20);
    final duration = _int(body?['durationSeconds'], 0, 86400) ?? 0;
    final distance = body?['distanceMeters'] == null
        ? null
        : _number(body?['distanceMeters'], 0.01, 1000000);
    final exercises = body?['exercises'];
    if (!const {
          'strength',
          'running',
          'cycling',
          'swimming',
        }.contains(category) ||
        (category == 'strength' && exercises is! List) ||
        (category != 'strength' && distance == null))
      return _bad('Dados do treino inválidos.');
    final session = await db.runTx((tx) async {
      final inserted = await tx.execute(
        Sql.named(
          'insert into workout_sessions (profile_id, category, performed_at, duration_seconds, distance_meters) values (@profile, @category, now(), @duration, @distance) returning id',
        ),
        parameters: {
          'profile': profileId,
          'category': category,
          'duration': duration,
          'distance': distance,
        },
      );
      final id = inserted.first[0].toString();
      if (category == 'strength')
        for (final raw in exercises as List) {
          if (raw is! Map) throw const FormatException();
          final name = _text(raw['name'], 2, 100);
          final group = _text(raw['muscleGroup'], 2, 50);
          final sets = _int(raw['sets'], 1, 100);
          final reps = _int(raw['repetitions'], 1, 1000);
          final load = _number(raw['loadKg'], 0, 2000);
          if (name == null ||
              group == null ||
              sets == null ||
              reps == null ||
              load == null)
            throw const FormatException();
          final exercise = await tx.execute(
            Sql.named(
              'insert into workout_exercises (workout_session_id, exercise_name, muscle_group) values (@session, @name, @group) returning id',
            ),
            parameters: {'session': id, 'name': name, 'group': group},
          );
          for (var i = 1; i <= sets; i++)
            await tx.execute(
              Sql.named(
                'insert into workout_sets (workout_exercise_id, set_number, repetitions, load_kg) values (@exercise, @number, @reps, @load)',
              ),
              parameters: {
                'exercise': exercise.first[0],
                'number': i,
                'reps': reps,
                'load': load,
              },
            );
        }
      return id;
    });
    return _ok({'id': session}, status: 201);
  }

  /// Lista exercícios e suas categorias para usuários administradores.
  Future<Response> adminExercises(Request request) async {
    if (await _adminContext(request) == null) return _unauthorized();
    final rows = await db.execute(
      'select e.id::text as id, e.name, c.id::text as category_id, c.name as category_name from exercises e join exercise_categories c on c.id = e.exercise_category_id order by c.name, e.name',
    );
    return _ok({'items': rows.map((row) => row.toColumnMap()).toList()});
  }

  /// Lista as categorias de exercícios disponíveis para administração.
  Future<Response> adminCategories(Request request) async {
    if (await _adminContext(request) == null) return _unauthorized();
    final rows = await db.execute(
      'select id::text as id, name from exercise_categories order by name',
    );
    return _ok({'items': rows.map((row) => row.toColumnMap()).toList()});
  }

  /// Cria um exercício na categoria escolhida por um administrador.
  Future<Response> createExercise(Request request) async {
    if (await _adminContext(request) == null) return _unauthorized();
    final body = await _body(request);
    final name = _text(body?['name'], 2, 100);
    final categoryId = _text(body?['categoryId'], 36, 36);
    if (name == null || categoryId == null)
      return _bad('Informe nome e categoria.');
    try {
      final row = await db.execute(
        Sql.named(
          'insert into exercises (name, exercise_category_id) values (@name, @category) returning id::text as id, name, exercise_category_id::text as exercise_category_id',
        ),
        parameters: {'name': name, 'category': categoryId},
      );
      return _ok(row.first.toColumnMap(), status: 201);
    } on ServerException catch (_) {
      return _conflict('Exercício duplicado ou categoria inválida.');
    }
  }

  /// Atualiza o nome de um exercício existente.
  Future<Response> renameExercise(Request request, String id) async {
    if (await _adminContext(request) == null) return _unauthorized();
    final name = _text((await _body(request))?['name'], 2, 100);
    if (name == null) return _bad('Informe um nome válido.');
    final result = await db.execute(
      Sql.named(
        'update exercises set name = @name where id = @id returning id::text as id, name',
      ),
      parameters: {'id': id, 'name': name},
    );
    return result.isEmpty
        ? Response.notFound('Não encontrado.')
        : _ok(result.first.toColumnMap());
  }

  /// Remove um exercício quando solicitado por um administrador.
  Future<Response> deleteExercise(Request request, String id) async {
    if (await _adminContext(request) == null) return _unauthorized();
    final result = await db.execute(
      Sql.named('delete from exercises where id = @id returning id'),
      parameters: {'id': id},
    );
    return result.isEmpty
        ? Response.notFound('Não encontrado.')
        : Response(204, headers: apiHeaders);
  }

  /// Lista contas e permissões visíveis para a área administrativa.
  Future<Response> adminUsers(Request request) async {
    if (await _adminContext(request) == null) return _unauthorized();
    final rows = await db.execute(
      'select id::text as id, username, display_name, user_type::text as user_type, is_active, created_at::text as created_at from users order by created_at desc',
    );
    return _ok({'items': rows.map((row) => row.toColumnMap()).toList()});
  }

  /// Atualiza situação, permissão ou senha de uma conta administrativa.
  Future<Response> updateUser(Request request, String id) async {
    final admin = await _adminContext(request);
    if (admin == null) return _unauthorized();
    final body = await _body(request);
    final active = body?['isActive'];
    final type = body?['userType'];
    final password = body?['password'];
    if (active is! bool && type is! String && password is! String)
      return _bad('Nenhuma alteração válida foi informada.');
    if (id == admin.userId && active == false)
      return _bad('Uma conta não pode desativar a si mesma.');
    if (type is String && !const {'standard', 'administrator'}.contains(type))
      return _bad('Tipo de conta inválido.');
    if (password is String && _text(password, 8, 128) == null)
      return _bad('A nova senha deve ter ao menos 8 caracteres.');
    final result = await db.execute(
      Sql.named(
        'update users set is_active = coalesce(@active, is_active), user_type = coalesce(cast(@type as user_type), user_type), password_hash = coalesce(@hash, password_hash) where id = @id returning id::text as id, username, display_name, user_type::text as user_type, is_active',
      ),
      parameters: {
        'id': id,
        'active': active,
        'type': type,
        'hash': password is String
            ? BCrypt.hashpw(password, BCrypt.gensalt())
            : null,
      },
    );
    return result.isEmpty
        ? Response.notFound('Não encontrado.')
        : _ok(result.first.toColumnMap());
  }

  /// Cria um evento com status inicial de agendado.
  Future<Response> createEvent(Request request) async {
    final admin = await _adminContext(request);
    if (admin == null) return _unauthorized();
    final title = _text((await _body(request))?['title'], 3, 100);
    if (title == null) return _bad('Informe o título do evento.');
    final result = await db.execute(
      Sql.named(
        "insert into app_events (title, status, created_by) values (@title, 'scheduled', @admin) returning id::text as id, title, status",
      ),
      parameters: {'title': title, 'admin': admin.userId},
    );
    return _ok(result.first.toColumnMap(), status: 201);
  }

  /// Marca um evento agendado como ativo.
  Future<Response> startEvent(Request request, String id) async =>
      _changeEventStatus(request, id, 'active');

  /// Marca um evento ativo como finalizado.
  Future<Response> finishEvent(Request request, String id) async =>
      _changeEventStatus(request, id, 'finished');

  /// Altera o status e registra o horário de início ou encerramento do evento.
  Future<Response> _changeEventStatus(
    Request request,
    String id,
    String status,
  ) async {
    if (await _adminContext(request) == null) return _unauthorized();
    final timestamp = status == 'active'
        ? 'started_at = now()'
        : 'finished_at = now()';
    final result = await db.execute(
      Sql.named(
        'update app_events set status = @status, $timestamp where id = @id and status <> \'finished\' returning id::text as id, title, status',
      ),
      parameters: {'id': id, 'status': status},
    );
    return result.isEmpty
        ? Response.notFound('Não encontrado.')
        : _ok(result.first.toColumnMap());
  }

  /// Gera, armazena apenas o hash e devolve um token de sessão temporário.
  Future<String> _session({required String userId, String? profileId}) async {
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final token = base64UrlEncode(bytes).replaceAll('=', '');
    await db.execute(
      Sql.named(
        'insert into local_sessions (token_hash, user_id, profile_id, expires_at) values (@hash, @user, @profile, now() + interval \'30 days\')',
      ),
      parameters: {
        'hash': sha256.convert(utf8.encode(token)).toString(),
        'user': userId,
        'profile': profileId,
      },
    );
    return token;
  }

  /// Obtém o identificador do perfil associado ao token enviado na requisição.
  Future<String?> _profileId(Request request) async {
    final header = request.headers['authorization'];
    if (header == null || !header.startsWith('Bearer ')) return null;
    final hash = sha256.convert(utf8.encode(header.substring(7))).toString();
    final row = await db.execute(
      Sql.named(
        'select profile_id from local_sessions where token_hash = @hash and expires_at > now()',
      ),
      parameters: {'hash': hash},
    );
    return row.isEmpty ? null : row.first[0].toString();
  }

  /// Confirma que a sessão pertence a uma conta administradora ativa.
  Future<_AuthContext?> _adminContext(Request request) async {
    final header = request.headers['authorization'];
    if (header == null || !header.startsWith('Bearer ')) return null;
    final hash = sha256.convert(utf8.encode(header.substring(7))).toString();
    final row = await db.execute(
      Sql.named(
        'select s.user_id, u.user_type::text as user_type, u.is_active from local_sessions s join users u on u.id = s.user_id where s.token_hash = @hash and s.expires_at > now()',
      ),
      parameters: {'hash': hash},
    );
    if (row.isEmpty) return null;
    final values = row.first.toColumnMap();
    if (values['user_type'].toString() != 'administrator' ||
        values['is_active'] != true)
      return null;
    return _AuthContext(values['user_id'].toString());
  }
}

/// Guarda o identificador da conta autorizada para operações administrativas.
class _AuthContext {
  /// Cria o contexto com a conta já autorizada para administrar o sistema.
  const _AuthContext(this.userId);
  final String userId;
}

/// Lê o corpo JSON da requisição ou retorna nulo quando ele for inválido.
Future<Map<String, dynamic>?> _body(Request request) async {
  try {
    final value = jsonDecode(await request.readAsString());
    return value is Map<String, dynamic> ? value : null;
  } catch (_) {
    return null;
  }
}

/// Valida e limpa um texto dentro do tamanho permitido.
String? _text(Object? value, int min, int max) {
  final text = value is String ? value.trim() : '';
  return text.length >= min && text.length <= max ? text : null;
}

/// Converte e valida um número inteiro dentro dos limites informados.
int? _int(Object? value, int min, int max) {
  final number = value is num ? value.toInt() : int.tryParse('$value');
  return number != null && number >= min && number <= max ? number : null;
}

/// Converte e valida um número decimal dentro dos limites informados.
double? _number(Object? value, double min, double max) {
  final number = value is num ? value.toDouble() : double.tryParse('$value');
  return number != null && number >= min && number <= max ? number : null;
}

/// Monta uma sugestão determinística sem depender de serviços externos.
Map<String, Object> _predefinedSuggestion(String category, int profile) {
  final series = profile >= 3 ? 2 : 3;
  final intensity = profile == 4
      ? 'muito leve'
      : profile == 3
      ? 'leve'
      : 'moderada';
  final content = switch (category) {
    'strength' => (
      title: 'Força para membros superiores',
      rationale: 'Prioriza movimentos básicos com intensidade $intensity.',
      items: [
        'Supino reto — $series séries',
        'Remada baixa — $series séries',
        'Desenvolvimento — $series séries',
      ],
    ),
    'running' => (
      title: 'Base para corrida',
      rationale: 'Fortalece pernas e core com intensidade $intensity.',
      items: [
        'Agachamento com peso corporal — $series séries',
        'Ponte de glúteos — $series séries',
        'Prancha — $series séries',
      ],
    ),
    'cycling' => (
      title: 'Base para ciclismo',
      rationale:
          'Prioriza pernas, core e mobilidade com intensidade $intensity.',
      items: [
        'Leg press leve — $series séries',
        'Elevação de panturrilhas — $series séries',
        'Prancha lateral — $series séries',
      ],
    ),
    _ => (
      title: 'Base geral para natação',
      rationale: 'Equilibra ombros, costas e core com intensidade $intensity.',
      items: [
        'Puxada frontal leve — $series séries',
        'Rotação externa de ombro — $series séries',
        'Prancha — $series séries',
      ],
    ),
  };
  return {
    'title': content.title,
    'rationale': content.rationale,
    'items': content.items,
  };
}

/// Cria uma resposta JSON de sucesso com o código HTTP informado.
Response _ok(Object body, {int status = 200}) =>
    Response(status, body: jsonEncode(body), headers: apiHeaders);

/// Cria uma resposta JSON para dados inválidos.
Response _bad(String text) => _ok({'error': text}, status: 400);

/// Cria uma resposta JSON para conflito de dados existentes.
Response _conflict(String text) => _ok({'error': text}, status: 409);

/// Cria uma resposta JSON quando a sessão não é autorizada.
Response _unauthorized() =>
    _ok({'error': 'Acesso não autorizado.'}, status: 401);

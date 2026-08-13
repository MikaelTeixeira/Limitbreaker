import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  final url = Platform.environment['DATABASE_URL'];
  if (url == null || url.isEmpty) throw StateError('Defina DATABASE_URL.');
  final db = await Connection.openFromUrl(url);
  final api = _Api(db);
  final router = Router()
    ..get('/health', api.health)
    ..post('/auth/register', api.register)
    ..post('/auth/login', api.login)
    ..get('/me', api.me)
    ..get('/workouts', api.listWorkouts)
    ..post('/workouts', api.createWorkout);
  final handler = const Pipeline()
      .addMiddleware(_cors)
      .addMiddleware(logRequests())
      .addHandler(router.call);
  final server = await shelf_io.serve(
    handler,
    InternetAddress.loopbackIPv4,
    8080,
  );
  stdout.writeln('API local em http://${server.address.host}:${server.port}');
}

final _cors = createMiddleware(
  requestHandler: (request) =>
      request.method == 'OPTIONS' ? Response.ok('', headers: _headers) : null,
  responseHandler: (response) => response.change(headers: _headers),
);
const _headers = {
  'content-type': 'application/json; charset=utf-8',
  'access-control-allow-origin': '*',
  'access-control-allow-headers': 'authorization, content-type',
  'access-control-allow-methods': 'GET, POST, OPTIONS',
};

class _Api {
  _Api(this.db);
  final Connection db;

  Future<Response> health(Request _) async {
    await db.execute('select 1');
    return _ok({'database': 'connected'});
  }

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
            'insert into app_profiles (email, display_name, age, height_cm, weight_kg) values (@email, @name, @age, @height, @weight) returning id, email, display_name',
          ),
          parameters: {
            'email': email,
            'name': displayName,
            'age': age,
            'height': height,
            'weight': weight,
          },
        );
        await tx.execute(
          Sql.named(
            'insert into local_credentials (profile_id, username, password_hash) values (@id, @username, @hash)',
          ),
          parameters: {
            'id': inserted.first[0],
            'username': username.toLowerCase(),
            'hash': BCrypt.hashpw(password, BCrypt.gensalt()),
          },
        );
        return inserted.first.toColumnMap();
      });
      return _ok({
        ...profile,
        'token': await _session(profile['id'].toString()),
      }, status: 201);
    } on ServerException catch (_) {
      return _conflict('E-mail ou nome de usuário já cadastrado.');
    }
  }

  Future<Response> login(Request request) async {
    final body = await _body(request);
    final identifier = _text(body?['identifier'], 3, 320)?.toLowerCase();
    final password = _text(body?['password'], 8, 128);
    if (identifier == null || password == null)
      return _bad('Informe acesso e senha.');
    final result = await db.execute(
      Sql.named(
        'select p.id, p.email, p.display_name, c.password_hash from local_credentials c join app_profiles p on p.id = c.profile_id where c.username = @value or p.email = @value limit 1',
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
    return _ok({
      'id': profile['id'],
      'email': profile['email'],
      'display_name': profile['display_name'],
      'token': await _session(profile['id'].toString()),
    });
  }

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

  Future<String> _session(String profileId) async {
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final token = base64UrlEncode(bytes).replaceAll('=', '');
    await db.execute(
      Sql.named(
        'insert into local_sessions (token_hash, profile_id, expires_at) values (@hash, @profile, now() + interval \'30 days\')',
      ),
      parameters: {
        'hash': sha256.convert(utf8.encode(token)).toString(),
        'profile': profileId,
      },
    );
    return token;
  }

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
}

Future<Map<String, dynamic>?> _body(Request request) async {
  try {
    final value = jsonDecode(await request.readAsString());
    return value is Map<String, dynamic> ? value : null;
  } catch (_) {
    return null;
  }
}

String? _text(Object? value, int min, int max) {
  final text = value is String ? value.trim() : '';
  return text.length >= min && text.length <= max ? text : null;
}

int? _int(Object? value, int min, int max) {
  final number = value is num ? value.toInt() : int.tryParse('$value');
  return number != null && number >= min && number <= max ? number : null;
}

double? _number(Object? value, double min, double max) {
  final number = value is num ? value.toDouble() : double.tryParse('$value');
  return number != null && number >= min && number <= max ? number : null;
}

Response _ok(Object body, {int status = 200}) =>
    Response(status, body: jsonEncode(body), headers: _headers);
Response _bad(String text) => _ok({'error': text}, status: 400);
Response _conflict(String text) => _ok({'error': text}, status: 409);
Response _unauthorized() =>
    _ok({'error': 'Acesso não autorizado.'}, status: 401);

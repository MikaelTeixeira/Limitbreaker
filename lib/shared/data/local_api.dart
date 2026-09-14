import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Cliente HTTP usado pelo Flutter para falar com a API local de desenvolvimento.
class LocalApi {
  /// Impede instâncias externas e mantém um único cliente compartilhado.
  LocalApi._();
  static final instance = LocalApi._();
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'local_api_session_token';
  static const _userTypeKey = 'local_api_user_type';

  /// Obtém a URL da API definida para o ambiente atual.
  String get _baseUrl => const String.fromEnvironment(
    'LOCAL_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  /// Faz login e salva o token de sessão no armazenamento seguro.
  Future<bool> login(String identifier, String password) async {
    final result = await _post('/auth/login', {
      'identifier': identifier,
      'password': password,
    });
    await _storage.write(key: _tokenKey, value: result['token'] as String);
    await _storage.write(
      key: _userTypeKey,
      value: result['user_type'] as String? ?? 'standard',
    );
    return result['user_type'] == 'administrator';
  }

  /// Cria uma conta e salva o token recebido no armazenamento seguro.
  Future<void> register({
    required String username,
    required String email,
    required String displayName,
    required String password,
    required int age,
    required double heightCm,
    required double weightKg,
  }) async {
    final result = await _post('/auth/register', {
      'username': username,
      'email': email,
      'displayName': displayName,
      'password': password,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
    });
    await _storage.write(key: _tokenKey, value: result['token'] as String);
    await _storage.write(
      key: _userTypeKey,
      value: result['user_type'] as String? ?? 'standard',
    );
  }

  /// Persiste as preferências e respostas finais do onboarding.
  Future<int> saveOnboarding({
    required String goal,
    required List<String> sports,
    required String activityBaseline,
    required String familyStatus,
    required String limitationStatus,
    required bool requiresGentleTraining,
    required String consentVersion,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/onboarding'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer ${await _token()}',
      },
      body: jsonEncode({
        'goal': goal,
        'sports': sports,
        'activityBaseline': activityBaseline,
        'familyStatus': familyStatus,
        'limitationStatus': limitationStatus,
        'requiresGentleTraining': requiresGentleTraining,
        'consentVersion': consentVersion,
      }),
    );
    return _decode(response)['training_profile'] as int;
  }

  /// Gera e persiste uma sugestão pré-definida para a modalidade escolhida.
  Future<Map<String, dynamic>> createWorkoutSuggestion(
    String category, {
    String? muscleGroup,
  }) async {
    final body = <String, Object?>{'category': category};
    if (muscleGroup != null) body['muscleGroup'] = muscleGroup;
    final response = await http.post(
      Uri.parse('$_baseUrl/workout-suggestions'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer ${await _token()}',
      },
      body: jsonEncode(body),
    );
    return Map<String, dynamic>.from(_decode(response)['suggestion'] as Map);
  }

  /// Informa se a sessão local pertence a uma conta administradora.
  Future<bool> isAdministrator() async =>
      await _storage.read(key: _userTypeKey) == 'administrator';

  /// Remove token e tipo de usuário salvos localmente.
  Future<void> signOut() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userTypeKey);
  }

  /// Busca os dados básicos do perfil autenticado.
  Future<UserProfile> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {'authorization': 'Bearer ${await _token()}'},
    );
    return UserProfile.fromJson(_decode(response));
  }

  /// Atualiza nome e medidas do perfil autenticado.
  Future<UserProfile> updateProfile({
    required String displayName,
    required int age,
    required double heightCm,
    required double weightKg,
  }) async {
    final request = http.Request('PATCH', Uri.parse('$_baseUrl/me'))
      ..headers.addAll({
        'content-type': 'application/json',
        'authorization': 'Bearer ${await _token()}',
      })
      ..body = jsonEncode({
        'displayName': displayName,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
      });
    return UserProfile.fromJson(
      _decode(await http.Response.fromStream(await request.send())),
    );
  }

  /// Lista usuários disponíveis na área administrativa.
  Future<List<Map<String, dynamic>>> adminUsers() =>
      _adminItems('/admin/users');

  /// Lista exercícios disponíveis na área administrativa.
  Future<List<Map<String, dynamic>>> adminExercises() =>
      _adminItems('/admin/exercises');

  /// Lista categorias de exercício disponíveis na área administrativa.
  Future<List<Map<String, dynamic>>> adminCategories() =>
      _adminItems('/admin/categories');

  /// Cria um exercício pelo painel administrativo.
  Future<void> createAdminExercise(String name, String categoryId) =>
      _adminRequest('POST', '/admin/exercises', {
        'name': name,
        'categoryId': categoryId,
      });

  /// Renomeia um exercício pelo painel administrativo.
  Future<void> renameAdminExercise(String id, String name) =>
      _adminRequest('PATCH', '/admin/exercises/$id', {'name': name});

  /// Remove um exercício pelo painel administrativo.
  Future<void> deleteAdminExercise(String id) =>
      _adminRequest('DELETE', '/admin/exercises/$id', const {});

  /// Atualiza dados administrativos de uma conta.
  Future<void> updateAdminUser(String id, Map<String, Object?> values) =>
      _adminRequest('PATCH', '/admin/users/$id', values);

  /// Cria um evento simples pelo painel administrativo.
  Future<void> createAdminEvent(String title) =>
      _adminRequest('POST', '/admin/events', {'title': title});

  /// Busca itens administrativos autenticados no caminho informado.
  Future<List<Map<String, dynamic>>> _adminItems(String path) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: {'authorization': 'Bearer ${await _token()}'},
    );
    final body = _decode(response);
    return (body['items'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  /// Envia uma alteração administrativa autenticada para a API.
  Future<void> _adminRequest(
    String method,
    String path,
    Map<String, Object?> body,
  ) async {
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers.addAll({
        'content-type': 'application/json',
        'authorization': 'Bearer ${await _token()}',
      })
      ..body = jsonEncode(body);
    _decode(await http.Response.fromStream(await request.send()));
  }

  /// Envia um treino manual para a API autenticada.
  Future<void> createWorkout(Map<String, Object?> payload) async {
    final token = await _token();
    final response = await http.post(
      Uri.parse('$_baseUrl/workouts'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    _decode(response);
  }

  /// Lista treinos salvos para a sessão autenticada.
  Future<List<Map<String, dynamic>>> listWorkouts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/workouts'),
      headers: {'authorization': 'Bearer ${await _token()}'},
    );
    final body = _decode(response);
    return (body['items'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  /// Busca uma sessão completa do perfil autenticado.
  Future<Map<String, dynamic>> getWorkout(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/workouts/$id'),
      headers: {'authorization': 'Bearer ${await _token()}'},
    );
    return _decode(response);
  }

  /// Exclui uma sessão pertencente ao perfil autenticado.
  Future<void> deleteWorkout(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/workouts/$id'),
      headers: {'authorization': 'Bearer ${await _token()}'},
    );
    if (response.statusCode != 204) _decode(response);
  }

  /// Lê o token salvo ou interrompe a operação sem sessão ativa.
  Future<String> _token() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) {
      throw const LocalApiException(
        'Entre na conta antes de registrar o treino.',
      );
    }
    return token;
  }

  /// Envia um POST JSON e devolve a resposta já validada.
  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, Object?> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 8));
      return _decode(response);
    } on Exception {
      throw const LocalApiException(
        'A API local está indisponível. Inicie o sistema pelo flutter.bat e confira o PostgreSQL.',
      );
    }
  }

  /// Converte a resposta JSON e lança um erro para códigos não bem-sucedidos.
  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LocalApiException(
        (body['error'] as String?) ??
            'Não foi possível comunicar com a API local.',
      );
    }
    return body;
  }
}

/// Erro amigável retornado pelo cliente da API local.
class LocalApiException implements Exception {
  const LocalApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

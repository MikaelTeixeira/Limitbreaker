import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LocalApi {
  LocalApi._();
  static final instance = LocalApi._();
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'local_api_session_token';
  static const _userTypeKey = 'local_api_user_type';
  String get _baseUrl => const String.fromEnvironment(
    'LOCAL_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

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

  Future<bool> isAdministrator() async =>
      await _storage.read(key: _userTypeKey) == 'administrator';

  Future<void> signOut() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userTypeKey);
  }

  Future<List<Map<String, dynamic>>> adminUsers() =>
      _adminItems('/admin/users');
  Future<List<Map<String, dynamic>>> adminExercises() =>
      _adminItems('/admin/exercises');
  Future<List<Map<String, dynamic>>> adminCategories() =>
      _adminItems('/admin/categories');

  Future<void> createAdminExercise(String name, String categoryId) =>
      _adminRequest('POST', '/admin/exercises', {
        'name': name,
        'categoryId': categoryId,
      });
  Future<void> renameAdminExercise(String id, String name) =>
      _adminRequest('PATCH', '/admin/exercises/$id', {'name': name});
  Future<void> deleteAdminExercise(String id) =>
      _adminRequest('DELETE', '/admin/exercises/$id', const {});
  Future<void> updateAdminUser(String id, Map<String, Object?> values) =>
      _adminRequest('PATCH', '/admin/users/$id', values);
  Future<void> createAdminEvent(String title) =>
      _adminRequest('POST', '/admin/events', {'title': title});

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

  Future<String> _token() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) {
      throw const LocalApiException(
        'Entre na conta antes de registrar o treino.',
      );
    }
    return token;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

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

class LocalApiException implements Exception {
  const LocalApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LocalApi {
  LocalApi._();
  static final instance = LocalApi._();
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'local_api_session_token';
  String get _baseUrl => const String.fromEnvironment(
    'LOCAL_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  Future<void> login(String identifier, String password) async {
    final result = await _post('/auth/login', {
      'identifier': identifier,
      'password': password,
    });
    await _storage.write(key: _tokenKey, value: result['token'] as String);
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
  }

  Future<void> createWorkout(Map<String, Object?> payload) async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null)
      throw const LocalApiException(
        'Entre na conta antes de registrar o treino.',
      );
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

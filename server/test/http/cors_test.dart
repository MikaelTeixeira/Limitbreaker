import 'package:limit_breaker_local_api/http/cors.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

/// Verifica o contrato CORS exigido pelo painel administrativo no navegador.
void main() {
  final handler = const Pipeline()
      .addMiddleware(corsMiddleware)
      .addHandler((_) => Response.ok('{}'));

  test('libera PATCH e DELETE no preflight administrativo', () async {
    final response = await handler(
      Request(
        'OPTIONS',
        Uri.parse('http://127.0.0.1:8080/admin/users/user-id'),
        headers: const {
          'origin': 'http://localhost:8081',
          'access-control-request-method': 'PATCH',
        },
      ),
    );

    expect(response.statusCode, 200);
    expect(response.headers['access-control-allow-origin'], '*');
    expect(response.headers['access-control-allow-methods'], contains('PATCH'));
    expect(
      response.headers['access-control-allow-methods'],
      contains('DELETE'),
    );
  });

  test('inclui os cabeçalhos CORS nas respostas comuns', () async {
    final response = await handler(
      Request('GET', Uri.parse('http://127.0.0.1:8080/health')),
    );

    expect(response.statusCode, 200);
    expect(response.headers['access-control-allow-origin'], '*');
  });
}

import 'package:shelf/shelf.dart';

/// Cabeçalhos compartilhados pelas respostas JSON da API local.
const apiHeaders = <String, String>{
  'content-type': 'application/json; charset=utf-8',
  'access-control-allow-origin': '*',
  'access-control-allow-headers': 'authorization, content-type',
  'access-control-allow-methods': 'GET, POST, PATCH, DELETE, OPTIONS',
};

/// Permite que o aplicativo web chame todos os endpoints locais autorizados.
final corsMiddleware = createMiddleware(
  requestHandler: (request) {
    if (request.method != 'OPTIONS') return null;
    return Response.ok('', headers: apiHeaders);
  },
  responseHandler: (response) => response.change(headers: apiHeaders),
);

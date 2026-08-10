import 'package:flutter_test/flutter_test.dart';
import 'package:limit_breaker/shared/models/models.dart';
import 'package:limit_breaker/shared/repositories/repositories.dart';

void main() {
  test('envia e aceita convite local', () async {
    final repository = LocalAppRepository();
    final sent = await repository.sendRequest('lb-caio-123');
    expect(sent.status, FriendRequestStatus.pending);
    expect(sent.direction, FriendRequestDirection.sent);
    await repository.respondToRequest(sent.id, FriendRequestStatus.accepted);
    expect(
      (await repository.getRequests()).last.status,
      FriendRequestStatus.accepted,
    );
  });

  test('uma conta nova começa sem amigos ou convites', () async {
    final repository = LocalAppRepository();
    expect(await repository.getRequests(), isEmpty);
    expect(await repository.getFriends(), isEmpty);
  });
}

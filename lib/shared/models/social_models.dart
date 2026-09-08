/// Relação direta entre duas pessoas no aplicativo.
class Friendship {
  const Friendship({required this.userId, required this.friendId});

  final String userId;
  final String friendId;
}

/// Resumo de amigo exibido na tela social.
class FriendSummary {
  const FriendSummary({
    required this.displayName,
    required this.rankingLabel,
    required this.recentActivity,
  });

  final String displayName;
  final String rankingLabel;
  final String recentActivity;
}

/// Estado atual de uma solicitação de amizade.
enum FriendRequestStatus { pending, accepted, declined }

/// Direção da solicitação em relação à pessoa logada.
enum FriendRequestDirection { received, sent }

/// Convite de amizade enviado ou recebido.
class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.displayName,
    required this.status,
    required this.direction,
  });

  final String id;
  final String fromUserId;
  final String displayName;
  final FriendRequestStatus status;
  final FriendRequestDirection direction;
}

/// Conversa exibida na área social.
class ChatConversation {
  const ChatConversation({required this.id, required this.title});

  final String id;
  final String title;
}

/// Participante de uma conversa.
class ChatMember {
  const ChatMember({required this.userId, required this.conversationId});

  final String userId;
  final String conversationId;
}

/// Mensagem enviada em uma conversa.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.authorId,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String conversationId;
  final String authorId;
  final String text;
  final DateTime sentAt;
}

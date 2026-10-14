enum RequestStatus { pending, accepted, declined, cancelled, expired, voided }

class FlamingoRequest {
  FlamingoRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  factory FlamingoRequest.fromJson(Map<String, dynamic> json) =>
      FlamingoRequest(
        id: json['id'] as String,
        senderId: json['sender_id'] as String,
        receiverId: json['receiver_id'] as String,
        status: RequestStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );

  final String id;
  final String senderId;
  final String receiverId;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;

  /// Pendiente y sin expirar (el servidor la expira al minuto, esto evita el desfase).
  bool get isLive =>
      status == RequestStatus.pending && expiresAt.isAfter(DateTime.now());
}

sealed class SendResult {}

class RequestSent extends SendResult {}

class InstantMatch extends SendResult {}

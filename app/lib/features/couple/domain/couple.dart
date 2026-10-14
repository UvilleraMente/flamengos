enum CoupleStatus { active, dissolving, dissolved }

/// Una pareja (match). Se llama Couple para no chocar con `Match` de dart:core.
class Couple {
  Couple({
    required this.id,
    required this.userA,
    required this.userB,
    required this.status,
    required this.createdAt,
    required this.dissolutionRequestedBy,
    required this.dissolveAt,
  });

  factory Couple.fromJson(Map<String, dynamic> json) => Couple(
    id: json['id'] as String,
    userA: json['user_a'] as String,
    userB: json['user_b'] as String,
    status: CoupleStatus.values.byName(json['status'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
    dissolutionRequestedBy: json['dissolution_requested_by'] as String?,
    dissolveAt: json['dissolve_at'] == null
        ? null
        : DateTime.parse(json['dissolve_at'] as String),
  );

  final String id;
  final String userA;
  final String userB;
  final CoupleStatus status;
  final DateTime createdAt;
  final String? dissolutionRequestedBy;
  final DateTime? dissolveAt;

  String partnerOf(String me) => me == userA ? userB : userA;
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as int,
    senderId: json['sender_id'] as String,
    body: json['body'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final int id;
  final String senderId;
  final String body;
  final DateTime createdAt;
}

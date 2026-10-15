/// Debe coincidir con el enum `notification_type` del SQL.
enum NotificationType {
  requestReceived('request_received'),
  requestAccepted('request_accepted'),
  requestExpiring('request_expiring'),
  dissolutionRequested('dissolution_requested'),
  dissolutionCancelled('dissolution_cancelled'),
  coupleDissolved('couple_dissolved'),
  photoRejected('photo_rejected'),
  boostStarted('boost_started'),
  dailyPicks('daily_picks'),
  newNearby('new_nearby'),
  dailyAnswer('daily_answer');

  const NotificationType(this.dbValue);
  final String dbValue;

  static NotificationType? parse(String value) =>
      values.where((t) => t.dbValue == value).firstOrNull;
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.actorId,
    required this.createdAt,
    required this.readAt,
    this.data = const {},
  });

  static AppNotification? tryParse(Map<String, dynamic> json) {
    final type = NotificationType.parse(json['type'] as String);
    if (type == null) return null;
    return AppNotification(
      id: json['id'] as int,
      type: type,
      actorId: json['actor_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );
  }

  final int id;
  final NotificationType type;
  final String? actorId;
  final DateTime createdAt;
  final DateTime? readAt;

  /// Datos extra (p. ej. {"count": 4} en new_nearby).
  final Map<String, dynamic> data;

  bool get isUnread => readAt == null;
}

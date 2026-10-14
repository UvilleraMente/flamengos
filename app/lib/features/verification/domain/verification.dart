import 'dart:math';

enum VerificationStatus { pending, approved, rejected }

class VerificationRequest {
  VerificationRequest({required this.status, required this.createdAt});

  factory VerificationRequest.fromJson(Map<String, dynamic> json) =>
      VerificationRequest(
        status: VerificationStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final VerificationStatus status;
  final DateTime createdAt;
}

/// Pose que el usuario debe imitar en la selfie (prueba de que es una foto
/// nueva y no una sacada de internet).
enum VerificationPose {
  peace('✌️'),
  thumbsUp('👍'),
  openHand('🖐️'),
  pointUp('☝️');

  const VerificationPose(this.emoji);
  final String emoji;

  static VerificationPose random() => values[Random().nextInt(values.length)];
}

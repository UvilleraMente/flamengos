import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../profile/data/profile_repository.dart';
import '../domain/verification.dart';

final verificationRepositoryProvider = Provider(
  (ref) => VerificationRepository(
    ref.watch(supabaseProvider),
    ref.watch(profileRepositoryProvider),
  ),
);

/// Última solicitud de verificación del usuario (o null si nunca pidió).
final latestVerificationProvider = StreamProvider<VerificationRequest?>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return Stream.value(null);
  return ref.watch(verificationRepositoryProvider).watchLatest();
});

class VerificationRepository {
  VerificationRepository(this._db, this._profiles);

  final SupabaseClient _db;
  final ProfileRepository _profiles;

  Stream<VerificationRequest?> watchLatest() => _db
      .from('verification_requests')
      .stream(primaryKey: ['id'])
      .eq('user_id', _db.myId)
      .order('created_at', ascending: false)
      .limit(1)
      .map(
        (rows) =>
            rows.isEmpty ? null : VerificationRequest.fromJson(rows.first),
      );

  /// Sube la selfie al bucket privado y crea la solicitud para revisión.
  Future<void> submit(XFile selfie, VerificationPose pose) async {
    final path = await _profiles.uploadPhoto(selfie, bucket: 'verifications');
    await _db.rpc(
      'request_verification',
      params: {'p_path': path, 'p_pose': pose.name},
    );
  }
}

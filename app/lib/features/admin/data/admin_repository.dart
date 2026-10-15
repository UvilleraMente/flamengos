import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

final adminRepositoryProvider = Provider(
  (ref) => AdminRepository(ref.watch(supabaseProvider)),
);

/// ¿La cuenta actual es admin? (Las funciones de admin lo vuelven a
/// comprobar en el servidor; esto solo decide si se muestra el panel.)
final isAdminProvider = FutureProvider<bool>((ref) async {
  if (ref.watch(currentUserIdProvider) == null) return false;
  try {
    return await ref.watch(supabaseProvider).rpc('is_admin') == true;
  } catch (_) {
    return false;
  }
});

final adminCountsProvider = FutureProvider.autoDispose<Map<String, int>>(
  (ref) => ref.watch(adminRepositoryProvider).counts(),
);

final adminVerificationsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref
          .watch(adminRepositoryProvider)
          .list('admin_pending_verifications'),
    );

final adminPhotosProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref.watch(adminRepositoryProvider).list('admin_pending_photos'),
    );

final adminReportsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref.watch(adminRepositoryProvider).list('admin_open_reports'),
    );

class AdminRepository {
  AdminRepository(this._db);

  final SupabaseClient _db;

  Future<Map<String, int>> counts() async {
    final data = await _db.rpc('admin_counts') as Map;
    return {
      for (final e in data.entries) e.key as String: (e.value as num).toInt(),
    };
  }

  Future<List<Map<String, dynamic>>> list(String function) async {
    final rows = await _db.rpc(function) as List;
    return rows.cast<Map<String, dynamic>>();
  }

  /// La selfie está en un bucket privado: enlace temporal de 10 minutos.
  Future<String> selfieUrl(String path) =>
      _db.storage.from('verifications').createSignedUrl(path, 600);

  Future<void> reviewVerification(String id, bool approve) => _db.rpc(
    'admin_review_verification',
    params: {'p_request': id, 'p_approve': approve},
  );

  Future<void> reviewPhoto(String path, bool approve) => _db.rpc(
    'admin_review_photo',
    params: {'p_path': path, 'p_approve': approve},
  );

  Future<void> dismissReport(String id) =>
      _db.rpc('admin_dismiss_report', params: {'p_report': id});

  Future<void> banUser(String userId) =>
      _db.rpc('admin_ban_user', params: {'p_user': userId});
}

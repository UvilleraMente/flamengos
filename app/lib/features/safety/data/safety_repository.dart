import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../profile/domain/profile.dart';
import '../domain/report_reason.dart';

final safetyRepositoryProvider = Provider(
  (ref) => SafetyRepository(ref.watch(supabaseProvider)),
);

final blockedProfilesProvider = FutureProvider.autoDispose<List<Profile>>(
  (ref) => ref.watch(safetyRepositoryProvider).blockedProfiles(),
);

class SafetyRepository {
  SafetyRepository(this._db);

  final SupabaseClient _db;

  /// Bloquea y, si hay [reason], también reporta. Anula solicitudes entre
  /// ambos y disuelve la pareja si la había.
  Future<void> block(
    String targetId, {
    ReportReason? reason,
    String? details,
  }) => _db.rpc(
    'block_user',
    params: {
      'p_target': targetId,
      'p_reason': reason?.dbValue,
      'p_details': details,
    },
  );

  Future<void> unblock(String targetId) =>
      _db.rpc('unblock_user', params: {'p_target': targetId});

  Future<List<Profile>> blockedProfiles() async {
    final rows = await _db
        .from('blocks')
        .select('profiles!blocks_blocked_id_fkey(*)')
        .order('created_at', ascending: false);
    return [
      for (final r in rows)
        if (r['profiles'] != null)
          Profile.fromJson(r['profiles'] as Map<String, dynamic>),
    ];
  }
}

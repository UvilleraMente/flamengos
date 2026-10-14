import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/flamingo_request.dart';

final requestsRepositoryProvider = Provider(
  (ref) => RequestsRepository(ref.watch(supabaseProvider)),
);

final incomingRequestsProvider = StreamProvider<List<FlamingoRequest>>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return Stream.value(const []);
  return ref.watch(requestsRepositoryProvider).watch(incoming: true);
});

final outgoingRequestsProvider = StreamProvider<List<FlamingoRequest>>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return Stream.value(const []);
  return ref.watch(requestsRepositoryProvider).watch(incoming: false);
});

/// Solicitudes vigentes (pendientes y sin expirar).
final liveIncomingCountProvider = Provider<int>(
  (ref) => ref.watch(
    incomingRequestsProvider.select(
      (v) => v.value?.where((r) => r.isLive).length ?? 0,
    ),
  ),
);

final liveOutgoingCountProvider = Provider<int>(
  (ref) => ref.watch(
    outgoingRequestsProvider.select(
      (v) => v.value?.where((r) => r.isLive).length ?? 0,
    ),
  ),
);

class RequestsRepository {
  RequestsRepository(this._db);

  final SupabaseClient _db;

  Stream<List<FlamingoRequest>> watch({required bool incoming}) => _db
      .from('requests')
      .stream(primaryKey: ['id'])
      .eq(incoming ? 'receiver_id' : 'sender_id', _db.myId)
      .order('created_at')
      .map((rows) => rows.map(FlamingoRequest.fromJson).toList());

  Future<SendResult> send(String targetId) async {
    final res =
        await _db.rpc('send_request', params: {'p_target': targetId}) as Map;
    return res['result'] == 'matched' ? InstantMatch() : RequestSent();
  }

  Future<void> accept(String id) =>
      _db.rpc('accept_request', params: {'p_request': id});

  Future<void> decline(String id) =>
      _db.rpc('decline_request', params: {'p_request': id});

  Future<void> cancel(String id) =>
      _db.rpc('cancel_request', params: {'p_request': id});

  /// Expira solicitudes y concreta disoluciones vencidas. El servidor ya lo
  /// hace con pg_cron; llamarlo desde la app solo adelanta el resultado.
  Future<void> housekeeping() => _db.rpc('housekeeping');
}

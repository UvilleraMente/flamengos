import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../profile/data/profile_repository.dart';
import '../domain/couple.dart';

final coupleRepositoryProvider = Provider(
  (ref) => CoupleRepository(ref.watch(supabaseProvider)),
);

final coupleProvider = StreamProvider<Couple?>((ref) {
  final matchId = ref.watch(
    myProfileProvider.select((p) => p.value?.currentMatchId),
  );
  if (matchId == null) return Stream.value(null);
  return ref.watch(coupleRepositoryProvider).watchCouple(matchId);
});

final messagesProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, String>(
      (ref, matchId) =>
          ref.watch(coupleRepositoryProvider).watchMessages(matchId),
    );

/// Hasta cuándo leyó cada quien el chat (userId → fecha). La fila del otro
/// solo llega si eres premium (RLS en chat_reads).
final chatReadsProvider = StreamProvider.autoDispose
    .family<Map<String, DateTime>, String>(
      (ref, matchId) => ref.watch(coupleRepositoryProvider).watchReads(matchId),
    );

class CoupleRepository {
  CoupleRepository(this._db);

  final SupabaseClient _db;

  Stream<Couple?> watchCouple(String id) => _db
      .from('matches')
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .map((rows) => rows.isEmpty ? null : Couple.fromJson(rows.first));

  Future<void> requestDissolution() => _db.rpc('request_dissolution');

  Future<void> cancelDissolution() => _db.rpc('cancel_dissolution');

  Stream<List<ChatMessage>> watchMessages(String matchId) => _db
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('match_id', matchId)
      .order('created_at')
      .map((rows) => rows.map(ChatMessage.fromJson).toList());

  Future<void> sendMessage(String matchId, String body) => _db
      .from('messages')
      .insert({'match_id': matchId, 'sender_id': _db.myId, 'body': body});

  Future<void> markRead(String matchId) =>
      _db.rpc('mark_chat_read', params: {'p_match': matchId});

  Stream<Map<String, DateTime>> watchReads(String matchId) => _db
      .from('chat_reads')
      .stream(primaryKey: ['match_id', 'user_id'])
      .eq('match_id', matchId)
      .map(
        (rows) => {
          for (final r in rows)
            r['user_id'] as String: DateTime.parse(r['last_read_at'] as String),
        },
      );
}

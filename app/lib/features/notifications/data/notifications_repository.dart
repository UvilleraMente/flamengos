import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/app_notification.dart';

final notificationsRepositoryProvider = Provider(
  (ref) => NotificationsRepository(ref.watch(supabaseProvider)),
);

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return Stream.value(const []);
  return ref.watch(notificationsRepositoryProvider).watch();
});

final unreadNotificationsProvider = Provider<int>(
  (ref) => ref.watch(
    notificationsProvider.select(
      (v) => v.value?.where((n) => n.isUnread).length ?? 0,
    ),
  ),
);

class NotificationsRepository {
  NotificationsRepository(this._db);

  final SupabaseClient _db;

  /// Las 50 más recientes, de la más nueva a la más vieja.
  Stream<List<AppNotification>> watch() => _db
      .from('notifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', _db.myId)
      .order('created_at', ascending: false)
      .limit(50)
      .map((rows) => [for (final r in rows) ?AppNotification.tryParse(r)]);

  Future<void> markAllRead() => _db.rpc('mark_notifications_read');
}

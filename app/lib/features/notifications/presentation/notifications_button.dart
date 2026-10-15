import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../profile/data/profile_repository.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

extension NotificationText on AppNotification {
  String text(AppLocalizations t, String name) => switch (type) {
    NotificationType.requestReceived => t.notifRequestReceived(name),
    NotificationType.requestAccepted => t.notifRequestAccepted(name),
    NotificationType.requestExpiring => t.notifRequestExpiring(name),
    NotificationType.dissolutionRequested => t.notifDissolutionRequested(name),
    NotificationType.dissolutionCancelled => t.notifDissolutionCancelled(name),
    NotificationType.coupleDissolved => t.notifCoupleDissolved(name),
  };

  IconData get icon => switch (type) {
    NotificationType.requestReceived => Icons.mail_rounded,
    NotificationType.requestAccepted => Icons.favorite_rounded,
    NotificationType.requestExpiring => Icons.hourglass_bottom_rounded,
    NotificationType.dissolutionRequested => Icons.heart_broken_rounded,
    NotificationType.dissolutionCancelled => Icons.healing_rounded,
    NotificationType.coupleDissolved => Icons.waving_hand_rounded,
  };
}

String timeAgo(DateTime when, BuildContext context) {
  final t = context.l10n;
  final d = DateTime.now().difference(when);
  if (d.inMinutes < 1) return t.timeJustNow;
  if (d.inHours < 1) return t.timeMinutesAgo(d.inMinutes);
  if (d.inDays < 1) return t.timeHoursAgo(d.inHours);
  return DateFormat.MMMd(context.localeTag).format(when.toLocal());
}

/// Campana con contador de no leídas. Abre la bandeja y las marca como leídas.
class NotificationsButton extends ConsumerWidget {
  const NotificationsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsProvider);
    return Badge.count(
      count: unread,
      isLabelVisible: unread > 0,
      backgroundColor: FlamColors.coral,
      child: FlamIconButton(
        icon: const Icon(Icons.notifications_rounded),
        size: 40,
        tooltip: context.l10n.notificationsTitle,
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => const _NotificationsSheet(),
          );
          if (unread > 0) {
            ref.read(notificationsRepositoryProvider).markAllRead().ignore();
          }
        },
      ),
    );
  }
}

class _NotificationsSheet extends ConsumerWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final list = ref.watch(notificationsProvider).value ?? const [];
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              t.notificationsTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: t.notificationsEmptyTitle,
                    message: t.notificationsEmptyMessage,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _NotificationTile(list[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile(this.n);

  final AppNotification n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final actor = n.actorId == null
        ? null
        : ref.watch(profileByIdProvider(n.actorId!)).value;
    return Glass(
      padding: const EdgeInsets.all(12),
      borderColor: n.isUnread
          ? FlamColors.pink.withValues(alpha: 0.6)
          : FlamColors.glassBorder,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Avatar(actor, radius: 22, ring: false),
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: FlamColors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(color: FlamColors.sheet, width: 2),
                  ),
                  child: Icon(n.icon, size: 12, color: FlamColors.onAccent),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.text(t, actor?.displayName ?? t.someone),
                  style: TextStyle(
                    fontWeight: n.isUnread ? FontWeight.w700 : FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo(n.createdAt, context),
                  style: TextStyle(color: FlamColors.textFaint, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

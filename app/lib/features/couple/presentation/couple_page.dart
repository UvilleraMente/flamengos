import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../notifications/presentation/notifications_button.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/profile.dart';
import '../../profile/presentation/profile_sheet.dart';
import '../../requests/data/requests_repository.dart';
import '../../safety/presentation/report_sheet.dart';
import '../data/couple_repository.dart';
import '../domain/couple.dart';
import 'chat_view.dart';

/// Pantalla de la pareja: quiénes son, estado de disolución y chat.
class CouplePage extends ConsumerWidget {
  const CouplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider).value;
    final me = ref.watch(myProfileProvider).value;
    if (couple == null || me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final partner = ref
        .watch(profileByIdProvider(couple.partnerOf(me.id)))
        .value;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _CoupleHeader(couple: couple, me: me, partner: partner),
            ),
          ),
          AnimatedSize(
            duration: FlamMotion.medium,
            child: couple.status == CoupleStatus.dissolving
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _DissolutionBanner(
                      couple: couple,
                      me: me.id,
                      partner: partner,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          Expanded(
            child: ChatView(matchId: couple.id, me: me.id),
          ),
        ],
      ),
    );
  }
}

class _CoupleHeader extends ConsumerWidget {
  const _CoupleHeader({
    required this.couple,
    required this.me,
    required this.partner,
  });

  final Couple couple;
  final Profile me;
  final Profile? partner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final days = DateTime.now().difference(couple.createdAt).inDays;

    return Glass(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: partner == null
                ? null
                : () => showProfileSheet(context, partner!),
            child: SizedBox(
              width: 92,
              height: 56,
              child: Stack(
                children: [
                  Avatar(me, radius: 24),
                  Positioned(right: 0, child: Avatar(partner, radius: 24)),
                  const Positioned(
                    left: 34,
                    bottom: -2,
                    child: Text('💕', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        partner?.displayName ?? '…',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (partner?.verified ?? false) ...[
                      const SizedBox(width: 6),
                      const VerifiedBadge(size: 18),
                    ],
                  ],
                ),
                Text(
                  t.coupleTogetherSince(days),
                  style: const TextStyle(color: FlamColors.textMuted),
                ),
              ],
            ),
          ),
          const NotificationsButton(),
          PopupMenuButton<void>(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (_) => [
              if (partner != null)
                PopupMenuItem(
                  onTap: () => showProfileSheet(context, partner!),
                  child: Text(t.coupleViewProfile),
                ),
              if (couple.status == CoupleStatus.active)
                PopupMenuItem(
                  onTap: () => _requestDissolution(context, ref),
                  child: Text(t.coupleEnd),
                ),
              if (partner != null)
                PopupMenuItem(
                  onTap: () => showReportSheet(context, partner!),
                  child: Text(
                    t.safetyReportOrBlock,
                    style: const TextStyle(color: FlamColors.danger),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _requestDissolution(BuildContext context, WidgetRef ref) async {
    final t = context.l10n;
    final ok = await confirm(
      context,
      emoji: '💔',
      title: t.coupleEndTitle,
      message: t.coupleEndMessage(partner?.displayName ?? t.someone),
      action: t.coupleEndAction,
      destructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(coupleRepositoryProvider).requestDissolution();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

class _DissolutionBanner extends ConsumerWidget {
  const _DissolutionBanner({
    required this.couple,
    required this.me,
    required this.partner,
  });

  final Couple couple;
  final String me;
  final Profile? partner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final repo = ref.read(coupleRepositoryProvider);
    final mine = couple.dissolutionRequestedBy == me;

    Future<void> run(Future<void> Function() action) async {
      try {
        await action();
      } catch (e) {
        if (context.mounted) showError(context, e);
      }
    }

    return Glass(
      borderColor: FlamColors.danger.withValues(alpha: 0.6),
      gradient: LinearGradient(
        colors: [
          FlamColors.danger.withValues(alpha: 0.22),
          FlamColors.danger.withValues(alpha: 0.08),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mine
                      ? t.coupleYouAskedToEnd
                      : t.couplePartnerAskedToEnd(
                          partner?.displayName ?? t.someone,
                        ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                if (couple.dissolveAt != null)
                  CountdownPill(
                    until: couple.dissolveAt!,
                    label: t.coupleDissolvesIn,
                    onDone: () => ref
                        .read(requestsRepositoryProvider)
                        .housekeeping()
                        .ignore(),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          mine
              ? FlamButton(
                  label: t.coupleUndoEnd,
                  size: FlamSize.small,
                  onPressed: () => run(repo.cancelDissolution),
                )
              : FlamButton(
                  label: t.coupleEndNow,
                  size: FlamSize.small,
                  variant: FlamVariant.danger,
                  onPressed: () => run(repo.requestDissolution),
                ),
        ],
      ),
    );
  }
}

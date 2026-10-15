import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/env.dart';
import '../../../app/router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/profile.dart';

const _premiumColor = Color(0xFFFF9F0A);

/// Estado premium y modo incógnito (en Ajustes).
class PremiumGroup extends ConsumerStatefulWidget {
  const PremiumGroup({super.key});

  @override
  ConsumerState<PremiumGroup> createState() => _PremiumGroupState();
}

class _PremiumGroupState extends ConsumerState<PremiumGroup> {
  bool _saving = false;

  Future<void> _setIncognito(bool value) async {
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile({
        'incognito': value,
      });
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final me = ref.watch(myProfileProvider).value;
    if (me == null) return const SizedBox.shrink();
    final premium = me.isPremium;

    return SettingsGroup(
      title: t.premiumTitle,
      footer: premium ? null : t.premiumComingSoon,
      children: [
        SettingsTile(
          icon: Icons.workspace_premium_rounded,
          color: _premiumColor,
          title: t.premiumPerksTitle,
          onTap: () => _showPerks(context, premium),
        ),
        SettingsTile(
          icon: Icons.insights_rounded,
          color: const Color(0xFF5856D6),
          title: t.insightsTitle,
          onTap: () => context.push(Routes.insights),
        ),
        SettingsTile(
          icon: Icons.visibility_off_rounded,
          color: const Color(0xFF8E8E93),
          title: t.premiumPerkIncognito,
          subtitle: premium ? t.premiumIncognitoHint : t.premiumOnly,
          trailing: Switch.adaptive(
            value: premium && me.incognito,
            onChanged: premium && !_saving ? _setIncognito : null,
          ),
        ),
      ],
    );
  }
}

String premiumStatus(BuildContext context, Profile me) {
  final t = context.l10n;
  final until = me.premiumUntil;
  if (me.founder) return t.premiumFounder;
  if (me.isPremium && until != null) {
    return t.premiumUntil(
      DateFormat.yMMMd(context.localeTag).format(until.toLocal()),
    );
  }
  return t.premiumFree;
}

void _showPerks(BuildContext context, bool premium) {
  final t = context.l10n;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: _premiumColor,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  t.premiumTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final (icon, text) in [
              (
                Icons.favorite_rounded,
                t.premiumPerkRequests(Env.premiumMaxActiveRequests),
              ),
              (Icons.visibility_off_rounded, t.premiumPerkIncognito),
              (Icons.done_all_rounded, t.premiumPerkSeen),
              (Icons.more_horiz_rounded, t.premiumPerkTyping),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(icon, size: 22, color: FlamColors.pink),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(text, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            if (!premium) ...[
              const SizedBox(height: 8),
              Text(
                t.premiumComingSoon,
                style: TextStyle(color: FlamColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

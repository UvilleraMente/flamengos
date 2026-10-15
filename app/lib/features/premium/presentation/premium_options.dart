import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/env.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../profile/data/profile_repository.dart';

/// Estado premium, sus beneficios y el modo incógnito (en Ajustes).
class PremiumOptions extends ConsumerStatefulWidget {
  const PremiumOptions({super.key});

  @override
  ConsumerState<PremiumOptions> createState() => _PremiumOptionsState();
}

class _PremiumOptionsState extends ConsumerState<PremiumOptions> {
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
    final until = me.premiumUntil;

    final status = me.founder
        ? t.premiumFounder
        : premium && until != null
        ? t.premiumUntil(
            DateFormat.yMMMd(context.localeTag).format(until.toLocal()),
          )
        : t.premiumFree;

    Widget perk(String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            premium ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            size: 18,
            color: premium ? FlamColors.mint : FlamColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: premium ? FlamColors.blush : FlamColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        perk(t.premiumPerkRequests(Env.premiumMaxActiveRequests)),
        perk(t.premiumPerkIncognito),
        perk(t.premiumPerkSeen),
        perk(t.premiumPerkTyping),
        const SizedBox(height: 4),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            t.premiumPerkIncognito,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(premium ? t.premiumIncognitoHint : t.premiumOnly),
          value: premium && me.incognito,
          onChanged: premium && !_saving ? _setIncognito : null,
        ),
        if (!premium)
          Text(
            t.premiumComingSoon,
            style: TextStyle(color: FlamColors.textMuted, fontSize: 13),
          ),
      ],
    );
  }
}

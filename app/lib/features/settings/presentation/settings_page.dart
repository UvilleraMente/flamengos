import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/env.dart';
import '../../../app/router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../premium/presentation/premium_options.dart';
import '../../profile/data/profile_repository.dart';
import '../../verification/presentation/verification_page.dart';
import 'appearance_options.dart';
import 'delete_account_dialog.dart';
import 'language_picker.dart';
import 'lock_screen.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final me = ref.watch(myProfileProvider).value;
    const gap = SizedBox(height: 26);

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              if (me != null) ...[
                Glass(
                  padding: const EdgeInsets.all(14),
                  radius: FlamRadius.md,
                  child: Row(
                    children: [
                      Avatar(me, radius: 30),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    me.displayName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (me.verified) ...[
                                  const SizedBox(width: 6),
                                  const VerifiedBadge(size: 18),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              premiumStatus(context, me),
                              style: TextStyle(color: FlamColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                gap,
              ],
              const PremiumGroup(),
              gap,
              const AppearanceGroup(),
              gap,
              const SettingsGroup(children: [LanguageTile()]),
              gap,
              SettingsGroup(
                title: t.settingsSafety,
                children: [
                  const BiometricLockTile(),
                  SettingsTile(
                    icon: Icons.verified_rounded,
                    color: FlamColors.mint,
                    title: me?.verified ?? false
                        ? t.verificationApprovedShort
                        : t.verificationCta,
                    trailing: const VerificationStatusPill(),
                    onTap: () => context.push(Routes.verification),
                  ),
                  SettingsTile(
                    icon: Icons.block_rounded,
                    color: const Color(0xFFFF3B30),
                    title: t.blockedTitle,
                    onTap: () => context.push(Routes.blocked),
                  ),
                ],
              ),
              gap,
              SettingsGroup(
                title: t.settingsLegal,
                children: [
                  SettingsTile(
                    icon: Icons.help_rounded,
                    color: const Color(0xFF007AFF),
                    title: t.helpTitle,
                    onTap: () => context.push(Routes.help),
                  ),
                  SettingsTile(
                    icon: Icons.description_rounded,
                    color: const Color(0xFF8E8E93),
                    title: t.legalTerms,
                    onTap: () => launchUrl(Uri.parse(Env.termsUrl)),
                  ),
                  SettingsTile(
                    icon: Icons.privacy_tip_rounded,
                    color: const Color(0xFF8E8E93),
                    title: t.legalPrivacy,
                    onTap: () => launchUrl(Uri.parse(Env.privacyUrl)),
                  ),
                ],
              ),
              gap,
              SettingsGroup(
                title: t.settingsAccount,
                children: [
                  SettingsTile(
                    icon: Icons.logout_rounded,
                    color: const Color(0xFF8E8E93),
                    title: t.actionSignOut,
                    // El router lleva al login.
                    onTap: () => ref.read(authRepositoryProvider).signOut(),
                  ),
                  SettingsTile(
                    icon: Icons.delete_forever_rounded,
                    color: FlamColors.danger,
                    title: t.deleteAccount,
                    destructive: true,
                    onTap: () => showDeleteAccountDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                t.settingsMadeBy,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: FlamColors.textFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

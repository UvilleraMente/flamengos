import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../verification/presentation/verification_page.dart';
import 'appearance_options.dart';
import 'delete_account_dialog.dart';
import 'language_picker.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final verified = ref.watch(
      myProfileProvider.select((p) => p.value?.verified ?? false),
    );
    const gap = SizedBox(height: 14);

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              GlassSection(
                title: t.settingsAppearance,
                child: const AppearanceOptions(),
              ),
              gap,
              GlassSection(
                title: t.settingsLanguage,
                child: const LanguageOptions(),
              ),
              gap,
              GlassSection(
                title: t.settingsVerification,
                child: _Row(
                  leading: verified
                      ? const VerifiedBadge(size: 26)
                      : const Icon(
                          Icons.verified_outlined,
                          color: FlamColors.mint,
                        ),
                  title: verified
                      ? t.verificationApprovedShort
                      : t.verificationCta,
                  trailing: const VerificationStatusPill(),
                  onTap: () => context.push(Routes.verification),
                ),
              ),
              gap,
              GlassSection(
                title: t.settingsSafety,
                child: _Row(
                  leading: Icon(Icons.block_rounded, color: FlamColors.blush),
                  title: t.blockedTitle,
                  onTap: () => context.push(Routes.blocked),
                ),
              ),
              gap,
              GlassSection(
                title: t.helpTitle,
                child: _Row(
                  leading: Icon(
                    Icons.help_outline_rounded,
                    color: FlamColors.blush,
                  ),
                  title: t.helpSubtitle,
                  onTap: () => context.push(Routes.help),
                ),
              ),
              gap,
              GlassSection(
                title: t.settingsAccount,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FlamButton(
                      label: t.actionSignOut,
                      icon: const Icon(Icons.logout_rounded),
                      variant: FlamVariant.glass,
                      expand: true,
                      // El router lleva al login.
                      onPressed: () =>
                          ref.read(authRepositoryProvider).signOut(),
                    ),
                    const SizedBox(height: 8),
                    FlamButton(
                      label: t.deleteAccount,
                      icon: const Icon(Icons.delete_forever_rounded),
                      variant: FlamVariant.ghost,
                      expand: true,
                      onPressed: () => showDeleteAccountDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.leading,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(FlamRadius.md),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (trailing != null) ...[trailing!, const SizedBox(width: 6)],
          Icon(Icons.chevron_right_rounded, color: FlamColors.textMuted),
        ],
      ),
    ),
  );
}

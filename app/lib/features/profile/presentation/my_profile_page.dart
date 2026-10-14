import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../verification/data/verification_repository.dart';
import '../../verification/domain/verification.dart';
import '../data/profile_repository.dart';
import 'profile_sheet.dart';

class MyProfilePage extends ConsumerWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final profile = ref.watch(myProfileProvider).value;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final verificationPending =
        ref.watch(latestVerificationProvider).value?.status ==
        VerificationStatus.pending;

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: Text(t.myProfileTitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassPill(
                  color: profile.isPaired ? FlamColors.pink : FlamColors.mint,
                  leading: Text(profile.isPaired ? '💕' : '🦩'),
                  child: Text(
                    profile.isPaired ? t.statusPaired : t.statusSingle,
                  ),
                ),
                const SizedBox(width: 8),
                FlamIconButton(
                  icon: const Icon(Icons.settings_rounded),
                  size: 40,
                  tooltip: t.settingsTitle,
                  onPressed: () => context.push(Routes.settings),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Column(
                      children: [
                        if (!profile.verified)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => context.push(Routes.verification),
                              child: Glass(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  10,
                                  14,
                                  10,
                                ),
                                borderColor: FlamColors.mint.withValues(
                                  alpha: 0.5,
                                ),
                                child: Row(
                                  children: [
                                    const VerifiedBadge(size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        verificationPending
                                            ? t.verificationPendingShort
                                            : t.verificationCta,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: GestureDetector(
                            onLongPress: () =>
                                showProfileSheet(context, profile),
                            child: ProfileCard(profile),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FlamButton(
                                label: t.myProfileEdit,
                                icon: const Icon(Icons.edit_rounded),
                                variant: FlamVariant.glass,
                                expand: true,
                                onPressed: () =>
                                    context.push(Routes.editProfile),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FlamIconButton(
                              icon: const Icon(Icons.visibility_rounded),
                              tooltip: t.myProfilePreview,
                              onPressed: () =>
                                  showProfileSheet(context, profile),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

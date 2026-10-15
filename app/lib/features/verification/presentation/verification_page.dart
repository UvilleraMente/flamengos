import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../profile/data/profile_repository.dart';
import '../data/verification_repository.dart';
import '../domain/verification.dart';

extension VerificationPoseL10n on VerificationPose {
  String instruction(AppLocalizations t) => switch (this) {
    VerificationPose.peace => t.posePeace,
    VerificationPose.thumbsUp => t.poseThumbsUp,
    VerificationPose.openHand => t.poseOpenHand,
    VerificationPose.pointUp => t.posePointUp,
  };
}

/// Pastilla con el estado de verificación (para Ajustes).
class VerificationStatusPill extends ConsumerWidget {
  const VerificationStatusPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final verified = ref.watch(
      myProfileProvider.select((p) => p.value?.verified ?? false),
    );
    final status = ref.watch(latestVerificationProvider).value?.status;
    if (verified) {
      return GlassPill(
        color: FlamColors.mint,
        child: Text(t.verificationStatusApproved),
      );
    }
    return switch (status) {
      VerificationStatus.pending => GlassPill(
        child: Text(t.verificationStatusPending),
      ),
      VerificationStatus.rejected => GlassPill(
        color: FlamColors.coral,
        child: Text(t.verificationStatusRejected),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Verificación con selfie: el usuario imita una pose al azar y un
/// moderador compara la selfie con sus fotos.
class VerificationPage extends ConsumerStatefulWidget {
  const VerificationPage({super.key});

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  final _pose = VerificationPose.random();
  bool _sending = false;

  Future<void> _takeSelfie() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _sending = true);
    try {
      await ref.read(verificationRepositoryProvider).submit(file, _pose);
      if (mounted) showInfo(context, context.l10n.verificationSent);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final verified = ref.watch(
      myProfileProvider.select((p) => p.value?.verified ?? false),
    );
    final status = ref.watch(latestVerificationProvider).value?.status;

    final Widget body;
    if (verified) {
      body = EmptyState(
        emoji: '✅',
        title: t.verificationApprovedTitle,
        message: t.verificationApprovedMessage,
      );
    } else if (status == VerificationStatus.pending) {
      body = EmptyState(
        emoji: '🕵️',
        title: t.verificationPendingTitle,
        message: t.verificationPendingMessage,
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (status == VerificationStatus.rejected)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Glass(
                borderColor: FlamColors.coral.withValues(alpha: 0.6),
                child: Text(t.verificationRejectedMessage),
              ),
            ),
          Glass(
            radius: FlamRadius.xl,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const VerifiedBadge(size: 56),
                const SizedBox(height: 16),
                Text(
                  t.verificationTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.verificationIntro,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: FlamColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 24),
                Heartbeat(
                  scale: 0.1,
                  child: Text(
                    _pose.emoji,
                    style: const TextStyle(fontSize: 88),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _pose.instruction(t),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                FlamButton(
                  label: t.verificationTakeSelfie,
                  icon: const Icon(Icons.photo_camera_front_rounded),
                  size: FlamSize.large,
                  expand: true,
                  loading: _sending,
                  onPressed: _takeSelfie,
                ),
                const SizedBox(height: 12),
                Text(
                  t.verificationPrivacy,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: FlamColors.textFaint, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsVerification)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: body,
        ),
      ),
    );
  }
}

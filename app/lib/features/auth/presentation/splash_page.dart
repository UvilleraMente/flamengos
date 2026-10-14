import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/widgets.dart';
import '../../profile/data/profile_repository.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final profile = ref.watch(myProfileProvider);
    return Scaffold(
      body: profile.hasError
          ? EmptyState(
              emoji: '🪶',
              title: t.splashError,
              message: describeError(context, profile.error!),
              action: Column(
                children: [
                  FlamButton(
                    label: t.actionRetry,
                    onPressed: () => ref.invalidate(myProfileProvider),
                  ),
                  const SizedBox(height: 8),
                  FlamButton(
                    label: t.actionSignOut,
                    variant: FlamVariant.ghost,
                    onPressed: () => Supabase.instance.client.auth.signOut(),
                  ),
                ],
              ),
            )
          : const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Heartbeat(child: Text('🦩', style: TextStyle(fontSize: 72))),
                  Wordmark(size: 36),
                ],
              ),
            ),
    );
  }
}

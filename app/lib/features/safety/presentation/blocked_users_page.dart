import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/safety_repository.dart';

class BlockedUsersPage extends ConsumerWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final blocked = ref.watch(blockedProfilesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.blockedTitle)),
      body: blocked.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.cloud_off_rounded,
          title: t.errorGeneric,
          message: describeError(context, e),
        ),
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.shield_outlined,
                title: t.blockedEmptyTitle,
                message: t.blockedEmptyMessage,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final p = list[i];
                  return Glass(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Avatar(p, ring: false),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            p.displayName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        FlamButton(
                          label: t.unblock,
                          size: FlamSize.small,
                          variant: FlamVariant.glass,
                          onPressed: () async {
                            try {
                              await ref
                                  .read(safetyRepositoryProvider)
                                  .unblock(p.id);
                              ref.invalidate(blockedProfilesProvider);
                            } catch (e) {
                              if (context.mounted) showError(context, e);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

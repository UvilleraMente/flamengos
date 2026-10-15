import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../notifications/presentation/notifications_button.dart';
import '../../premium/data/premium.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/profile.dart';
import '../../profile/presentation/profile_sheet.dart';
import '../data/requests_repository.dart';
import '../domain/flamingo_request.dart';

class RequestsPage extends ConsumerStatefulWidget {
  const RequestsPage({super.key});

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
  bool _incoming = true;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final value = ref.watch(
      _incoming ? incomingRequestsProvider : outgoingRequestsProvider,
    );
    final inCount = ref.watch(liveIncomingCountProvider);
    final outCount = ref.watch(liveOutgoingCountProvider);

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: Text(t.requestsTitle),
            trailing: const NotificationsButton(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: GlassSegmented(
                segments: [
                  (true, t.requestsReceivedTab(inCount)),
                  (
                    false,
                    t.requestsSentTab(
                      outCount,
                      ref.watch(requestLimitProvider),
                    ),
                  ),
                ],
                value: _incoming,
                onChanged: (v) => setState(() => _incoming = v),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: FlamMotion.medium,
              child: KeyedSubtree(
                key: ValueKey(_incoming),
                child: _list(value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(AsyncValue<List<FlamingoRequest>> value) {
    final t = context.l10n;
    if (value.hasError) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: t.requestsLoadError,
        message: describeError(context, value.error!),
      );
    }
    if (!value.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    final requests = value.value!
        .where((r) => r.isLive)
        .toList()
        .reversed
        .toList();
    if (requests.isEmpty) {
      return _incoming
          ? EmptyState(
              icon: Icons.mail_outline_rounded,
              title: t.requestsReceivedEmptyTitle,
              message: t.requestsReceivedEmptyMessage,
            )
          : EmptyState(
              icon: Icons.send_outlined,
              title: t.requestsSentEmptyTitle,
              message: t.requestsSentEmptyMessage(
                ref.watch(requestLimitProvider),
              ),
            );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.paddingOf(context).bottom + 16,
          ),
          itemCount: requests.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _RequestTile(
            key: ValueKey(requests[i].id),
            request: requests[i],
            incoming: _incoming,
          ),
        ),
      ),
    );
  }
}

class _RequestTile extends ConsumerStatefulWidget {
  const _RequestTile({
    super.key,
    required this.request,
    required this.incoming,
  });

  final FlamingoRequest request;
  final bool incoming;

  @override
  ConsumerState<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends ConsumerState<_RequestTile> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accept(Profile? other) async {
    final t = context.l10n;
    final ok = await confirm(
      context,
      icon: Icons.favorite_border_rounded,
      title: t.requestsAcceptTitle(other?.displayName ?? t.someone),
      message: t.requestsAcceptMessage,
      action: t.requestsAcceptAction,
    );
    if (!ok) return;
    await _run(
      () => ref.read(requestsRepositoryProvider).accept(widget.request.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final r = widget.request;
    final otherId = widget.incoming ? r.senderId : r.receiverId;
    final other = ref.watch(profileByIdProvider(otherId)).value;
    final repo = ref.read(requestsRepositoryProvider);

    return GestureDetector(
      onTap: other == null ? null : () => showProfileSheet(context, other),
      child: Glass(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Avatar(other, radius: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          other == null
                              ? '…'
                              : '${other.displayName}, ${other.age}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (other?.verified ?? false) ...[
                        const SizedBox(width: 6),
                        const VerifiedBadge(size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  CountdownPill(until: r.expiresAt, label: t.expiresIn),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (widget.incoming) ...[
              FlamIconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: t.requestsDecline,
                size: 46,
                onPressed: _busy ? null : () => _run(() => repo.decline(r.id)),
              ),
              const SizedBox(width: 8),
              FlamIconButton(
                icon: const Icon(Icons.favorite_rounded),
                tooltip: t.requestsAccept,
                variant: FlamVariant.primary,
                size: 52,
                onPressed: _busy ? null : () => _accept(other),
              ),
            ] else
              FlamButton(
                label: t.actionCancel,
                variant: FlamVariant.glass,
                size: FlamSize.small,
                loading: _busy,
                onPressed: () => _run(() => repo.cancel(r.id)),
              ),
          ],
        ),
      ),
    );
  }
}

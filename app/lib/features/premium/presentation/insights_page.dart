import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/insights.dart';
import '../data/premium.dart';

String formatDuration(AppLocalizations t, Duration d) {
  if (d.inHours < 1) return t.durMinutes(d.inMinutes);
  if (d.inDays < 1) return t.durHours(d.inHours);
  return t.durDays(d.inDays);
}

String endReasonLabel(AppLocalizations t, EndReason r) => switch (r) {
  EndReason.noChemistry => t.endNoChemistry,
  EndReason.differentGoals => t.endDifferentGoals,
  EndReason.distance => t.endDistance,
  EndReason.communication => t.endCommunication,
  EndReason.metSomeone => t.endMetSomeone,
  EndReason.disrespect => t.endDisrespect,
  EndReason.other => t.endOther,
};

/// Estadísticas premium: tiempo en la app, conexiones y parejas.
class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final premium = ref.watch(isPremiumProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.insightsTitle)),
      body: !premium
          ? EmptyState(
              icon: Icons.insights_rounded,
              title: t.premiumTitle,
              message: t.insightsLocked,
            )
          : ref
                .watch(insightsProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: t.insightsTitle,
                    message: describeError(context, e),
                  ),
                  data: (data) => _Body(data: data),
                ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data});

  final Insights data;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final d = data;
    final accepted = d.sentByStatus['accepted'] ?? 0;
    final resolvedSent =
        accepted +
        (d.sentByStatus['declined'] ?? 0) +
        (d.sentByStatus['expired'] ?? 0);
    final dateFmt = DateFormat.yMMMd(context.localeTag);
    const gap = SizedBox(height: 26);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            SettingsGroup(
              title: t.insightsTime,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _Stat(
                            label: t.insightsToday,
                            value: formatDuration(
                              t,
                              Duration(seconds: d.secondsToday),
                            ),
                          ),
                          _Stat(
                            label: t.insights7d,
                            value: formatDuration(
                              t,
                              Duration(seconds: d.seconds7d),
                            ),
                          ),
                          _Stat(
                            label: t.insights30d,
                            value: formatDuration(
                              t,
                              Duration(seconds: d.seconds30d),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _Bars(values: d.usage14d),
                    ],
                  ),
                ),
              ],
            ),
            gap,
            SettingsGroup(
              title: t.insightsConnections,
              footer: resolvedSent == 0
                  ? null
                  : t.insightsAcceptRate(
                      (accepted * 100 / resolvedSent).round(),
                    ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _Stat(label: t.insightsSent, value: '${d.sent}'),
                          _Stat(
                            label: t.insightsReceived,
                            value: '${d.received}',
                          ),
                          _Stat(label: t.insightsAccepted, value: '$accepted'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _Stat(
                            label: t.insightsDeclined,
                            value: '${d.sentByStatus['declined'] ?? 0}',
                            small: true,
                          ),
                          _Stat(
                            label: t.insightsExpired,
                            value: '${d.sentByStatus['expired'] ?? 0}',
                            small: true,
                          ),
                          _Stat(
                            label: t.insightsYouAccepted,
                            value: '${d.receivedByStatus['accepted'] ?? 0}',
                            small: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gap,
            SettingsGroup(
              title: t.insightsCouples,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _Stat(
                        label: t.insightsCouples,
                        value: '${d.couples.length}',
                      ),
                      _Stat(
                        label: t.insightsAverage,
                        value: d.averageCouple == null
                            ? '—'
                            : formatDuration(t, d.averageCouple!),
                      ),
                      _Stat(
                        label: t.insightsLongest,
                        value: d.longestCouple == null
                            ? '—'
                            : formatDuration(t, d.longestCouple!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (d.reasons.isNotEmpty) ...[
              gap,
              SettingsGroup(
                title: t.insightsWhyEnded,
                children: [
                  for (final MapEntry(key: reason, value: n)
                      in d.reasons.entries)
                    _Line(title: endReasonLabel(t, reason), value: '$n'),
                ],
              ),
            ],
            gap,
            SettingsGroup(
              title: t.insightsHistory,
              children: d.couples.isEmpty
                  ? [_Line(title: t.insightsEmptyCouples)]
                  : [
                      for (final c in d.couples)
                        _Line(
                          title: c.partner ?? t.someone,
                          subtitle: [
                            '${dateFmt.format(c.started.toLocal())} – '
                                '${c.ended == null ? t.insightsOngoing : dateFmt.format(c.ended!.toLocal())}',
                            if (c.reason case final r?) endReasonLabel(t, r),
                          ].join(' · '),
                          value: formatDuration(t, c.length),
                        ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.small = false});

  final String label;
  final String value;
  final bool small;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: small ? 18 : 24,
            fontWeight: FontWeight.w800,
            color: small ? FlamColors.text : FlamColors.pink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: FlamColors.textMuted),
        ),
      ],
    ),
  );
}

/// Barras de los últimos 14 días (la última es hoy).
class _Bars extends StatelessWidget {
  const _Bars({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final top = values.fold(1, (a, b) => a > b ? a : b);
    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, v) in values.indexed)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FractionallySizedBox(
                  heightFactor: (v / top).clamp(0.04, 1.0),
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: i == values.length - 1
                          ? FlamColors.pink
                          : FlamColors.pink.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
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

class _Line extends StatelessWidget {
  const _Line({required this.title, this.subtitle, this.value});

  final String title;
  final String? subtitle;
  final String? value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 13, color: FlamColors.textMuted),
                ),
            ],
          ),
        ),
        if (value != null)
          Text(
            value!,
            style: TextStyle(
              color: FlamColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    ),
  );
}

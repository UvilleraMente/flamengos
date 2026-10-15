import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

/// Por qué terminó una pareja. Debe coincidir con match_feedback en el SQL.
enum EndReason {
  noChemistry('no_chemistry'),
  differentGoals('different_goals'),
  distance('distance'),
  communication('communication'),
  metSomeone('met_someone'),
  disrespect('disrespect'),
  other('other');

  const EndReason(this.dbValue);
  final String dbValue;

  static EndReason? parse(Object? v) =>
      values.where((r) => r.dbValue == v).firstOrNull;
}

class PastCouple {
  PastCouple({
    required this.started,
    required this.ended,
    required this.partner,
    required this.reason,
  });

  factory PastCouple.fromJson(Map<String, dynamic> j) => PastCouple(
    started: DateTime.parse(j['started'] as String),
    ended: j['ended'] == null ? null : DateTime.parse(j['ended'] as String),
    partner: j['partner'] as String?,
    reason: EndReason.parse(j['reason']),
  );

  final DateTime started;

  /// null = sigue abierta.
  final DateTime? ended;

  /// null = la cuenta ya no existe.
  final String? partner;
  final EndReason? reason;

  Duration get length => (ended ?? DateTime.now()).difference(started);
}

/// Estadísticas premium (my_insights en el SQL).
class Insights {
  Insights({
    required this.secondsToday,
    required this.seconds7d,
    required this.seconds30d,
    required this.usage14d,
    required this.sent,
    required this.received,
    required this.sentByStatus,
    required this.receivedByStatus,
    required this.couples,
  });

  factory Insights.fromJson(Map<String, dynamic> j) {
    Map<String, int> counts(Object? m) => {
      for (final e in (m as Map? ?? const {}).entries)
        e.key as String: (e.value as num).toInt(),
    };
    return Insights(
      secondsToday: (j['seconds_today'] as num).toInt(),
      seconds7d: (j['seconds_7d'] as num).toInt(),
      seconds30d: (j['seconds_30d'] as num).toInt(),
      usage14d: [
        for (final d in j['usage_14d'] as List)
          ((d as Map)['seconds'] as num).toInt(),
      ],
      sent: (j['sent'] as num).toInt(),
      received: (j['received'] as num).toInt(),
      sentByStatus: counts(j['sent_by_status']),
      receivedByStatus: counts(j['received_by_status']),
      couples: [
        for (final c in j['couples'] as List)
          PastCouple.fromJson(c as Map<String, dynamic>),
      ],
    );
  }

  final int secondsToday;
  final int seconds7d;
  final int seconds30d;

  /// Segundos por día, del más antiguo a hoy.
  final List<int> usage14d;
  final int sent;
  final int received;
  final Map<String, int> sentByStatus;
  final Map<String, int> receivedByStatus;
  final List<PastCouple> couples;

  List<PastCouple> get ended => couples.where((c) => c.ended != null).toList();

  Duration? get averageCouple {
    final done = ended;
    if (done.isEmpty) return null;
    final total = done.fold(Duration.zero, (sum, c) => sum + c.length);
    return total ~/ done.length;
  }

  Duration? get longestCouple => couples.isEmpty
      ? null
      : couples.map((c) => c.length).reduce((a, b) => a > b ? a : b);

  Map<EndReason, int> get reasons {
    final out = <EndReason, int>{};
    for (final c in couples) {
      if (c.reason case final r?) out[r] = (out[r] ?? 0) + 1;
    }
    return out;
  }
}

final insightsProvider = FutureProvider.autoDispose<Insights>((ref) async {
  final data = await ref.watch(supabaseProvider).rpc('my_insights');
  return Insights.fromJson(data as Map<String, dynamic>);
});

Future<void> submitMatchFeedback(
  SupabaseClient db,
  String matchId,
  EndReason reason,
) => db.rpc(
  'submit_match_feedback',
  params: {'p_match': matchId, 'p_reason': reason.dbValue},
);

/// Suma el tiempo que la app está abierta y en primer plano (un aviso por
/// minuto al servidor). Vive mientras HomeShell lo escuche.
final usageTrackerProvider = Provider.autoDispose<void>((ref) {
  final db = ref.watch(supabaseProvider);
  var visible = true;
  final timer = Timer.periodic(const Duration(minutes: 1), (_) {
    if (!visible) return;
    db.rpc('track_usage', params: {'p_seconds': 60}).ignore();
  });
  final lifecycle = AppLifecycleListener(
    onShow: () => visible = true,
    onHide: () => visible = false,
  );
  ref.onDispose(() {
    timer.cancel();
    lifecycle.dispose();
  });
});

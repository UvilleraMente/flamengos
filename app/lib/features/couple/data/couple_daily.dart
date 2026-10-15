import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';

/// Lo del día de la pareja: pregunta, respuestas y racha (couple_daily en SQL).
class CoupleDaily {
  CoupleDaily({
    required this.question,
    required this.myAnswer,
    required this.partnerAnswered,
    required this.partnerAnswer,
    required this.streak,
    required this.todayActive,
  });

  factory CoupleDaily.fromJson(Map<String, dynamic> j) => CoupleDaily(
    question: (j['question'] as num).toInt(),
    myAnswer: j['my_answer'] as String?,
    partnerAnswered: j['partner_answered'] as bool? ?? false,
    partnerAnswer: j['partner_answer'] as String?,
    streak: (j['streak'] as num?)?.toInt() ?? 0,
    todayActive: j['today_active'] as bool? ?? false,
  );

  /// Índice de la pregunta de hoy (igual para los dos).
  final int question;
  final String? myAnswer;
  final bool partnerAnswered;

  /// Solo llega después de que yo respondo.
  final String? partnerAnswer;

  /// Días seguidos en que los dos se escribieron o respondieron.
  final int streak;

  /// Hoy ya cuenta para la racha.
  final bool todayActive;
}

final coupleDailyProvider = FutureProvider.autoDispose
    .family<CoupleDaily, String>((ref, matchId) async {
      final data = await ref.watch(supabaseProvider).rpc('couple_daily');
      return CoupleDaily.fromJson(data as Map<String, dynamic>);
    });

Future<void> answerDailyQuestion(WidgetRef ref, String answer) => ref
    .read(supabaseProvider)
    .rpc('answer_daily_question', params: {'p_answer': answer});

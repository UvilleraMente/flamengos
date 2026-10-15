// Preguntas del día para parejas (los textos están en lib/l10n/app_*.arb).
import '../../../core/l10n/l10n.dart';

/// Cantidad de preguntas. Debe coincidir con cfg_daily_questions() en el SQL.
const dailyQuestionCount = 30;

String dailyQuestion(AppLocalizations t, int index) =>
    switch (index % dailyQuestionCount) {
      0 => t.dailyQuestion0,
      1 => t.dailyQuestion1,
      2 => t.dailyQuestion2,
      3 => t.dailyQuestion3,
      4 => t.dailyQuestion4,
      5 => t.dailyQuestion5,
      6 => t.dailyQuestion6,
      7 => t.dailyQuestion7,
      8 => t.dailyQuestion8,
      9 => t.dailyQuestion9,
      10 => t.dailyQuestion10,
      11 => t.dailyQuestion11,
      12 => t.dailyQuestion12,
      13 => t.dailyQuestion13,
      14 => t.dailyQuestion14,
      15 => t.dailyQuestion15,
      16 => t.dailyQuestion16,
      17 => t.dailyQuestion17,
      18 => t.dailyQuestion18,
      19 => t.dailyQuestion19,
      20 => t.dailyQuestion20,
      21 => t.dailyQuestion21,
      22 => t.dailyQuestion22,
      23 => t.dailyQuestion23,
      24 => t.dailyQuestion24,
      25 => t.dailyQuestion25,
      26 => t.dailyQuestion26,
      27 => t.dailyQuestion27,
      28 => t.dailyQuestion28,
      29 => t.dailyQuestion29,
      _ => t.dailyQuestion0,
    };

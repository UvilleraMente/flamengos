import 'package:flamengos/features/couple/data/couple_daily.dart';
import 'package:flamengos/features/couple/presentation/daily_questions.dart';
import 'package:flamengos/features/notifications/domain/app_notification.dart';
import 'package:flamengos/l10n/app_localizations_es.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pregunta del día: la respuesta del otro solo llega tras responder', () {
    final d = CoupleDaily.fromJson({
      'question': 4,
      'my_answer': null,
      'partner_answered': true,
      'partner_answer': null,
      'streak': 3,
      'today_active': false,
    });
    expect(d.partnerAnswered, isTrue);
    expect(d.partnerAnswer, isNull);
    expect(d.streak, 3);
    expect(d.todayActive, isFalse);
  });

  test('las preguntas dan la vuelta y no se repiten en el ciclo', () {
    final t = AppLocalizationsEs();
    final all = {
      for (var i = 0; i < dailyQuestionCount; i++) dailyQuestion(t, i),
    };
    expect(all, hasLength(dailyQuestionCount));
    expect(dailyQuestion(t, dailyQuestionCount), dailyQuestion(t, 0));
  });

  test('notificación "nuevos cerca" lee la cantidad', () {
    final n = AppNotification.tryParse({
      'id': 1,
      'type': 'new_nearby',
      'actor_id': null,
      'created_at': '2026-10-15T23:00:00Z',
      'read_at': null,
      'data': {'count': 4},
    })!;
    expect(n.type, NotificationType.newNearby);
    expect(n.data['count'], 4);
  });
}

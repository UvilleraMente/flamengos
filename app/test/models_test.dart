import 'package:flamengos/features/couple/domain/couple.dart';
import 'package:flamengos/features/discover/domain/search_filters.dart';
import 'package:flamengos/features/profile/domain/profile.dart';
import 'package:flamengos/features/requests/domain/flamingo_request.dart';
import 'package:flamengos/l10n/app_localizations_en.dart';
import 'package:flamengos/l10n/app_localizations_es.dart';
import 'package:flamengos/shared/widgets/countdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('ageOn', () {
    test('cuenta el año solo después del cumpleaños', () {
      final birth = DateTime(2000, 6, 15);
      expect(ageOn(birth, DateTime(2026, 6, 14)), 25);
      expect(ageOn(birth, DateTime(2026, 6, 15)), 26);
    });
  });

  group('Profile.fromJson', () {
    final base = {
      'id': 'p1',
      'display_name': 'Ana',
      'birthdate': '2000-01-01',
      'gender': 'woman',
      'interested_in': ['man'],
    };

    test('ubicación, filtros y preguntas', () {
      final p = Profile.fromJson({
        ...base,
        'lat': 18.48,
        'lng': -69.94,
        'age_min': 25,
        'age_max': 35,
        'max_distance_km': null,
        'search_lat': 40.42,
        'search_lng': -3.70,
        'search_label': 'Madrid',
        'prompts': [
          {'q': 'idealDate', 'a': 'Playa y empanadas'},
          {'q': 'pregunta_del_futuro', 'a': 'se ignora'},
        ],
        'verified': true,
        'distance_km': 3.4,
      });
      expect(p.location, const LatLng(18.48, -69.94));
      expect(p.maxDistanceKm, isNull); // null explícito = sin límite
      expect(p.searchCenter, const LatLng(40.42, -3.70));
      expect(p.prompts.single.key, PromptKey.idealDate);
      expect(p.verified, isTrue);
      expect(p.distanceKm, 3.4);
    });

    test('sin columnas nuevas usa valores por defecto', () {
      final p = Profile.fromJson(base);
      expect(p.location, isNull);
      expect(p.maxDistanceKm, 50);
      expect(p.prompts, isEmpty);
    });
  });

  test('SearchFilters.toJson borra la etiqueta si no hay zona', () {
    const f = SearchFilters(
      ageMin: 20,
      ageMax: 30,
      maxDistanceKm: 25,
      centerLabel: 'vieja',
    );
    expect(f.toJson(), {
      'age_min': 20,
      'age_max': 30,
      'max_distance_km': 25,
      'search_lat': null,
      'search_lng': null,
      'search_label': null,
    });
  });

  group('FlamingoRequest.isLive', () {
    FlamingoRequest build(String status, Duration fromNow) =>
        FlamingoRequest.fromJson({
          'id': 'r1',
          'sender_id': 'a',
          'receiver_id': 'b',
          'status': status,
          'created_at': DateTime.now().toIso8601String(),
          'expires_at': DateTime.now().add(fromNow).toIso8601String(),
        });

    test('pendiente y vigente', () {
      expect(build('pending', const Duration(hours: 1)).isLive, isTrue);
    });
    test('pendiente pero vencida', () {
      expect(build('pending', const Duration(minutes: -1)).isLive, isFalse);
    });
    test('anulada', () {
      expect(build('voided', const Duration(hours: 1)).isLive, isFalse);
    });
  });

  test('Couple.partnerOf', () {
    final c = Couple.fromJson({
      'id': 'm1',
      'user_a': 'a',
      'user_b': 'b',
      'status': 'dissolving',
      'created_at': '2026-10-14T10:00:00Z',
      'dissolution_requested_by': 'a',
      'dissolve_at': '2026-10-14T22:00:00Z',
    });
    expect(c.partnerOf('a'), 'b');
    expect(c.partnerOf('b'), 'a');
    expect(c.status, CoupleStatus.dissolving);
  });

  group('formatRemaining', () {
    test('español', () {
      final t = AppLocalizationsEs();
      expect(formatRemaining(const Duration(seconds: 30), t), 'menos de 1 min');
      expect(formatRemaining(const Duration(minutes: 42), t), '42 min');
      expect(
        formatRemaining(const Duration(hours: 47, minutes: 5), t),
        '47 h 5 min',
      );
    });
    test('inglés', () {
      final t = AppLocalizationsEn();
      expect(
        formatRemaining(const Duration(seconds: 30), t),
        'less than 1 min',
      );
    });
  });

  test('plurales de "juntos desde"', () {
    final es = AppLocalizationsEs();
    final en = AppLocalizationsEn();
    expect(es.coupleTogetherSince(0), 'Juntos desde hoy');
    expect(es.coupleTogetherSince(5), 'Juntos hace 5 días');
    expect(en.coupleTogetherSince(1), 'Together since yesterday');
  });

  group('ChatMessage responder y editar', () {
    final sent = DateTime.utc(2026, 10, 15, 12);
    ChatMessage parse(Map<String, dynamic> extra) => ChatMessage.fromJson({
      'id': 7,
      'sender_id': 'me',
      'body': 'hola',
      'created_at': sent.toIso8601String(),
      ...extra,
    });

    test('lee la respuesta y la edición', () {
      final m = parse({'reply_to': 3, 'edited_at': sent.toIso8601String()});
      expect(m.replyTo, 3);
      expect(m.edited, isTrue);
      expect(parse({}).edited, isFalse);
    });

    test('solo se edita durante 1 minuto', () {
      final m = parse({});
      expect(m.canEdit(sent.add(const Duration(seconds: 59))), isTrue);
      expect(m.canEdit(sent.add(const Duration(minutes: 1))), isFalse);
    });
  });
}

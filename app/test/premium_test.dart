import 'package:flamengos/features/profile/domain/profile.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _profile(Map<String, dynamic> extra) => Profile.fromJson({
  'id': 'u1',
  'display_name': 'Ana',
  'birthdate': '1995-04-02',
  'gender': 'woman',
  'interested_in': ['man'],
  ...extra,
});

void main() {
  test('fundador: premium para siempre', () {
    expect(_profile({'founder': true}).isPremium, isTrue);
  });

  test('prueba vigente o vencida', () {
    final later = DateTime.now().add(const Duration(days: 2));
    final earlier = DateTime.now().subtract(const Duration(minutes: 1));
    expect(
      _profile({'premium_until': later.toIso8601String()}).isPremium,
      isTrue,
    );
    expect(
      _profile({'premium_until': earlier.toIso8601String()}).isPremium,
      isFalse,
    );
  });

  test('perfil ajeno (sin columnas premium) no es premium', () {
    final p = _profile({});
    expect(p.isPremium, isFalse);
    expect(p.incognito, isFalse);
  });
}

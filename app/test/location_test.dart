import 'package:flamengos/features/location/data/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _feature(List<(String, String)> levels) => {
  'id': levels.first.$1,
  'text': levels.first.$2,
  'context': [
    for (final (id, text) in levels.skip(1)) {'id': id, 'text': text},
  ],
};

void main() {
  group('LocationService.cityFrom (respuestas reales de MapTiler)', () {
    test('Madrid: usa el municipio, no el barrio', () {
      final f = _feature([
        ('address.17163817', 'CALLE GRAN VIA'),
        ('place.615426', 'Chueca'),
        ('municipality.126341', 'Madrid'),
        ('county.9878', 'Comunidad de Madrid'),
      ]);
      expect(LocationService.cityFrom(f), 'Madrid');
    });

    test('Santo Domingo: sin municipio, usa el condado', () {
      final f = _feature([
        ('address.8840933', 'Calle 10 - Mutualismo'),
        ('place.750907', 'Ensanche Espaillat'),
        ('county.10891', 'Santo Domingo'),
        ('region.50', 'Distrito Nacional'),
      ]);
      expect(LocationService.cityFrom(f), 'Santo Domingo');
    });

    test('sin niveles conocidos devuelve null', () {
      expect(LocationService.cityFrom(_feature([('place.1', 'X')])), isNull);
    });
  });
}

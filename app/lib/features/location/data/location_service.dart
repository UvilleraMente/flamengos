import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../app/env.dart';
import '../domain/place.dart';

final locationServiceProvider = Provider((ref) => LocationService());

enum LocationProblem { serviceDisabled, denied, deniedForever }

class LocationException implements Exception {
  const LocationException(this.problem);
  final LocationProblem problem;
}

/// GPS del dispositivo + búsqueda de lugares con MapTiler Geocoding.
class LocationService {
  LocationService({http.Client? client}) : _http = client ?? http.Client();

  final http.Client _http;

  static Uri _geocoding(String query, Map<String, String> params) => Uri.https(
    'api.maptiler.com',
    '/geocoding/${Uri.encodeComponent(query)}.json',
    {'key': Env.mapTilerKey, ...params},
  );

  /// Ubicación actual con precisión baja (suficiente y más rápida).
  Future<LatLng> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationProblem.serviceDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationProblem.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationProblem.deniedForever);
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  /// Busca ciudades, barrios o lugares por nombre. [near] prioriza resultados
  /// cercanos a ese punto.
  Future<List<Place>> search(
    String query, {
    required String language,
    LatLng? near,
  }) async {
    if (query.trim().length < 2) return const [];
    final res = await _http.get(
      _geocoding(query.trim(), {
        'language': language,
        'limit': '6',
        'autocomplete': 'true',
        if (near != null) 'proximity': '${near.longitude},${near.latitude}',
      }),
    );
    if (res.statusCode != 200) return const [];
    return [
      for (final f in (jsonDecode(res.body) as Map)['features'] as List)
        if (_point(f) case final point?)
          Place(label: f['place_name'] as String, point: point),
    ];
  }

  /// Nombre corto de la ciudad ("Santo Domingo", "Madrid"…) para un punto.
  Future<String?> placeName(LatLng point, {required String language}) async {
    try {
      final res = await _http.get(
        _geocoding('${point.longitude},${point.latitude}', {
          'language': language,
          'limit': '1',
        }),
      );
      if (res.statusCode != 200) return null;
      final features = (jsonDecode(res.body) as Map)['features'] as List;
      if (features.isEmpty) return null;
      return cityFrom(features.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// De la jerarquía de MapTiler (dirección → barrio → municipio → condado →
  /// región…) elige el primer nivel que suena a "ciudad".
  static String? cityFrom(Map<String, dynamic> feature) {
    final levels = [
      feature,
      ...(feature['context'] as List? ?? const []).cast<Map<String, dynamic>>(),
    ];
    for (final kind in const ['municipality', 'county', 'region']) {
      for (final level in levels) {
        final id = level['id'] as String? ?? '';
        if (id.startsWith('$kind.')) return level['text'] as String?;
      }
    }
    return null;
  }

  static LatLng? _point(dynamic feature) {
    final center = feature['center'];
    if (center is! List || center.length < 2) return null;
    return LatLng((center[1] as num).toDouble(), (center[0] as num).toDouble());
  }
}

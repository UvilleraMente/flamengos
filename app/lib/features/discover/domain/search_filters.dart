import 'package:latlong2/latlong.dart';

import '../../profile/domain/profile.dart';

/// Qué busca el flamengo: rango de edad, distancia y zona.
class SearchFilters {
  const SearchFilters({
    required this.ageMin,
    required this.ageMax,
    required this.maxDistanceKm,
    this.center,
    this.centerLabel,
  });

  factory SearchFilters.of(Profile p) => SearchFilters(
    ageMin: p.ageMin,
    ageMax: p.ageMax,
    maxDistanceKm: p.maxDistanceKm,
    center: p.searchCenter,
    centerLabel: p.searchLabel,
  );

  static const minAge = 18;
  static const maxAge = 99;

  /// Pasos del control de distancia; null = sin límite.
  static const distanceSteps = <int?>[5, 10, 25, 50, 100, 250, 500, null];

  final int ageMin;
  final int ageMax;
  final int? maxDistanceKm;

  /// Zona personalizada; null = alrededor de mi ubicación.
  final LatLng? center;
  final String? centerLabel;

  SearchFilters copyWith({
    int? ageMin,
    int? ageMax,
    int? Function()? maxDistanceKm,
    LatLng? Function()? center,
    String? Function()? centerLabel,
  }) => SearchFilters(
    ageMin: ageMin ?? this.ageMin,
    ageMax: ageMax ?? this.ageMax,
    maxDistanceKm: maxDistanceKm != null ? maxDistanceKm() : this.maxDistanceKm,
    center: center != null ? center() : this.center,
    centerLabel: centerLabel != null ? centerLabel() : this.centerLabel,
  );

  Map<String, dynamic> toJson() => {
    'age_min': ageMin,
    'age_max': ageMax,
    'max_distance_km': maxDistanceKm,
    'search_lat': center?.latitude,
    'search_lng': center?.longitude,
    'search_label': center == null ? null : centerLabel,
  };
}

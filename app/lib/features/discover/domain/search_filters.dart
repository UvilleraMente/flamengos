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
    this.mustTags = const {},
    this.interestedIn = const {},
  });

  factory SearchFilters.of(Profile p) => SearchFilters(
    ageMin: p.ageMin,
    ageMax: p.ageMax,
    maxDistanceKm: p.maxDistanceKm,
    center: p.searchCenter,
    centerLabel: p.searchLabel,
    mustTags: p.mustTags,
    interestedIn: p.interestedIn,
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

  /// Etiquetas que la otra persona debe tener.
  final Set<ProfileTag> mustTags;

  /// A quién quiero ver (el mismo campo que "Busco" en el perfil).
  final Set<Gender> interestedIn;

  SearchFilters copyWith({
    int? ageMin,
    int? ageMax,
    int? Function()? maxDistanceKm,
    LatLng? Function()? center,
    String? Function()? centerLabel,
    Set<ProfileTag>? mustTags,
    Set<Gender>? interestedIn,
  }) => SearchFilters(
    ageMin: ageMin ?? this.ageMin,
    ageMax: ageMax ?? this.ageMax,
    maxDistanceKm: maxDistanceKm != null ? maxDistanceKm() : this.maxDistanceKm,
    center: center != null ? center() : this.center,
    centerLabel: centerLabel != null ? centerLabel() : this.centerLabel,
    mustTags: mustTags ?? this.mustTags,
    interestedIn: interestedIn ?? this.interestedIn,
  );

  Map<String, dynamic> toJson() => {
    'age_min': ageMin,
    'age_max': ageMax,
    'max_distance_km': maxDistanceKm,
    'search_lat': center?.latitude,
    'search_lng': center?.longitude,
    'search_label': center == null ? null : centerLabel,
    'must_tags': [for (final tag in mustTags) tag.dbValue],
    // Vacío no se guarda (el perfil exige al menos uno).
    if (interestedIn.isNotEmpty)
      'interested_in': [for (final g in interestedIn) g.name],
  };
}

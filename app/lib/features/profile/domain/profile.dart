import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum Gender { woman, man, nonbinary }

/// Preguntas de perfil disponibles (el texto de cada una está en l10n).
enum PromptKey {
  idealDate,
  greenFlag,
  song,
  weekend,
  unpopularOpinion,
  lookingFor,
}

/// Etiquetas de perfil. Deben coincidir con cfg_tags() en el SQL.
enum ProfileTag {
  christian,
  catholic,
  spiritual,
  worker,
  student,
  entrepreneur,
  sports,
  gym,
  gamer,
  reader,
  traveler,
  foodie,
  music,
  dance,
  pets,
  nature,
  beach,
  homebody,
  party,
  family,
  wantsKids('wants_kids'),
  noSmoking('no_smoking'),
  noDrinking('no_drinking'),
  serious;

  const ProfileTag([this._db]);

  final String? _db;
  String get dbValue => _db ?? name;

  static const maxPerProfile = 5;
  static const maxMustHave = 2;

  static Set<ProfileTag> parse(Object? list) => {
    for (final v in list as List? ?? const [])
      ?values.where((t) => t.dbValue == v).firstOrNull,
  };
}

class ProfilePrompt {
  const ProfilePrompt(this.key, this.answer);

  /// Ignora preguntas desconocidas (p. ej. de una versión más nueva de la app).
  static ProfilePrompt? tryParse(Map<String, dynamic> json) {
    final key = PromptKey.values.asNameMap()[json['q']];
    final answer = json['a'];
    return key == null || answer is! String ? null : ProfilePrompt(key, answer);
  }

  final PromptKey key;
  final String answer;

  Map<String, dynamic> toJson() => {'q': key.name, 'a': answer};
}

/// Las cuentas de prueba usan fotos externas (URL completa).
String photoUrl(String path) => path.startsWith('http')
    ? path
    : Supabase.instance.client.storage.from('photos').getPublicUrl(path);

class Profile {
  Profile({
    required this.id,
    required this.displayName,
    required this.birthdate,
    required this.gender,
    required this.interestedIn,
    this.bio = '',
    this.city = '',
    this.photos = const [],
    this.prompts = const [],
    this.verified = false,
    this.currentMatchId,
    this.location,
    this.ageMin = 18,
    this.ageMax = 99,
    this.maxDistanceKm = 50,
    this.searchCenter,
    this.searchLabel,
    this.distanceKm,
    this.founder = false,
    this.premiumUntil,
    this.incognito = false,
    this.tags = const {},
    this.mustTags = const {},
    this.boostUntil,
    this.sharedTags = 0,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    LatLng? point(String lat, String lng) =>
        json[lat] == null || json[lng] == null
        ? null
        : LatLng((json[lat] as num).toDouble(), (json[lng] as num).toDouble());

    return Profile(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      birthdate: DateTime.parse(json['birthdate'] as String),
      gender: Gender.values.byName(json['gender'] as String),
      interestedIn: (json['interested_in'] as List)
          .map((g) => Gender.values.byName(g as String))
          .toSet(),
      bio: json['bio'] as String? ?? '',
      city: json['city'] as String? ?? '',
      photos: List<String>.from(json['photos'] as List? ?? const []),
      prompts: [
        for (final p in json['prompts'] as List? ?? const [])
          ?ProfilePrompt.tryParse(p as Map<String, dynamic>),
      ],
      verified: json['verified'] as bool? ?? false,
      currentMatchId: json['current_match_id'] as String?,
      location: point('lat', 'lng'),
      ageMin: json['age_min'] as int? ?? 18,
      ageMax: json['age_max'] as int? ?? 99,
      maxDistanceKm: json.containsKey('max_distance_km')
          ? json['max_distance_km'] as int?
          : 50,
      searchCenter: point('search_lat', 'search_lng'),
      searchLabel: json['search_label'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      founder: json['founder'] as bool? ?? false,
      premiumUntil: json['premium_until'] == null
          ? null
          : DateTime.parse(json['premium_until'] as String),
      incognito: json['incognito'] as bool? ?? false,
      tags: ProfileTag.parse(json['tags']),
      mustTags: ProfileTag.parse(json['must_tags']),
      boostUntil: json['boost_until'] == null
          ? null
          : DateTime.parse(json['boost_until'] as String),
      sharedTags: json['shared_tags'] as int? ?? 0,
    );
  }

  final String id;
  final String displayName;
  final DateTime birthdate;
  final Gender gender;
  final Set<Gender> interestedIn;
  final String bio;
  final String city;

  /// Rutas dentro del bucket `photos`.
  final List<String> photos;
  final List<ProfilePrompt> prompts;
  final bool verified;
  final String? currentMatchId;

  /// Ubicación aproximada (cuadrícula de ~2 km), o null si no la compartió.
  final LatLng? location;

  // Preferencias de búsqueda (solo vienen completas en el perfil propio).
  final int ageMin;
  final int ageMax;

  /// null = sin límite de distancia.
  final int? maxDistanceKm;

  /// null = buscar alrededor de [location].
  final LatLng? searchCenter;
  final String? searchLabel;

  /// Distancia al centro de búsqueda (solo en resultados de descubrimiento).
  final double? distanceKm;

  /// Una de las primeras 100 cuentas: premium para siempre.
  final bool founder;

  /// Fin de la prueba o suscripción premium (null si no tiene).
  final DateTime? premiumUntil;

  /// Oculto en descubrir (solo cuenta si es premium).
  final bool incognito;

  final Set<ProfileTag> tags;

  /// Etiquetas que la otra persona debe tener (filtro de búsqueda).
  final Set<ProfileTag> mustTags;

  /// Impulso en Descubrir tras varios rechazos (solo en el perfil propio).
  final DateTime? boostUntil;

  /// Etiquetas en común conmigo (solo en resultados de descubrimiento).
  final int sharedTags;

  bool get boosted => boostUntil?.isAfter(DateTime.now()) ?? false;

  bool get isPremium =>
      founder || (premiumUntil?.isAfter(DateTime.now()) ?? false);

  bool get isPaired => currentMatchId != null;

  List<String> get photoUrls => photos.map(photoUrl).toList();

  String? get mainPhotoUrl => photos.isEmpty ? null : photoUrl(photos.first);

  int get age => ageOn(birthdate, DateTime.now());
}

int ageOn(DateTime birthdate, DateTime today) {
  var age = today.year - birthdate.year;
  if (today.month < birthdate.month ||
      (today.month == birthdate.month && today.day < birthdate.day)) {
    age--;
  }
  return age;
}

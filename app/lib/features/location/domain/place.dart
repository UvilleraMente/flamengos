import 'package:latlong2/latlong.dart';

/// Un lugar con nombre (resultado de búsqueda o de geocodificación inversa).
class Place {
  const Place({required this.label, required this.point});

  final String label;
  final LatLng point;
}

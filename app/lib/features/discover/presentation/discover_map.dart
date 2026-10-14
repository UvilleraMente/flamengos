import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../location/presentation/flam_map.dart';
import '../../profile/domain/profile.dart';

/// Mapa con los flamengos encontrados (posiciones aproximadas) y el radio
/// de búsqueda.
class DiscoverMap extends StatelessWidget {
  const DiscoverMap({
    super.key,
    required this.profiles,
    required this.center,
    required this.radiusKm,
    required this.onSelect,
  });

  final List<Profile> profiles;

  /// Centro de búsqueda (zona elegida o mi ubicación); null si no hay.
  final LatLng? center;
  final int? radiusKm;
  final ValueChanged<Profile> onSelect;

  @override
  Widget build(BuildContext context) {
    final located = profiles.where((p) => p.location != null).toList();
    final mapCenter =
        center ?? located.firstOrNull?.location ?? defaultMapCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(FlamRadius.xl),
      child: Stack(
        children: [
          FlamMap(
            center: mapCenter,
            zoom: center == null ? 6 : zoomForRadius(radiusKm),
            layers: [
              if (center != null && radiusKm != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: center!,
                      radius: radiusKm! * 1000,
                      useRadiusInMeter: true,
                      color: FlamColors.pink.withValues(alpha: 0.10),
                      borderColor: FlamColors.pink.withValues(alpha: 0.7),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (center != null)
                    Marker(
                      point: center!,
                      width: 18,
                      height: 18,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: FlamColors.coral,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  for (final p in located)
                    Marker(
                      point: _jitter(p),
                      width: 56,
                      height: 56,
                      child: GestureDetector(
                        onTap: () => onSelect(p),
                        child: Avatar(p, radius: 22),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Center(
              child: GlassPill(
                leading: const Icon(Icons.shield_moon_outlined, size: 15),
                child: Text(context.l10n.mapPrivacyNote),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Las ubicaciones vienen en cuadrícula de ~2 km; varias personas pueden
  /// caer en el mismo punto. Se separan un poco, siempre igual por persona.
  static LatLng _jitter(Profile p) {
    final h = p.id.hashCode;
    final dx = ((h & 0xFF) / 255 - 0.5) * 0.012;
    final dy = (((h >> 8) & 0xFF) / 255 - 0.5) * 0.012;
    return LatLng(p.location!.latitude + dy, p.location!.longitude + dx);
  }
}

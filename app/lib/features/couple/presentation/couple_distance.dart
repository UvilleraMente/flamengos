import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../location/presentation/flam_map.dart';
import '../../profile/domain/profile.dart';

/// Distancia aproximada entre los dos (km), o null si alguno no compartió
/// su ubicación.
double? coupleDistanceKm(Profile me, Profile? partner) {
  final a = me.location, b = partner?.location;
  if (a == null || b == null) return null;
  return const Distance().as(LengthUnit.Kilometer, a, b);
}

/// Pastilla "📍 a 5 km" que abre el mapa de la pareja.
class CoupleDistancePill extends StatelessWidget {
  const CoupleDistancePill({
    super.key,
    required this.me,
    required this.partner,
  });

  final Profile me;
  final Profile? partner;

  @override
  Widget build(BuildContext context) {
    final km = coupleDistanceKm(me, partner);
    if (km == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => showCoupleMap(context, me, partner!),
      child: GlassPill(
        leading: const Icon(Icons.place_rounded, size: 14),
        child: Text(context.l10n.distanceAway(km.round().clamp(1, 99999))),
      ),
    );
  }
}

/// Mapa con los dos (zonas aproximadas) unidos por una línea.
void showCoupleMap(BuildContext context, Profile me, Profile partner) {
  final a = me.location!, b = partner.location!;
  final km = coupleDistanceKm(me, partner)!.round().clamp(1, 99999);
  final t = context.l10n;
  final middle = LatLng(
    (a.latitude + b.latitude) / 2,
    (a.longitude + b.longitude) / 2,
  );

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.coupleMapTitle(km),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              t.mapPrivacyNote,
              style: TextStyle(color: FlamColors.textMuted),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FlamRadius.xl),
                child: FlamMap(
                  center: middle,
                  zoom: 10,
                  // Si están en la misma zona, no acercar de más.
                  fit: a == b
                      ? null
                      : CameraFit.bounds(
                          bounds: LatLngBounds(a, b),
                          padding: const EdgeInsets.all(70),
                          maxZoom: 13,
                        ),
                  layers: [
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [a, b],
                          strokeWidth: 3,
                          color: FlamColors.pink,
                          pattern: StrokePattern.dashed(
                            segments: const [10, 8],
                          ),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        for (final (p, point) in [(me, a), (partner, b)])
                          Marker(
                            point: point,
                            width: 56,
                            height: 56,
                            child: Avatar(p, radius: 22),
                          ),
                        if (a != b)
                          Marker(
                            point: middle,
                            width: 110,
                            height: 40,
                            child: Center(
                              child: GlassPill(
                                leading: Icon(
                                  Icons.favorite_rounded,
                                  size: 14,
                                  color: FlamColors.pink,
                                ),
                                child: Text('$km km'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

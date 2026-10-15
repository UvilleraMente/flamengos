import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/env.dart';
import '../../../core/theme/tokens.dart';

/// Centro por defecto si no hay ninguna ubicación (Santo Domingo).
const defaultMapCenter = LatLng(18.4861, -69.9312);

/// Mapa base de Flamengos: MapTiler streets-v4 en versión oscura, que combina
/// con el vidrio. La atribución a MapTiler y OpenStreetMap es obligatoria.
class FlamMap extends StatelessWidget {
  const FlamMap({
    super.key,
    required this.center,
    required this.zoom,
    required this.layers,
    this.controller,
    this.onTap,
    this.fit,
  });

  final LatLng center;
  final double zoom;
  final List<Widget> layers;
  final MapController? controller;
  final void Function(LatLng point)? onTap;

  /// Si se da, encuadra estos límites en vez de usar center/zoom.
  final CameraFit? fit;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        initialCameraFit: fit,
        minZoom: 3,
        maxZoom: 16,
        backgroundColor: const Color(0xFF0E0E12),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onTap: onTap == null ? null : (_, point) => onTap!(point),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://api.maptiler.com/maps/${FlamColors.palette.mapStyle}'
              '/256/{z}/{x}/{y}{r}.png?key=${Env.mapTilerKey}',
          retinaMode: RetinaMode.isHighDensity(context),
          userAgentPackageName: 'com.flamengos.flamengos',
        ),
        ...layers,
        const RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          attributions: [
            TextSourceAttribution('© MapTiler'),
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}

/// Zoom aproximado para que un radio de [km] quepa en pantalla.
double zoomForRadius(int? km) => switch (km) {
  null => 5,
  <= 5 => 12,
  <= 10 => 11,
  <= 25 => 10,
  <= 50 => 9,
  <= 100 => 8,
  <= 250 => 7,
  _ => 6,
};

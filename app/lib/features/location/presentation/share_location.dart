import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/feedback.dart';
import '../data/location_service.dart';
import 'location_l10n.dart';

/// Pide el GPS y devuelve la ubicación + el nombre de la zona, o null si
/// no se pudo (ya muestra el motivo al usuario).
Future<({LatLng point, String? city})?> locateMe(
  BuildContext context,
  WidgetRef ref,
) async {
  final service = ref.read(locationServiceProvider);
  final t = context.l10n;
  final language = context.localeTag;
  try {
    final point = await service.currentPosition();
    final city = await service.placeName(point, language: language);
    return (point: point, city: city);
  } on LocationException catch (e) {
    if (context.mounted) showInfo(context, e.problem.message(t));
  } catch (_) {
    if (context.mounted) showInfo(context, t.locationUnavailable);
  }
  return null;
}

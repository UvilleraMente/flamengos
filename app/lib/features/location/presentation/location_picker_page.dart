import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/location_service.dart';
import '../domain/place.dart';
import 'flam_map.dart';
import 'location_l10n.dart';

/// Elige una zona en el mapa (tocando o buscando por nombre).
/// Devuelve un [Place] con `context.pop`.
class LocationPickerPage extends ConsumerStatefulWidget {
  const LocationPickerPage({super.key, this.initial});

  final LatLng? initial;

  @override
  ConsumerState<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends ConsumerState<LocationPickerPage> {
  final _map = MapController();
  final _query = TextEditingController();
  Timer? _debounce;
  List<Place> _results = const [];
  LatLng? _point;
  String? _label;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _point = widget.initial;
    if (_point != null) _resolveLabel(_point!);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  LocationService get _service => ref.read(locationServiceProvider);

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    // Esperamos a que deje de escribir para no gastar consultas de MapTiler.
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await _service.search(
        q,
        language: context.localeTag,
        near: _map.camera.center,
      );
      if (mounted) setState(() => _results = results);
    });
  }

  void _select(LatLng point, {String? label, double? zoom}) {
    setState(() {
      _point = point;
      _label = label;
      _results = const [];
    });
    _map.move(point, zoom ?? _map.camera.zoom);
    if (label == null) _resolveLabel(point);
  }

  Future<void> _resolveLabel(LatLng point) async {
    final name = await _service.placeName(point, language: context.localeTag);
    if (mounted && _point == point) setState(() => _label = name);
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      final here = await _service.currentPosition();
      _select(here, zoom: 11);
    } on LocationException catch (e) {
      if (mounted) showInfo(context, e.problem.message(context.l10n));
    } catch (_) {
      if (mounted) showInfo(context, context.l10n.locationUnavailable);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final point = _point;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(t.locationPickerTitle)),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlamMap(
              controller: _map,
              center: point ?? defaultMapCenter,
              zoom: point == null ? 5 : 10,
              onTap: _select,
              layers: [
                if (point != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 48,
                        height: 48,
                        alignment: Alignment.topCenter,
                        child: const Text('📍', style: TextStyle(fontSize: 40)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  Glass(
                    blur: true,
                    radius: FlamRadius.pill,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: TextField(
                      controller: _query,
                      onChanged: _onQueryChanged,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: t.locationSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_results.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Glass(
                      blur: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          for (final r in _results)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.place_outlined),
                              title: Text(
                                r.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                _select(
                                  r.point,
                                  label: r.label.split(',').first,
                                  zoom: 10,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FlamIconButton(
                    icon: _locating
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                    tooltip: t.locationUseMine,
                    onPressed: _locating ? null : _useMyLocation,
                  ),
                  const SizedBox(height: 12),
                  Glass(
                    blur: true,
                    radius: FlamRadius.xl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          point == null
                              ? t.locationTapHint
                              : (_label ?? t.locationSelected),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FlamButton(
                          label: t.locationUseThisArea,
                          expand: true,
                          onPressed: point == null
                              ? null
                              : () => context.pop(
                                  Place(
                                    label: _label ?? t.locationSelected,
                                    point: point,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

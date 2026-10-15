import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../location/domain/place.dart';
import '../../profile/domain/profile.dart';
import '../../profile/presentation/tag_chips.dart';
import '../data/discover_repository.dart';
import '../domain/search_filters.dart';

/// Filtros de búsqueda. Devuelve true si se guardaron cambios.
Future<bool> showFiltersSheet(BuildContext context, Profile me) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FiltersSheet(me: me),
  );
  return saved ?? false;
}

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet({required this.me});

  final Profile me;

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  late SearchFilters _f = SearchFilters.of(widget.me);
  bool _saving = false;

  int get _distanceIndex {
    final i = SearchFilters.distanceSteps.indexOf(_f.maxDistanceKm);
    return i < 0 ? 3 : i;
  }

  Future<void> _pickArea() async {
    final place = await context.push<Place>(
      Routes.pickLocation,
      extra: _f.center ?? widget.me.location,
    );
    if (place != null) {
      setState(
        () => _f = _f.copyWith(
          center: () => place.point,
          centerLabel: () => place.label,
        ),
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(discoverRepositoryProvider).saveFilters(_f);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final km = _f.maxDistanceKm;
    final customArea = _f.center != null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.filtersTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            _Label(
              t.filtersAge,
              value: t.filtersAgeRange(_f.ageMin, _f.ageMax),
            ),
            RangeSlider(
              values: RangeValues(_f.ageMin.toDouble(), _f.ageMax.toDouble()),
              min: SearchFilters.minAge.toDouble(),
              max: SearchFilters.maxAge.toDouble(),
              divisions: SearchFilters.maxAge - SearchFilters.minAge,
              onChanged: (v) => setState(
                () => _f = _f.copyWith(
                  ageMin: v.start.round(),
                  ageMax: v.end.round(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _Label(
              t.filtersDistance,
              value: km == null ? t.filtersAnyDistance : t.filtersUpToKm(km),
            ),
            Slider(
              value: _distanceIndex.toDouble(),
              max: SearchFilters.distanceSteps.length - 1,
              divisions: SearchFilters.distanceSteps.length - 1,
              onChanged: (v) => setState(
                () => _f = _f.copyWith(
                  maxDistanceKm: () => SearchFilters.distanceSteps[v.round()],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _Label(t.filtersArea),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FlamChip(
                  label: t.filtersNearMe,
                  selected: !customArea,
                  onTap: () => setState(
                    () => _f = _f.copyWith(
                      center: () => null,
                      centerLabel: () => null,
                    ),
                  ),
                ),
                FlamChip(
                  label: t.filtersOtherArea,
                  selected: customArea,
                  onTap: _pickArea,
                ),
              ],
            ),
            if (customArea) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickArea,
                child: Glass(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.travel_explore_rounded,
                        color: FlamColors.blush,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _f.centerLabel ?? t.locationSelected,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        t.actionChange,
                        style: TextStyle(color: FlamColors.blush),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (widget.me.location == null) ...[
              const SizedBox(height: 12),
              Text(
                t.filtersNeedLocation,
                style: TextStyle(color: FlamColors.textMuted),
              ),
            ],
            const SizedBox(height: 20),
            _Label(t.tagsMustTitle),
            const SizedBox(height: 4),
            Text(
              t.tagsMustHint(ProfileTag.maxMustHave),
              style: TextStyle(color: FlamColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 10),
            TagPicker(
              selected: _f.mustTags,
              max: ProfileTag.maxMustHave,
              onChanged: (v) => setState(() => _f = _f.copyWith(mustTags: v)),
            ),
            const SizedBox(height: 28),
            FlamButton(
              label: t.filtersApply,
              size: FlamSize.large,
              expand: true,
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.value});

  final String text;
  final String? value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      if (value != null)
        Text(
          value!,
          style: TextStyle(
            color: FlamColors.blush,
            fontWeight: FontWeight.w700,
          ),
        ),
    ],
  );
}

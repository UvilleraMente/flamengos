import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../location/presentation/share_location.dart';
import '../../notifications/presentation/notifications_button.dart';
import '../../premium/data/premium.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/profile.dart';
import '../../profile/presentation/profile_sheet.dart';
import '../../requests/data/requests_repository.dart';
import '../../requests/domain/flamingo_request.dart';
import '../data/discover_repository.dart';
import 'discover_map.dart';
import 'filters_sheet.dart';
import 'swipe_deck.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  final _deck = GlobalKey<SwipeDeckState>();
  List<Profile>? _queue;
  Object? _error;
  bool _showMap = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _queue = null;
      _error = null;
    });
    try {
      final list = await ref.read(discoverRepositoryProvider).discover();
      if (!mounted) return;
      setState(() => _queue = list);
      precacheProfilePhotos(context, list.take(3));
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<bool> _onSwipe(Profile p, Swipe swipe) async {
    try {
      if (swipe == Swipe.like) {
        final result = await ref.read(requestsRepositoryProvider).send(p.id);
        if (mounted && result is RequestSent) {
          showInfo(context, context.l10n.discoverRequestSent(p.displayName));
        }
        // InstantMatch: HomeShell muestra la celebración.
      } else {
        ref.read(discoverRepositoryProvider).pass(p.id).ignore();
      }
    } catch (e) {
      if (mounted) showError(context, e);
      return false;
    }
    _remove(p);
    return true;
  }

  void _remove(Profile p) {
    if (!mounted) return;
    setState(() => _queue?.remove(p));
    precacheProfilePhotos(context, _queue!.skip(1).take(1));
  }

  Future<void> _shareLocation(Profile me) async {
    setState(() => _locating = true);
    final found = await locateMe(context, ref);
    if (found != null) {
      final repo = ref.read(profileRepositoryProvider);
      await repo.setLocation(found.point);
      if (me.city.isEmpty && found.city != null) {
        await repo.updateProfile({'city': found.city});
      }
      await _load();
    }
    if (mounted) setState(() => _locating = false);
  }

  Future<void> _openFilters(Profile me) async {
    if (await showFiltersSheet(context, me)) _load();
  }

  /// Desde el mapa: abre el perfil con acciones de pedir pareja / pasar.
  Future<void> _openFromMap(Profile p, bool canLike) async {
    final t = context.l10n;
    final blocked = await showProfileSheet(
      context,
      p,
      actions: (sheet) => [
        FlamIconButton(
          icon: const Icon(Icons.close_rounded, color: FlamColors.mint),
          size: 56,
          tooltip: t.discoverPass,
          onPressed: () async {
            Navigator.pop(sheet);
            await _onSwipe(p, Swipe.pass);
          },
        ),
        FlamIconButton(
          icon: const Text('🦩'),
          size: 64,
          variant: FlamVariant.primary,
          tooltip: t.discoverRequest,
          onPressed: canLike
              ? () async {
                  Navigator.pop(sheet);
                  await _onSwipe(p, Swipe.like);
                }
              : null,
        ),
      ],
    );
    if (blocked) _remove(p);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final me = ref.watch(myProfileProvider).value;
    final active = ref.watch(liveOutgoingCountProvider);
    final limit = ref.watch(requestLimitProvider);
    final full = active >= limit;

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: const Wordmark(size: 30),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: t.discoverActiveRequestsHint,
                  child: GlassPill(
                    color: full ? FlamColors.coral : null,
                    leading: const Text('🦩'),
                    child: Text('$active/$limit'),
                  ),
                ),
                const SizedBox(width: 8),
                const NotificationsButton(),
              ],
            ),
          ),
          if (me != null)
            _Toolbar(
              me: me,
              showMap: _showMap,
              onToggleMap: () => setState(() => _showMap = !_showMap),
              onFilters: () => _openFilters(me),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SafeArea(top: false, child: _body(me, full)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(Profile? me, bool full) {
    final t = context.l10n;
    if (_error != null) {
      return EmptyState(
        emoji: '🪶',
        title: t.discoverLoadError,
        message: describeError(context, _error!),
        action: FlamButton(label: t.actionRetry, onPressed: _load),
      );
    }
    final queue = _queue;
    if (queue == null || me == null) {
      return const Center(
        child: Heartbeat(child: Text('🦩', style: TextStyle(fontSize: 56))),
      );
    }

    final needsLocation = me.location == null && me.searchCenter == null;
    final banner = needsLocation
        ? _Banner(
            icon: Icons.location_on_rounded,
            text: t.discoverLocationBanner,
            action: FlamButton(
              label: t.locationUseMine,
              size: FlamSize.small,
              loading: _locating,
              onPressed: () => _shareLocation(me),
            ),
          )
        : full
        ? _Banner(
            icon: Icons.hourglass_top_rounded,
            text: t.discoverLimitReached(ref.read(requestLimitProvider)),
          )
        : null;

    final Widget content;
    if (_showMap) {
      content = DiscoverMap(
        profiles: queue,
        center: me.searchCenter ?? me.location,
        radiusKm: me.maxDistanceKm,
        onSelect: (p) => _openFromMap(p, !full),
      );
    } else if (queue.isEmpty) {
      content = EmptyState(
        title: t.discoverEmptyTitle,
        message: t.discoverEmptyMessage,
        action: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            FlamButton(
              label: t.discoverAdjustFilters,
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => _openFilters(me),
            ),
            FlamButton(
              label: t.discoverSearchAgain,
              icon: const Icon(Icons.refresh_rounded),
              variant: FlamVariant.glass,
              onPressed: _load,
            ),
          ],
        ),
      );
    } else {
      content = Column(
        children: [
          Expanded(
            child: SwipeDeck(
              key: _deck,
              profiles: queue,
              canLike: !full,
              onSwipe: _onSwipe,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlamIconButton(
                icon: const Icon(Icons.close_rounded, color: FlamColors.mint),
                size: 60,
                tooltip: t.discoverPass,
                onPressed: () => _deck.currentState?.swipe(Swipe.pass),
              ),
              const SizedBox(width: 20),
              FlamIconButton(
                icon: const Icon(Icons.info_outline_rounded),
                size: 46,
                tooltip: t.discoverViewProfile,
                onPressed: () async {
                  final p = queue.first;
                  if (await showProfileSheet(context, p)) _remove(p);
                },
              ),
              const SizedBox(width: 20),
              FlamIconButton(
                icon: const Text('🦩'),
                size: 72,
                variant: FlamVariant.primary,
                tooltip: t.discoverRequest,
                onPressed: full
                    ? null
                    : () => _deck.currentState?.swipe(Swipe.like),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          AnimatedSize(
            duration: FlamMotion.medium,
            child: banner == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: banner,
                  ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: FlamMotion.medium,
              child: KeyedSubtree(key: ValueKey(_showMap), child: content),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra con la zona de búsqueda, filtros y el cambio tarjetas ↔ mapa.
class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.me,
    required this.showMap,
    required this.onToggleMap,
    required this.onFilters,
  });

  final Profile me;
  final bool showMap;
  final VoidCallback onToggleMap;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final area = me.searchCenter != null
        ? (me.searchLabel ?? t.filtersOtherArea)
        : t.filtersNearMe;
    final km = me.maxDistanceKm;
    final summary = [
      area,
      km == null ? t.filtersAnyDistance : '$km km',
      t.filtersAgeRange(me.ageMin, me.ageMax),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onFilters,
                child: Glass(
                  radius: FlamRadius.pill,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: FlamColors.blush,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FlamIconButton(
              icon: Icon(showMap ? Icons.style_rounded : Icons.map_rounded),
              size: 44,
              tooltip: showMap ? t.discoverShowCards : t.discoverShowMap,
              variant: showMap ? FlamVariant.primary : FlamVariant.glass,
              onPressed: onToggleMap,
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Glass(
    padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
    child: Row(
      children: [
        Icon(icon, color: FlamColors.blush),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: FlamColors.textMuted)),
        ),
        if (action != null) ...[const SizedBox(width: 8), action!],
      ],
    ),
  );
}

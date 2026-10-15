import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/tokens.dart';
import '../../features/profile/domain/profile.dart';
import 'glass.dart';
import 'media.dart';

/// Tarjeta de perfil a pantalla completa.
/// Toca la mitad izquierda/derecha para cambiar de foto (no usa PageView para
/// no pelear con el gesto de deslizar del mazo).
class ProfileCard extends StatefulWidget {
  const ProfileCard(this.profile, {super.key});

  final Profile profile;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int _photo = 0;

  void _step(int delta) {
    final count = widget.profile.photos.length;
    if (count < 2) return;
    setState(() => _photo = (_photo + delta).clamp(0, count - 1));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final p = widget.profile;
    final urls = p.photoUrls;
    final distance = p.distanceKm;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FlamRadius.xl),
        boxShadow: FlamShadows.soft,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FlamRadius.xl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (urls.isEmpty)
              ColoredBox(
                color: FlamColors.plum,
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 120,
                    color: FlamColors.textFaint,
                  ),
                ),
              )
            else
              AnimatedSwitcher(
                duration: FlamMotion.fast,
                child: FlamImage(urls[_photo], key: ValueKey(urls[_photo])),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: FlamGradients.scrim),
            ),
            Row(
              children: [
                Expanded(child: GestureDetector(onTap: () => _step(-1))),
                Expanded(child: GestureDetector(onTap: () => _step(1))),
              ],
            ),
            if (urls.length > 1)
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    for (var i = 0; i < urls.length; i++)
                      Expanded(
                        child: AnimatedContainer(
                          duration: FlamMotion.fast,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: i == _photo
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: p.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: '  ${p.age}',
                            style: const TextStyle(fontWeight: FontWeight.w400),
                          ),
                          if (p.verified)
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: VerifiedBadge(size: 24),
                              ),
                            ),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 32,
                        height: 1.1,
                        color: FlamColors.onPhoto,
                      ),
                    ),
                    if (p.city.isNotEmpty ||
                        distance != null ||
                        p.sharedTags > 0) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (p.city.isNotEmpty)
                            GlassPill(
                              leading: const Icon(
                                Icons.place_rounded,
                                size: 15,
                              ),
                              child: Text(p.city),
                            ),
                          if (p.sharedTags > 0)
                            GlassPill(
                              leading: const Icon(
                                Icons.local_offer_rounded,
                                size: 14,
                              ),
                              child: Text(t.tagsShared(p.sharedTags)),
                            ),
                          if (distance != null)
                            GlassPill(
                              leading: const Icon(
                                Icons.near_me_rounded,
                                size: 14,
                              ),
                              child: Text(
                                t.distanceAway(
                                  distance.round().clamp(1, 99999),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (p.bio.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        p.bio,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: FlamColors.onPhotoMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Insignia de perfil verificado.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.l10n.verifiedBadge,
    child: Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [FlamColors.mint, Color(0xFF38BDF8)]),
      ),
      child: Icon(
        Icons.check_rounded,
        size: size * 0.7,
        color: FlamColors.night,
      ),
    ),
  );
}

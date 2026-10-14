import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../features/profile/domain/profile.dart';

/// Imagen remota con caché en disco (móvil) y decodificada al tamaño que se
/// muestra, para no gastar memoria con fotos de 4000 px.
class FlamImage extends StatelessWidget {
  const FlamImage(this.url, {super.key, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final width = box.maxWidth.isFinite
            ? (box.maxWidth * dpr).round()
            : null;
        return CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          memCacheWidth: width,
          fadeInDuration: FlamMotion.medium,
          placeholder: (_, _) => const ColoredBox(color: FlamColors.glassFill),
          errorWidget: (_, _, _) => const ColoredBox(
            color: FlamColors.glassFill,
            child: Center(child: Icon(Icons.broken_image_outlined)),
          ),
        );
      },
    );
  }
}

/// Precarga fotos (p. ej. la siguiente tarjeta) para que aparezcan al instante.
void precacheProfilePhotos(BuildContext context, Iterable<Profile> profiles) {
  for (final p in profiles) {
    final url = p.mainPhotoUrl;
    if (url != null) {
      precacheImage(CachedNetworkImageProvider(url), context).ignore();
    }
  }
}

/// Avatar con anillo degradado.
class Avatar extends StatelessWidget {
  const Avatar(this.profile, {super.key, this.radius = 26, this.ring = true});

  final Profile? profile;
  final double radius;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final url = profile?.mainPhotoUrl;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: FlamColors.plum,
      backgroundImage: url == null
          ? null
          : ResizeImage(
              CachedNetworkImageProvider(url),
              width: (radius * 2 * dpr).round(),
            ),
      child: url == null
          ? Text('🦩', style: TextStyle(fontSize: radius * 0.9))
          : null,
    );
    if (!ring) return avatar;
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: FlamGradients.primary,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: FlamColors.night,
        ),
        child: avatar,
      ),
    );
  }
}

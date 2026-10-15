import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../features/profile/domain/profile.dart';

/// Imagen remota con caché en disco (móvil) y decodificada al tamaño que se
/// muestra, para no gastar memoria con fotos de 4000 px.
class FlamImage extends StatelessWidget {
  const FlamImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.alignment = faceAlignment,
  });

  /// Las caras suelen estar en el tercio de arriba: al recortar una foto
  /// vertical se conserva esa parte en vez del centro.
  static const faceAlignment = Alignment(0, -0.35);

  final String url;
  final BoxFit fit;
  final Alignment alignment;

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
          alignment: alignment,
          memCacheWidth: width,
          fadeInDuration: FlamMotion.medium,
          placeholder: (_, _) => ColoredBox(color: FlamColors.glassFill),
          errorWidget: (_, _, _) => ColoredBox(
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
          ? Icon(
              Icons.person_rounded,
              size: radius * 1.1,
              color: FlamColors.textFaint,
            )
          : null,
    );
    if (!ring) return avatar;
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: FlamGradients.primary,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: FlamColors.night,
        ),
        child: avatar,
      ),
    );
  }
}

/// Fotos a pantalla completa: deslizar entre ellas y pellizcar para ampliar.
Future<void> showPhotoViewer(
  BuildContext context,
  List<String> urls, {
  int initial = 0,
}) => Navigator.of(context).push(
  PageRouteBuilder<void>(
    opaque: false,
    barrierColor: Colors.black,
    pageBuilder: (_, _, _) => _PhotoViewer(urls: urls, initial: initial),
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  ),
);

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({required this.urls, required this.initial});

  final List<String> urls;
  final int initial;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final _pages = PageController(initialPage: widget.initial);
  late int _index = widget.initial;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: FlamImage(
                  widget.urls[i],
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  if (widget.urls.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        '${_index + 1} / ${widget.urls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/widgets.dart';

/// Proporción de las fotos de perfil (vertical, como en la tarjeta).
const photoAspectRatio = 4 / 5;

/// Abre el recorte y devuelve la foto recortada (o null si se cancela).
Future<Uint8List?> cropPhoto(BuildContext context, Uint8List image) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _PhotoCropPage(image: image),
      ),
    );

class _PhotoCropPage extends StatefulWidget {
  const _PhotoCropPage({required this.image});

  final Uint8List image;

  @override
  State<_PhotoCropPage> createState() => _PhotoCropPageState();
}

class _PhotoCropPageState extends State<_PhotoCropPage> {
  final _controller = CropController();
  bool _cropping = false;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          t.photoCropTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.image,
              controller: _controller,
              aspectRatio: photoAspectRatio,
              // Se mueve y amplía la foto; el marco queda fijo.
              interactive: true,
              fixCropRect: true,
              baseColor: Colors.black,
              maskColor: Colors.black.withValues(alpha: 0.6),
              cornerDotBuilder: (_, _) => const SizedBox.shrink(),
              initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                size: 0.92,
                aspectRatio: photoAspectRatio,
              ),
              progressIndicator: const CircularProgressIndicator(),
              onCropped: (result) {
                if (!mounted) return;
                switch (result) {
                  case CropSuccess(:final croppedImage):
                    Navigator.pop(context, croppedImage);
                  case CropFailure():
                    setState(() => _cropping = false);
                }
              },
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  t.photoCropHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                FlamButton(
                  label: t.photoCropUse,
                  icon: const Icon(Icons.check_rounded),
                  expand: true,
                  size: FlamSize.large,
                  loading: _cropping,
                  onPressed: () {
                    setState(() => _cropping = true);
                    _controller.crop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tipo de imagen por sus primeros bytes (para subirla con el correcto).
String imageMimeType(Uint8List bytes) {
  if (bytes.length > 3 && bytes[0] == 0x89 && bytes[1] == 0x50) {
    return 'image/png';
  }
  if (bytes.length > 12 && bytes[8] == 0x57 && bytes[9] == 0x45) {
    return 'image/webp';
  }
  return 'image/jpeg';
}

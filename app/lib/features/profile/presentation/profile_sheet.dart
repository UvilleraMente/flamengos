import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../safety/presentation/report_sheet.dart';
import '../data/profile_repository.dart';
import '../domain/profile.dart';
import 'profile_l10n.dart';
import 'tag_chips.dart';

/// Perfil completo de otra persona: fotos, preguntas, acciones y reporte.
///
/// [actions] recibe el contexto de la hoja (para cerrarla con Navigator.pop).
/// Devuelve true si el usuario bloqueó a esta persona.
Future<bool> showProfileSheet(
  BuildContext context,
  Profile profile, {
  List<Widget> Function(BuildContext sheetContext)? actions,
}) async {
  final blocked = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _ProfileSheet(
      profile: profile,
      actions: actions?.call(sheetContext) ?? const [],
    ),
  );
  return blocked ?? false;
}

class _ProfileSheet extends ConsumerWidget {
  const _ProfileSheet({required this.profile, required this.actions});

  final Profile profile;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final p = profile;
    final myTags = ref.watch(myProfileProvider).value?.tags ?? const {};
    final isMe = Supabase.instance.client.auth.currentUser?.id == p.id;
    final urls = p.photoUrls;
    void open(int i) => showPhotoViewer(context, urls, initial: i);

    // Después de la foto principal, se alternan preguntas y fotos.
    final rest = <Widget>[];
    final extra = urls.length - 1;
    for (var i = 0; i < extra || i < p.prompts.length; i++) {
      if (i < p.prompts.length) rest.add(PromptCard(prompt: p.prompts[i]));
      if (i < extra) {
        rest.add(_Photo(url: urls[i + 1], onTap: () => open(i + 1)));
      }
    }

    const gap = SizedBox(height: 12);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.92,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          _Hero(profile: p, onTap: urls.isEmpty ? null : () => open(0)),
          gap,
          _Facts(profile: p),
          if (p.tags.isNotEmpty) ...[
            gap,
            Glass(
              padding: const EdgeInsets.all(14),
              child: TagWrap(
                tags: p.tags,
                highlight: isMe ? const {} : myTags.intersection(p.tags),
              ),
            ),
          ],
          if (p.bio.isNotEmpty) ...[
            gap,
            Glass(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.profileAboutMe,
                    style: TextStyle(
                      color: FlamColors.blush,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.bio,
                    style: const TextStyle(fontSize: 16.5, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
          for (final w in rest) ...[gap, w],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (i, a) in actions.indexed) ...[
                  if (i > 0) const SizedBox(width: 16),
                  a,
                ],
              ],
            ),
          ],
          if (!isMe) ...[
            const SizedBox(height: 20),
            Center(
              child: FlamButton(
                label: t.safetyReportOrBlock,
                icon: const Icon(Icons.flag_outlined),
                variant: FlamVariant.ghost,
                size: FlamSize.small,
                onPressed: () async {
                  final blocked = await showReportSheet(context, p);
                  if (blocked && context.mounted) Navigator.pop(context, true);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Foto principal grande con el nombre, la edad y la insignia encima.
class _Hero extends StatelessWidget {
  const _Hero({required this.profile, this.onTap});

  final Profile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final url = p.mainPhotoUrl;
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(FlamRadius.xl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url == null)
                ColoredBox(
                  color: FlamColors.plum,
                  child: Icon(
                    Icons.person_rounded,
                    size: 120,
                    color: FlamColors.textFaint,
                  ),
                )
              else
                FlamImage(url),
              const DecoratedBox(
                decoration: BoxDecoration(gradient: FlamGradients.scrim),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 18,
                child: Text.rich(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Datos rápidos: ciudad, distancia, género y a quién busca.
class _Facts extends StatelessWidget {
  const _Facts({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final p = profile;
    final distance = p.distanceKm;
    final facts = [
      if (p.city.isNotEmpty) (Icons.place_rounded, p.city),
      if (distance != null)
        (
          Icons.near_me_rounded,
          t.distanceAway(distance.round().clamp(1, 99999)),
        ),
      (Icons.person_rounded, p.gender.label(t)),
      (
        Icons.favorite_rounded,
        p.interestedIn.map((g) => g.plural(t)).join(' · '),
      ),
    ];
    return Glass(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        children: [
          for (final (i, (icon, text)) in facts.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 0.5,
                indent: 44,
                color: FlamColors.glassBorder,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: FlamColors.pink),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(text, style: const TextStyle(fontSize: 15.5)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url, required this.onTap});

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FlamRadius.xl),
        child: FlamImage(url),
      ),
    ),
  );
}

class PromptCard extends StatelessWidget {
  const PromptCard({super.key, required this.prompt, this.trailing});

  final ProfilePrompt prompt;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prompt.key.question(context.l10n),
                  style: TextStyle(
                    color: FlamColors.blush,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  prompt.answer,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

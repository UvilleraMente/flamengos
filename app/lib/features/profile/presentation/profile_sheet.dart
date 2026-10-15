import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../safety/presentation/report_sheet.dart';
import '../domain/profile.dart';
import 'profile_l10n.dart';

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

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({required this.profile, required this.actions});

  final Profile profile;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final isMe = Supabase.instance.client.auth.currentUser?.id == profile.id;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.88,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          AspectRatio(aspectRatio: 3 / 4, child: ProfileCard(profile)),
          for (final prompt in profile.prompts) ...[
            const SizedBox(height: 12),
            PromptCard(prompt: prompt),
          ],
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
                  final blocked = await showReportSheet(context, profile);
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

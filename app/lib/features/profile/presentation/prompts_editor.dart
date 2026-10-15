import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/profile.dart';
import 'profile_l10n.dart';
import 'profile_sheet.dart';

const maxPrompts = 3;
const _maxAnswer = 200;

/// Lista editable de preguntas del perfil (hasta [maxPrompts]).
class PromptsEditor extends StatelessWidget {
  const PromptsEditor({
    super.key,
    required this.prompts,
    required this.onChanged,
  });

  final List<ProfilePrompt> prompts;
  final ValueChanged<List<ProfilePrompt>> onChanged;

  Future<void> _edit(BuildContext context, {int? index}) async {
    final used = {for (final p in prompts) p.key}
      ..remove(index == null ? null : prompts[index].key);
    final result = await showModalBottomSheet<ProfilePrompt>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PromptSheet(
        initial: index == null ? null : prompts[index],
        available: PromptKey.values.where((k) => !used.contains(k)).toList(),
      ),
    );
    if (result == null) return;
    final next = [...prompts];
    index == null ? next.add(result) : next[index] = result;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, p) in prompts.indexed) ...[
          GestureDetector(
            onTap: () => _edit(context, index: i),
            child: PromptCard(
              prompt: p,
              trailing: IconButton(
                tooltip: t.actionRemove,
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => onChanged([...prompts]..removeAt(i)),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (prompts.length < maxPrompts)
          FlamButton(
            label: t.promptsAdd,
            icon: const Icon(Icons.add_rounded),
            variant: FlamVariant.glass,
            onPressed: () => _edit(context),
          ),
      ],
    );
  }
}

class _PromptSheet extends StatefulWidget {
  const _PromptSheet({required this.initial, required this.available});

  final ProfilePrompt? initial;
  final List<PromptKey> available;

  @override
  State<_PromptSheet> createState() => _PromptSheetState();
}

class _PromptSheetState extends State<_PromptSheet> {
  late PromptKey? _key = widget.initial?.key;
  late final _answer = TextEditingController(text: widget.initial?.answer);

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final canSave = _key != null && _answer.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.promptsChoose,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in widget.available)
                  FlamChip(
                    label: k.question(t),
                    selected: _key == k,
                    onTap: () => setState(() => _key = k),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answer,
              onChanged: (_) => setState(() {}),
              maxLength: _maxAnswer,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _key == null
                    ? t.promptsPickFirst
                    : t.promptsAnswerHint,
                enabled: _key != null,
              ),
            ),
            const SizedBox(height: 8),
            FlamButton(
              label: t.actionSave,
              expand: true,
              onPressed: canSave
                  ? () => Navigator.pop(
                      context,
                      ProfilePrompt(_key!, _answer.text.trim()),
                    )
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              t.promptsTip,
              textAlign: TextAlign.center,
              style: TextStyle(color: FlamColors.textFaint, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

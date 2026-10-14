import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/data/auth_repository.dart';

/// Pide escribir una palabra de confirmación antes de borrar la cuenta
/// (es irreversible). Al terminar, el router lleva al login.
Future<void> showDeleteAccountDialog(BuildContext context) =>
    showGlassDialog<void>(
      context,
      builder: (_) => const _DeleteAccountDialog(),
    );

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final goodbye = context.l10n.deleteAccountDone;
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(goodbye)));
    } catch (e) {
      if (mounted) {
        showError(context, e);
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final word = t.deleteAccountWord;
    final matches = _confirm.text.trim().toUpperCase() == word.toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '🥀',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 44),
        ),
        const SizedBox(height: 12),
        Text(
          t.deleteAccountTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          t.deleteAccountMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: FlamColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _confirm,
          enabled: !_busy,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: t.deleteAccountTypeHint(word)),
        ),
        const SizedBox(height: 18),
        FlamButton(
          label: t.deleteAccountAction,
          variant: FlamVariant.danger,
          expand: true,
          loading: _busy,
          onPressed: matches ? _delete : null,
        ),
        const SizedBox(height: 8),
        FlamButton(
          label: t.actionCancel,
          variant: FlamVariant.ghost,
          expand: true,
          onPressed: _busy ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }
}

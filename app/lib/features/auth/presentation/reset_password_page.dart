import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/auth_repository.dart';

/// Elegir contraseña nueva (después del enlace o del código de recuperación).
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _show = false;
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).updatePassword(_password.text);
      if (!mounted) return;
      showInfo(context, context.l10n.resetDone);
      // El router sale de esta pantalla al apagarse la recuperación.
      ref.read(passwordRecoveryProvider.notifier).done();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final visibility = IconButton(
      tooltip: _show ? t.authHidePassword : t.authShowPassword,
      onPressed: () => setState(() => _show = !_show),
      icon: Icon(
        _show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Glass(
              radius: FlamRadius.xl,
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '🔐',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 52),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.resetTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _password,
                      obscureText: !_show,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: t.resetNewPassword,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: visibility,
                      ),
                      validator: (v) => v != null && v.length >= 6
                          ? null
                          : t.authPasswordTooShort,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirm,
                      obscureText: !_show,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: t.resetConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                      ),
                      onFieldSubmitted: (_) => _save(),
                      validator: (v) =>
                          v == _password.text ? null : t.resetMismatch,
                    ),
                    const SizedBox(height: 22),
                    FlamButton(
                      label: t.resetSave,
                      size: FlamSize.large,
                      expand: true,
                      loading: _busy,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.resetHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: FlamColors.textFaint,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

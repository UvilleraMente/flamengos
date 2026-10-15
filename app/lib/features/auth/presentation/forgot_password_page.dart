import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/auth_repository.dart';

/// Recuperar contraseña: 1) pedir el correo, 2) escribir el código del
/// correo (o abrir el enlace). Al verificar, el router lleva a /reset-password.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  static const _resendAfter = 60;

  late final _email = TextEditingController(text: widget.initialEmail);
  final _code = TextEditingController();
  bool _sent = false;
  bool _busy = false;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _resendAfter);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _cooldown <= 1) t.cancel();
      if (mounted) setState(() => _cooldown--);
    });
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      showInfo(context, context.l10n.authEmailInvalid);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _sent = true);
      _startCooldown();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.length < 6) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyRecoveryCode(_email.text.trim(), code);
      // passwordRecovery → el router abre /reset-password.
    } catch (_) {
      if (mounted) showInfo(context, context.l10n.forgotInvalidCode);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(t.forgotTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Glass(
              radius: FlamRadius.xl,
              padding: const EdgeInsets.all(22),
              child: AnimatedSize(
                duration: FlamMotion.medium,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: FlamColors.pink.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _sent
                              ? Icons.mark_email_read_rounded
                              : Icons.key_rounded,
                          size: 32,
                          color: FlamColors.pink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _sent
                          ? t.forgotSentMessage(_email.text.trim())
                          : t.forgotIntro,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: FlamColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _email,
                      enabled: !_sent,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: t.authEmail,
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                      ),
                      onSubmitted: (_) => _sent ? null : _send(),
                    ),
                    if (_sent) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: _code,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          letterSpacing: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          labelText: t.forgotCode,
                          hintText: '••••••',
                        ),
                        onChanged: (v) {
                          setState(() {});
                          if (v.length == 6) _verify();
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    FlamButton(
                      label: _sent ? t.forgotVerify : t.forgotSend,
                      size: FlamSize.large,
                      expand: true,
                      loading: _busy,
                      onPressed: _sent
                          ? (_code.text.length == 6 ? _verify : null)
                          : _send,
                    ),
                    if (_sent) ...[
                      const SizedBox(height: 8),
                      FlamButton(
                        label: _cooldown > 0
                            ? t.forgotResendIn(_cooldown)
                            : t.forgotResend,
                        variant: FlamVariant.ghost,
                        expand: true,
                        onPressed: _cooldown > 0 || _busy ? null : _send,
                      ),
                      FlamButton(
                        label: t.forgotChangeEmail,
                        variant: FlamVariant.ghost,
                        expand: true,
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                _sent = false;
                                _code.clear();
                              }),
                      ),
                    ],
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

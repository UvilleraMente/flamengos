import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/env.dart';
import '../../../app/router.dart';
import '../../../core/security/app_lock.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../settings/presentation/language_picker.dart';
import '../data/auth_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;
  bool _showPassword = false;

  /// Hay credenciales guardadas para entrar con huella o rostro.
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    ref.read(appLockProvider.notifier).canSignInWithBiometrics().then((ok) {
      if (mounted) setState(() => _canUseBiometrics = ok);
    });
  }

  Future<void> _biometricSignIn() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(appLockProvider.notifier)
          .signInWithBiometrics(
            context.l10n.lockReason,
            ref.read(authRepositoryProvider).signIn,
          );
    } catch (e) {
      if (mounted) {
        showError(context, e);
        setState(() => _canUseBiometrics = false);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final auth = ref.read(authRepositoryProvider);
    final email = _email.text.trim();
    try {
      if (_isSignUp) {
        final signedIn = await auth.signUp(email, _password.text);
        if (!signedIn && mounted) {
          showInfo(context, context.l10n.authCheckEmail);
        }
      } else {
        await auth.signIn(email, _password.text);
      }
      // El router redirige solo al detectar la sesión.
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    const Heartbeat(scale: 0.08, child: FlamLogo(size: 104)),
                    const Wordmark(size: 46),
                    const SizedBox(height: 4),
                    Text(
                      t.tagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: FlamColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Glass(
                      padding: const EdgeInsets.all(20),
                      radius: FlamRadius.xl,
                      child: Form(
                        key: _form,
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GlassSegmented(
                                segments: [
                                  (false, t.authSignInTab),
                                  (true, t.authSignUpTab),
                                ],
                                value: _isSignUp,
                                onChanged: (v) => setState(() => _isSignUp = v),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _email,
                                decoration: InputDecoration(
                                  labelText: t.authEmail,
                                  prefixIcon: const Icon(
                                    Icons.alternate_email_rounded,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: (v) => v != null && v.contains('@')
                                    ? null
                                    : t.authEmailInvalid,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _password,
                                decoration: InputDecoration(
                                  labelText: t.authPassword,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    tooltip: _showPassword
                                        ? t.authHidePassword
                                        : t.authShowPassword,
                                    onPressed: () => setState(
                                      () => _showPassword = !_showPassword,
                                    ),
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                                obscureText: !_showPassword,
                                autofillHints: [
                                  _isSignUp
                                      ? AutofillHints.newPassword
                                      : AutofillHints.password,
                                ],
                                onFieldSubmitted: (_) => _submit(),
                                validator: (v) => v != null && v.length >= 6
                                    ? null
                                    : t.authPasswordTooShort,
                              ),
                              if (!_isSignUp)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.push(
                                      Routes.forgotPassword,
                                      extra: _email.text.trim(),
                                    ),
                                    child: Text(t.authForgotPassword),
                                  ),
                                )
                              else
                                const SizedBox(height: 22),
                              FlamButton(
                                label: _isSignUp
                                    ? t.authCreateAccount
                                    : t.authSignIn,
                                size: FlamSize.large,
                                expand: true,
                                loading: _busy,
                                onPressed: _submit,
                              ),
                              if (_canUseBiometrics && !_isSignUp) ...[
                                const SizedBox(height: 10),
                                FlamButton(
                                  label: t.loginBiometric,
                                  icon: const Icon(Icons.fingerprint_rounded),
                                  variant: FlamVariant.glass,
                                  expand: true,
                                  onPressed: _busy ? null : _biometricSignIn,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t.authAgeNotice,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: FlamColors.textFaint,
                        fontSize: 13,
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => launchUrl(Uri.parse(Env.termsUrl)),
                          child: Text(t.legalTerms),
                        ),
                        TextButton(
                          onPressed: () => launchUrl(Uri.parse(Env.privacyUrl)),
                          child: Text(t.legalPrivacy),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: LanguageButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

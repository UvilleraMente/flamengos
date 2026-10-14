import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../settings/presentation/language_picker.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final auth = Supabase.instance.client.auth;
    try {
      if (_isSignUp) {
        final res = await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (res.session == null && mounted) {
          showInfo(context, context.l10n.authCheckEmail);
        }
      } else {
        await auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
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
                    const Heartbeat(
                      scale: 0.08,
                      child: Text('🦩', style: TextStyle(fontSize: 76)),
                    ),
                    const Wordmark(size: 46),
                    const SizedBox(height: 4),
                    Text(
                      t.tagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t.authAgeNotice,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/env.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../data/terms_repository.dart';

/// Reglas de Flamengos y aceptación de términos y privacidad. Se muestra
/// antes de crear el perfil (y otra vez si cambia Env.termsVersion).
class ConsentPage extends ConsumerStatefulWidget {
  const ConsentPage({super.key});

  @override
  ConsumerState<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends ConsumerState<ConsentPage> {
  bool _agreed = false;
  bool _saving = false;

  Future<void> _accept() async {
    setState(() => _saving = true);
    try {
      await acceptTerms(ref.read(supabaseProvider));
      // El router sigue solo al saber que ya aceptó.
      ref.invalidate(termsAcceptedProvider);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final rules = [
      (Icons.favorite_rounded, t.rulesExclusiveTitle, t.rulesExclusiveBody),
      (Icons.logout_rounded, t.rulesLeaveTitle, t.rulesLeaveBody),
      (Icons.send_rounded, t.rulesRequestsTitle, t.rulesRequestsBody),
      (Icons.shield_rounded, t.rulesRespectTitle, t.rulesRespectBody),
    ];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                const Center(child: FlamLogo(size: 76)),
                const SizedBox(height: 10),
                Text(
                  t.rulesTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.rulesSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: FlamColors.textMuted, fontSize: 15),
                ),
                const SizedBox(height: 22),
                SettingsGroupCard(
                  children: [
                    for (final (icon, title, body) in rules)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: FlamColors.pink.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                icon,
                                size: 19,
                                color: FlamColors.pink,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    body,
                                    style: TextStyle(
                                      color: FlamColors.textMuted,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                InkWell(
                  borderRadius: BorderRadius.circular(FlamRadius.md),
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox.adaptive(
                          value: _agreed,
                          onChanged: (v) => setState(() => _agreed = v!),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              t.rulesAgree,
                              style: const TextStyle(height: 1.35),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                const SizedBox(height: 8),
                FlamButton(
                  label: t.rulesAccept,
                  size: FlamSize.large,
                  expand: true,
                  loading: _saving,
                  onPressed: _agreed ? _accept : null,
                ),
                const SizedBox(height: 8),
                FlamButton(
                  label: t.actionSignOut,
                  variant: FlamVariant.ghost,
                  expand: true,
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

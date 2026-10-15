import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/env.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

/// Preguntas frecuentes + enlaces legales y de contacto.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final faqs = [
      (t.faqExclusiveQ, t.faqExclusiveA),
      (t.faqRequestsQ, t.faqRequestsA),
      (t.faqAcceptQ, t.faqAcceptA),
      (t.faqEndQ, t.faqEndA),
      (t.faqLocationQ, t.faqLocationA),
      (t.faqSafetyQ, t.faqSafetyA),
      (t.faqVerifyQ, t.faqVerifyA),
      (t.faqDeleteQ, t.faqDeleteA),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.helpTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              for (final (q, a) in faqs) ...[
                _Faq(question: q, answer: a),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (Env.supportEmail.isNotEmpty)
                    FlamButton(
                      label: t.helpContact,
                      icon: const Icon(Icons.mail_outline_rounded),
                      onPressed: () => launchUrl(
                        Uri(scheme: 'mailto', path: Env.supportEmail),
                      ),
                    ),
                  FlamButton(
                    label: t.legalTerms,
                    variant: FlamVariant.glass,
                    size: FlamSize.small,
                    onPressed: () => launchUrl(Uri.parse(Env.termsUrl)),
                  ),
                  FlamButton(
                    label: t.legalPrivacy,
                    variant: FlamVariant.glass,
                    size: FlamSize.small,
                    onPressed: () => launchUrl(Uri.parse(Env.privacyUrl)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Faq extends StatefulWidget {
  const _Faq({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_Faq> createState() => _FaqState();
}

class _FaqState extends State<_Faq> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: Glass(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        child: AnimatedSize(
          duration: FlamMotion.medium,
          curve: FlamMotion.curve,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: FlamMotion.medium,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: FlamColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (_open) ...[
                const SizedBox(height: 8),
                Text(
                  widget.answer,
                  style: TextStyle(color: FlamColors.textMuted, height: 1.45),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

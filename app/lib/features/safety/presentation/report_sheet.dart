import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../profile/domain/profile.dart';
import '../data/safety_repository.dart';
import '../domain/report_reason.dart';

extension ReportReasonL10n on ReportReason {
  String label(AppLocalizations t) => switch (this) {
    ReportReason.fakeProfile => t.reportFakeProfile,
    ReportReason.inappropriateContent => t.reportInappropriate,
    ReportReason.harassment => t.reportHarassment,
    ReportReason.underage => t.reportUnderage,
    ReportReason.spam => t.reportSpam,
    ReportReason.other => t.reportOther,
  };
}

/// Reportar (y bloquear) o solo bloquear. Devuelve true si se bloqueó.
Future<bool> showReportSheet(BuildContext context, Profile profile) async {
  final blocked = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ReportSheet(profile: profile),
  );
  return blocked ?? false;
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  final _details = TextEditingController();
  ReportReason? _reason;
  bool _busy = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool report}) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(safetyRepositoryProvider)
          .block(
            widget.profile.id,
            reason: report ? _reason : null,
            details: report ? _details.text : null,
          );
      ref.invalidate(blockedProfilesProvider);
      if (!mounted) return;
      showInfo(
        context,
        report
            ? context.l10n.reportSent
            : context.l10n.blockDone(widget.profile.displayName),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
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
              t.reportTitle(widget.profile.displayName),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              t.reportSubtitle,
              style: const TextStyle(color: FlamColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in ReportReason.values)
                  FlamChip(
                    label: r.label(t),
                    selected: _reason == r,
                    onTap: () => setState(() => _reason = r),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _details,
              decoration: InputDecoration(hintText: t.reportDetailsHint),
              maxLines: 3,
              maxLength: 1000,
            ),
            const SizedBox(height: 12),
            FlamButton(
              label: t.reportAndBlock,
              variant: FlamVariant.danger,
              expand: true,
              loading: _busy,
              onPressed: _reason == null ? null : () => _submit(report: true),
            ),
            const SizedBox(height: 8),
            FlamButton(
              label: t.blockOnly,
              variant: FlamVariant.glass,
              expand: true,
              onPressed: _busy ? null : () => _submit(report: false),
            ),
          ],
        ),
      ),
    );
  }
}

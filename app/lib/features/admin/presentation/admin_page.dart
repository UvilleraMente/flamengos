import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../profile/domain/profile.dart';
import '../../safety/domain/report_reason.dart';
import '../../safety/presentation/report_sheet.dart';
import '../../verification/domain/verification.dart';
import '../../verification/presentation/verification_page.dart';
import '../data/admin_repository.dart';

enum _Tab { verifications, photos, reports }

/// Panel de administración: verificaciones, fotos nuevas y reportes.
class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  _Tab _tab = _Tab.verifications;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final isAdmin = ref.watch(isAdminProvider).value ?? false;
    final counts = ref.watch(adminCountsProvider).value ?? const {};
    String label(String text, String key) =>
        (counts[key] ?? 0) > 0 ? '$text · ${counts[key]}' : text;

    return Scaffold(
      appBar: AppBar(title: Text(t.adminTitle)),
      body: !isAdmin
          ? EmptyState(
              icon: Icons.lock_rounded,
              title: t.adminTitle,
              message: t.errorNotAdmin,
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: GlassSegmented(
                        segments: [
                          (
                            _Tab.verifications,
                            label(t.adminVerifications, 'verifications'),
                          ),
                          (_Tab.photos, label(t.adminPhotos, 'photos')),
                          (_Tab.reports, label(t.adminReports, 'reports')),
                        ],
                        value: _tab,
                        onChanged: (v) => setState(() => _tab = v),
                      ),
                    ),
                    Expanded(
                      child: switch (_tab) {
                        _Tab.verifications => const _Verifications(),
                        _Tab.photos => const _Photos(),
                        _Tab.reports => const _Reports(),
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Lista genérica con carga, error y vacío.
class _AsyncList extends StatelessWidget {
  const _AsyncList({required this.value, required this.builder});

  final AsyncValue<List<Map<String, dynamic>>> value;
  final Widget Function(List<Map<String, dynamic>> items) builder;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.cloud_off_rounded,
        title: t.adminTitle,
        message: describeError(context, e),
      ),
      data: (items) => items.isEmpty
          ? EmptyState(
              icon: Icons.task_alt_rounded,
              title: t.adminEmpty,
              message: '',
            )
          : builder(items),
    );
  }
}

Future<void> _act(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() action,
  void Function() refresh,
) async {
  try {
    await action();
    refresh();
    ref.invalidate(adminCountsProvider);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

// ---------------------------------------------------------------------
// Verificaciones: foto del perfil al lado de la selfie con la pose pedida.
// ---------------------------------------------------------------------
class _Verifications extends ConsumerWidget {
  const _Verifications();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final repo = ref.read(adminRepositoryProvider);
    return _AsyncList(
      value: ref.watch(adminVerificationsProvider),
      builder: (items) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final v = items[i];
          final photos = List<String>.from(v['photos'] as List? ?? const []);
          final pose = VerificationPose.values
              .where((p) => p.name == v['pose'])
              .firstOrNull;
          return Glass(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  v['name'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (pose != null)
                  Text(
                    t.adminPose(pose.instruction(t)),
                    style: TextStyle(color: FlamColors.textMuted),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Framed(
                        child: photos.isEmpty
                            ? const SizedBox.shrink()
                            : FlamImage(photoUrl(photos.first)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Framed(
                        child: FutureBuilder(
                          future: repo.selfieUrl(v['selfie_path'] as String),
                          builder: (_, snap) => snap.hasData
                              ? FlamImage(snap.data!)
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Decision(
                  onApprove: () => _act(
                    context,
                    ref,
                    () => repo.reviewVerification(v['id'] as String, true),
                    () => ref.invalidate(adminVerificationsProvider),
                  ),
                  onReject: () => _act(
                    context,
                    ref,
                    () => repo.reviewVerification(v['id'] as String, false),
                    () => ref.invalidate(adminVerificationsProvider),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Fotos nuevas: cuadrícula; cada una se aprueba o se quita del perfil.
// ---------------------------------------------------------------------
class _Photos extends ConsumerWidget {
  const _Photos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final repo = ref.read(adminRepositoryProvider);
    return _AsyncList(
      value: ref.watch(adminPhotosProvider),
      builder: (items) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: FlamButton(
              label: t.adminApproveAll(items.length),
              icon: const Icon(Icons.done_all_rounded),
              variant: FlamVariant.glass,
              expand: true,
              onPressed: () => _act(
                context,
                ref,
                () => Future.wait([
                  for (final p in items)
                    repo.reviewPhoto(p['path'] as String, true),
                ]),
                () => ref.invalidate(adminPhotosProvider),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.62,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final p = items[i];
                final path = p['path'] as String;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showPhotoViewer(context, [photoUrl(path)]),
                        child: _Framed(child: FlamImage(photoUrl(path))),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p['name'] as String? ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    _Decision(
                      compact: true,
                      onApprove: () => _act(
                        context,
                        ref,
                        () => repo.reviewPhoto(path, true),
                        () => ref.invalidate(adminPhotosProvider),
                      ),
                      onReject: () => _act(
                        context,
                        ref,
                        () => repo.reviewPhoto(path, false),
                        () => ref.invalidate(adminPhotosProvider),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Reportes: descartar o bloquear la cuenta reportada.
// ---------------------------------------------------------------------
class _Reports extends ConsumerWidget {
  const _Reports();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final repo = ref.read(adminRepositoryProvider);
    final dateFmt = DateFormat.yMMMd(context.localeTag).add_Hm();
    return _AsyncList(
      value: ref.watch(adminReportsProvider),
      builder: (items) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final r = items[i];
          final photos = List<String>.from(r['photos'] as List? ?? const []);
          final reason = ReportReason.values
              .where((x) => x.dbValue == r['reason'])
              .firstOrNull;
          final name = r['reported'] as String? ?? t.someone;
          final details = r['details'] as String?;
          return Glass(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: photos.isEmpty
                          ? null
                          : () => showPhotoViewer(
                              context,
                              photos.map(photoUrl).toList(),
                            ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: FlamColors.plum,
                        child: photos.isEmpty
                            ? const Icon(Icons.person_rounded)
                            : ClipOval(
                                child: SizedBox.square(
                                  dimension: 52,
                                  child: FlamImage(photoUrl(photos.first)),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            t.adminOpenReports(
                              (r['open_against'] as num?)?.toInt() ?? 1,
                            ),
                            style: TextStyle(
                              color: FlamColors.danger,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  reason?.label(t) ?? '${r['reason']}',
                  style: TextStyle(
                    color: FlamColors.pink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (details != null && details.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(details),
                  ),
                const SizedBox(height: 6),
                Text(
                  '${t.adminReportedBy(r['reporter'] as String? ?? t.someone)}'
                  ' · ${dateFmt.format(DateTime.parse(r['created_at'] as String).toLocal())}',
                  style: TextStyle(color: FlamColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FlamButton(
                        label: t.adminDismiss,
                        variant: FlamVariant.glass,
                        size: FlamSize.small,
                        onPressed: () => _act(
                          context,
                          ref,
                          () => repo.dismissReport(r['id'] as String),
                          () => ref.invalidate(adminReportsProvider),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FlamButton(
                        label: t.adminBan,
                        variant: FlamVariant.danger,
                        size: FlamSize.small,
                        onPressed: () async {
                          final ok = await confirm(
                            context,
                            icon: Icons.block_rounded,
                            title: t.adminBan,
                            message: t.adminBanConfirm(name),
                            action: t.adminBan,
                            destructive: true,
                          );
                          if (!ok || !context.mounted) return;
                          await _act(
                            context,
                            ref,
                            () => repo.banUser(r['reported_id'] as String),
                            () => ref.invalidate(adminReportsProvider),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Framed extends StatelessWidget {
  const _Framed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 4 / 5,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(FlamRadius.md),
      child: ColoredBox(color: FlamColors.glassFill, child: child),
    ),
  );
}

class _Decision extends StatelessWidget {
  const _Decision({
    required this.onApprove,
    required this.onReject,
    this.compact = false,
  });

  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Row(
      children: [
        Expanded(
          child: FlamButton(
            label: compact ? '' : t.adminReject,
            icon: const Icon(Icons.close_rounded),
            variant: FlamVariant.glass,
            size: FlamSize.small,
            onPressed: onReject,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FlamButton(
            label: compact ? '' : t.adminApprove,
            icon: const Icon(Icons.check_rounded),
            size: FlamSize.small,
            onPressed: onApprove,
          ),
        ),
      ],
    );
  }
}

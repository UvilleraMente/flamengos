import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../couple/presentation/couple_page.dart';
import '../../discover/presentation/discover_page.dart';
import '../../notifications/data/notifications_repository.dart';
import '../../notifications/data/push_service.dart';
import '../../notifications/domain/app_notification.dart';
import '../../notifications/presentation/notifications_button.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/presentation/my_profile_page.dart';
import '../../requests/data/requests_repository.dart';
import '../../requests/presentation/requests_page.dart';

/// Navegación principal. Cambia según el estado del flamengo:
/// - libre:      Descubrir · Solicitudes · Perfil
/// - en pareja:  Mi flamengo · Perfil
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // Por si pg_cron no está activo: limpia expiraciones al abrir la app.
    ref.read(requestsRepositoryProvider).housekeeping().ignore();
    // Push: aquí ya existe el perfil (el token se guarda ligado a él).
    WidgetsBinding.instance.addPostFrameCallback((_) => _registerPush());
  }

  void _registerPush() {
    if (!mounted) return;
    ref
        .read(pushServiceProvider)
        .register(locale: Localizations.localeOf(context).languageCode)
        .ignore();
  }

  /// Muestra un aviso en la app cuando llega una notificación nueva.
  Future<void> _toast(AppNotification n) async {
    final t = context.l10n;
    final actor = n.actorId == null
        ? null
        : await ref.read(profileByIdProvider(n.actorId!).future);
    if (!mounted) return;
    showInfo(
      context,
      '${n.emoji}  ${n.text(t, actor?.displayName ?? t.someone)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;

    ref.listen(myProfileProvider.select((p) => p.value?.currentMatchId), (
      before,
      now,
    ) {
      if (before == now) return;
      setState(() => _tab = 0);
      if (before == null && now != null) _celebrate();
    });

    // Si cambia el idioma, las notificaciones push llegan en el nuevo.
    ref.listen(localeProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _registerPush());
    });

    ref.listen(notificationsProvider, (before, now) {
      final seen = before?.value?.map((n) => n.id).toSet();
      if (seen == null) return; // primera carga: no avisar de lo viejo
      final fresh = now.value?.where((n) => n.isUnread && !seen.contains(n.id));
      // La celebración de pareja ya tiene su propio diálogo.
      final toShow = fresh?.where(
        (n) => n.type != NotificationType.requestAccepted,
      );
      if (toShow != null && toShow.isNotEmpty) _toast(toShow.first);
    });

    final paired = ref.watch(
      myProfileProvider.select((p) => p.value?.isPaired ?? false),
    );
    final incoming = ref.watch(liveIncomingCountProvider);

    final tabs = paired
        ? [
            (
              GlassNavItem(icon: Icons.favorite_rounded, label: t.tabCouple),
              const CouplePage(),
            ),
            (
              GlassNavItem(icon: Icons.person_rounded, label: t.tabProfile),
              const MyProfilePage(),
            ),
          ]
        : [
            (
              GlassNavItem(icon: Icons.explore_rounded, label: t.tabDiscover),
              const DiscoverPage(),
            ),
            (
              GlassNavItem(
                icon: Icons.mail_rounded,
                label: t.tabRequests,
                badge: incoming,
              ),
              const RequestsPage(),
            ),
            (
              GlassNavItem(icon: Icons.person_rounded, label: t.tabProfile),
              const MyProfilePage(),
            ),
          ];
    final tab = _tab.clamp(0, tabs.length - 1);

    return Scaffold(
      extendBody: true,
      // IndexedStack conserva el estado de cada pestaña (no recarga al volver).
      body: IndexedStack(
        index: tab,
        children: [for (final (_, page) in tabs) page],
      ),
      bottomNavigationBar: GlassNavBar(
        index: tab,
        onTap: (i) => setState(() => _tab = i),
        items: [for (final (item, _) in tabs) item],
      ),
    );
  }

  void _celebrate() {
    HapticFeedback.heavyImpact();
    showGlassDialog<void>(
      context,
      builder: (context) {
        final t = context.l10n;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Heartbeat(
              scale: 0.15,
              child: Text('🦩💕🦩', style: TextStyle(fontSize: 56)),
            ),
            const SizedBox(height: 12),
            Text(
              t.matchTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 32,
                color: FlamColors.blush,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.matchMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: FlamColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 24),
            FlamButton(
              label: t.matchGoToChat,
              icon: const Icon(Icons.chat_bubble_rounded),
              size: FlamSize.large,
              expand: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}

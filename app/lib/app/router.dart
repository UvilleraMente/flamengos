import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../core/supabase/supabase_providers.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/forgot_password_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/reset_password_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/help/presentation/help_page.dart';
import '../features/premium/presentation/insights_page.dart';
import '../features/admin/presentation/admin_page.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/location/presentation/location_picker_page.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/presentation/profile_form_page.dart';
import '../features/safety/presentation/blocked_users_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/verification/presentation/verification_page.dart';

abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const editProfile = '/profile/edit';
  static const settings = '/settings';
  static const blocked = '/settings/blocked';
  static const verification = '/verification';
  static const help = '/help';
  static const insights = '/insights';
  static const admin = '/admin';

  /// Devuelve un `Place` con `context.push<Place>(Routes.pickLocation, extra: LatLng?)`.
  static const pickLocation = '/location';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(currentUserIdProvider, (_, _) => refresh.value++);
  ref.listen(myProfileProvider, (_, _) => refresh.value++);
  ref.listen(passwordRecoveryProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final here = state.matchedLocation;
      String? goTo(String path) => here == path ? null : path;

      if (ref.read(currentUserIdProvider) == null) {
        // Sin sesión solo se puede entrar o recuperar la contraseña.
        return here == Routes.forgotPassword ? null : goTo(Routes.login);
      }

      // Entró con un enlace/código de recuperación: primero, contraseña nueva.
      if (ref.read(passwordRecoveryProvider)) {
        return goTo(Routes.resetPassword);
      }

      final profile = ref.read(myProfileProvider);
      if (profile.isLoading || profile.hasError) return goTo(Routes.splash);
      if (profile.value == null) return goTo(Routes.onboarding);

      const gates = {
        Routes.login,
        Routes.forgotPassword,
        Routes.resetPassword,
        Routes.splash,
        Routes.onboarding,
      };
      return gates.contains(here) ? Routes.home : null;
    },
    routes: [
      GoRoute(path: Routes.home, builder: (_, _) => const HomeShell()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, state) =>
            ForgotPasswordPage(initialEmail: state.extra as String?),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, _) => const ResetPasswordPage(),
      ),
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const ProfileFormPage(),
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (_, _) =>
            ProfileFormPage(initial: ref.read(myProfileProvider).value),
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsPage()),
      GoRoute(path: Routes.help, builder: (_, _) => const HelpPage()),
      GoRoute(path: Routes.insights, builder: (_, _) => const InsightsPage()),
      GoRoute(path: Routes.admin, builder: (_, _) => const AdminPage()),
      GoRoute(
        path: Routes.blocked,
        builder: (_, _) => const BlockedUsersPage(),
      ),
      GoRoute(
        path: Routes.verification,
        builder: (_, _) => const VerificationPage(),
      ),
      GoRoute(
        path: Routes.pickLocation,
        builder: (_, state) =>
            LocationPickerPage(initial: state.extra as LatLng?),
      ),
    ],
  );
});

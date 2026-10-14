import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/env.dart';
import 'l10n/l10n.dart';

/// Convierte cualquier error en un texto para el usuario, en su idioma.
/// Las funciones SQL lanzan códigos (p. ej. `already_paired`); aquí se traducen.
String describeError(BuildContext context, Object error) {
  final t = context.l10n;
  return switch (error) {
    PostgrestException(:final message) =>
      _serverCode(t, message) ?? t.errorGeneric,
    AuthException(:final message) => switch (message) {
      'Invalid login credentials' => t.errorInvalidCredentials,
      'User already registered' => t.errorEmailTaken,
      'Email not confirmed' => t.errorEmailNotConfirmed,
      _ => message,
    },
    StorageException() => t.errorUpload,
    _ => t.errorGeneric,
  };
}

String? _serverCode(AppLocalizations t, String code) => switch (code) {
  'not_authenticated' => t.errorNotAuthenticated,
  'cannot_request_self' || 'cannot_block_self' => t.errorGeneric,
  'profile_incomplete' => t.errorProfileIncomplete,
  'already_paired' => t.errorAlreadyPaired,
  'target_not_found' || 'target_unavailable' => t.errorTargetUnavailable,
  'target_paired' => t.errorTargetPaired,
  'already_requested' => t.errorAlreadyRequested,
  'max_active_requests' => t.errorMaxActiveRequests(Env.maxActiveRequests),
  'request_not_found' || 'request_unavailable' => t.errorRequestUnavailable,
  'someone_paired' => t.errorSomeonePaired,
  'not_paired' => t.errorNotPaired,
  'no_dissolution_to_cancel' => t.errorNoDissolutionToCancel,
  'verification_pending' => t.errorVerificationPending,
  _ => null,
};

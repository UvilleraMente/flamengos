import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/env.dart';
import '../../../core/supabase/supabase_providers.dart';

/// ¿La cuenta aceptó la versión vigente de las reglas y los términos?
/// (null mientras no hay sesión.)
final termsAcceptedProvider = FutureProvider<bool?>((ref) async {
  if (ref.watch(currentUserIdProvider) == null) return null;
  try {
    final row = await ref
        .watch(supabaseProvider)
        .from('terms_acceptances')
        .select('version')
        .eq('version', Env.termsVersion)
        .maybeSingle();
    return row != null;
  } on PostgrestException catch (e) {
    // Si aún no se ejecutó 0009_terms_consent.sql, no bloquea la app.
    if (e.code == '42P01' || e.code == 'PGRST205') return true;
    rethrow;
  }
});

Future<void> acceptTerms(SupabaseClient db) =>
    db.rpc('accept_terms', params: {'p_version': Env.termsVersion});

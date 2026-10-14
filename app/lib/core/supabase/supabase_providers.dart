import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final _authEventsProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange,
);

/// Id del usuario con sesión, o null. Solo cambia al entrar o salir
/// (no al refrescar el token), así no se reinician los streams.
final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(_authEventsProvider);
  return ref.watch(supabaseProvider).auth.currentUser?.id;
});

/// Para repositorios: id del usuario actual (falla si no hay sesión).
extension SupabaseUserX on SupabaseClient {
  String get myId => auth.currentUser!.id;
}

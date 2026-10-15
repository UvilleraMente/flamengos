import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../profile/domain/profile.dart';
import '../domain/search_filters.dart';

final discoverRepositoryProvider = Provider(
  (ref) => DiscoverRepository(ref.watch(supabaseProvider)),
);

class DiscoverRepository {
  DiscoverRepository(this._db);

  final SupabaseClient _db;

  /// Perfiles compatibles según los filtros guardados, más cercanos primero.
  Future<List<Profile>> discover() async {
    final rows = await _db.rpc('discover') as List;
    return rows
        .map((r) => Profile.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Los 3 "flamengos del día" (se escogen una vez al día en el servidor).
  Future<List<Profile>> dailyPicks() async {
    final rows = await _db.rpc('my_daily_picks') as List;
    return rows
        .map((r) => Profile.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> pass(String targetId) =>
      _db.rpc('pass_profile', params: {'p_target': targetId});

  Future<void> saveFilters(SearchFilters filters) =>
      _db.from('profiles').update(filters.toJson()).eq('id', _db.myId);
}

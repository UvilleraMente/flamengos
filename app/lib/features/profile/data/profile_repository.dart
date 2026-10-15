import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/profile.dart';

final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.watch(supabaseProvider)),
);

final myProfileProvider = StreamProvider<Profile?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(uid);
});

final profileByIdProvider = FutureProvider.family<Profile?, String>(
  (ref, id) => ref.watch(profileRepositoryProvider).fetchProfile(id),
);

class ProfileRepository {
  ProfileRepository(this._db);

  final SupabaseClient _db;

  Stream<Profile?> watchProfile(String id) => _db
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .map((rows) => rows.isEmpty ? null : Profile.fromJson(rows.first));

  Future<Profile?> fetchProfile(String id) async {
    final row = await _db.from('profiles').select().eq('id', id).maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<void> createProfile(Map<String, dynamic> data) =>
      _db.from('profiles').insert({...data, 'id': _db.myId});

  Future<void> updateProfile(Map<String, dynamic> data) =>
      _db.from('profiles').update(data).eq('id', _db.myId);

  /// El servidor la redondea a ~2 km antes de guardarla.
  Future<void> setLocation(LatLng point) => _db.rpc(
    'set_location',
    params: {'p_lat': point.latitude, 'p_lng': point.longitude},
  );

  Future<String> uploadPhoto(XFile file, {String bucket = 'photos'}) async =>
      uploadPhotoBytes(
        await file.readAsBytes(),
        mime: file.mimeType ?? 'image/jpeg',
        bucket: bucket,
      );

  Future<String> uploadPhotoBytes(
    Uint8List bytes, {
    required String mime,
    String bucket = 'photos',
  }) async {
    final ext = switch (mime) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final path = '${_db.myId}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _db.storage
        .from(bucket)
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: mime));
    return path;
  }

  Future<void> deletePhotos(List<String> paths) async {
    if (paths.isEmpty) return;
    await _db.storage.from('photos').remove(paths);
  }
}

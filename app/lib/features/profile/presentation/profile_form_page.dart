import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../../location/presentation/share_location.dart';
import '../../auth/data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../domain/profile.dart';
import 'profile_l10n.dart';
import 'prompts_editor.dart';

const _maxPhotos = 6;

/// Crea el perfil (onboarding, [initial] == null) o lo edita.
class ProfileFormPage extends ConsumerStatefulWidget {
  const ProfileFormPage({super.key, this.initial});

  final Profile? initial;

  @override
  ConsumerState<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends ConsumerState<ProfileFormPage> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.displayName);
  late final _city = TextEditingController(text: widget.initial?.city);
  late final _bio = TextEditingController(text: widget.initial?.bio);
  late DateTime? _birthdate = widget.initial?.birthdate;
  late Gender? _gender = widget.initial?.gender;
  late final Set<Gender> _interestedIn = {...?widget.initial?.interestedIn};
  late final List<String> _photos = [...?widget.initial?.photos];
  late List<ProfilePrompt> _prompts = [...?widget.initial?.prompts];

  /// Ubicación nueva por guardar (se envía al servidor al guardar).
  LatLng? _newLocation;
  bool _locating = false;
  bool _uploading = false;
  bool _saving = false;

  bool get _isNew => widget.initial == null;
  bool get _hasLocation =>
      _newLocation != null || widget.initial?.location != null;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: context.l10n.profileBirthdate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    final found = await locateMe(context, ref);
    if (mounted) {
      setState(() {
        _locating = false;
        if (found == null) return;
        _newLocation = found.point;
        if (found.city != null) _city.text = found.city!;
      });
    }
  }

  Future<void> _addPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1440,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      final path = await ref.read(profileRepositoryProvider).uploadPhoto(file);
      setState(() => _photos.add(path));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    final t = context.l10n;
    final validForm = _form.currentState!.validate();
    final missing = [
      if (_photos.isEmpty) t.profileMissingPhoto,
      if (_birthdate == null) t.profileMissingBirthdate,
      if (_gender == null) t.profileMissingGender,
      if (_interestedIn.isEmpty) t.profileMissingInterest,
    ];
    if (missing.isNotEmpty) {
      showInfo(context, t.profileMissing(missing.join(', ')));
      return;
    }
    if (!validForm) return;

    final data = {
      'display_name': _name.text.trim(),
      'birthdate': DateFormat('yyyy-MM-dd').format(_birthdate!),
      'gender': _gender!.name,
      'interested_in': _interestedIn.map((g) => g.name).toList(),
      'city': _city.text.trim(),
      'bio': _bio.text.trim(),
      'photos': _photos,
      'prompts': [for (final p in _prompts) p.toJson()],
    };

    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);
    try {
      if (_isNew) {
        await repo.createProfile(data);
        if (_newLocation != null) await repo.setLocation(_newLocation!);
        // El router lleva al inicio cuando aparece el perfil.
      } else {
        await repo.updateProfile(data);
        if (_newLocation != null) await repo.setLocation(_newLocation!);
        final removed = widget.initial!.photos
            .where((p) => !_photos.contains(p))
            .toList();
        await repo.deletePhotos(removed);
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? t.profileCreateTitle : t.profileEditTitle),
        actions: [
          if (_isNew)
            TextButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: Text(t.actionSignOut),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                if (_isNew)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      t.profileCreateIntro,
                      style: const TextStyle(
                        color: FlamColors.textMuted,
                        fontSize: 15,
                      ),
                    ),
                  ),
                GlassSection(
                  title: t.profilePhotos,
                  subtitle: t.profilePhotosHint(_maxPhotos),
                  child: _PhotoGrid(
                    photos: _photos,
                    uploading: _uploading,
                    onAdd: _photos.length < _maxPhotos ? _addPhoto : null,
                    onRemove: (p) => setState(() => _photos.remove(p)),
                  ),
                ),
                gap,
                GlassSection(
                  title: t.profileBasics,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: t.profileName,
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                        ),
                        textCapitalization: TextCapitalization.words,
                        maxLength: 40,
                        validator: (v) => (v?.trim().length ?? 0) >= 2
                            ? null
                            : t.profileNameTooShort,
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: _pickBirthdate,
                        borderRadius: BorderRadius.circular(FlamRadius.md),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: t.profileBirthdate,
                            prefixIcon: const Icon(Icons.cake_outlined),
                          ),
                          child: Text(
                            _birthdate == null
                                ? t.actionChoose
                                : '${DateFormat.yMMMMd(context.localeTag).format(_birthdate!)} '
                                      '· ${t.profileAgeYears(ageOn(_birthdate!, DateTime.now()))}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                gap,
                GlassSection(
                  title: t.profileLocation,
                  subtitle: t.profileLocationHint,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _city,
                        decoration: InputDecoration(
                          labelText: t.profileCity,
                          prefixIcon: const Icon(Icons.place_outlined),
                        ),
                        textCapitalization: TextCapitalization.words,
                        maxLength: 60,
                      ),
                      FlamButton(
                        label: _hasLocation
                            ? t.profileLocationShared
                            : t.locationUseMine,
                        icon: Icon(
                          _hasLocation
                              ? Icons.check_circle_rounded
                              : Icons.my_location_rounded,
                        ),
                        variant: FlamVariant.glass,
                        loading: _locating,
                        onPressed: _locate,
                      ),
                    ],
                  ),
                ),
                gap,
                GlassSection(
                  title: t.profileIAm,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final g in Gender.values)
                        FlamChip(
                          label: g.label(t),
                          selected: _gender == g,
                          onTap: () => setState(() => _gender = g),
                        ),
                    ],
                  ),
                ),
                gap,
                GlassSection(
                  title: t.profileLookingFor,
                  subtitle: t.profileLookingForHint,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final g in Gender.values)
                        FlamChip(
                          label: g.plural(t),
                          selected: _interestedIn.contains(g),
                          onTap: () => setState(
                            () => _interestedIn.contains(g)
                                ? _interestedIn.remove(g)
                                : _interestedIn.add(g),
                          ),
                        ),
                    ],
                  ),
                ),
                gap,
                GlassSection(
                  title: t.profileAboutYou,
                  child: TextFormField(
                    controller: _bio,
                    decoration: InputDecoration(hintText: t.profileBioHint),
                    maxLines: 4,
                    maxLength: 500,
                  ),
                ),
                gap,
                GlassSection(
                  title: t.promptsTitle,
                  subtitle: t.promptsSubtitle(maxPrompts),
                  child: PromptsEditor(
                    prompts: _prompts,
                    onChanged: (p) => setState(() => _prompts = p),
                  ),
                ),
                const SizedBox(height: 24),
                FlamButton(
                  label: _isNew ? t.profileStart : t.profileSave,
                  size: FlamSize.large,
                  expand: true,
                  loading: _saving,
                  onPressed: _uploading ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.photos,
    required this.uploading,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photos;
  final bool uploading;
  final VoidCallback? onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final radius = BorderRadius.circular(FlamRadius.md);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3 / 4,
      children: [
        for (final (i, path) in photos.indexed)
          Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(borderRadius: radius, child: FlamImage(photoUrl(path))),
              if (i == 0)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: GlassPill(child: Text(t.profileMainPhoto)),
                ),
              Positioned(
                top: 6,
                right: 6,
                child: FlamIconButton(
                  icon: const Icon(Icons.close_rounded),
                  size: 30,
                  tooltip: t.actionRemove,
                  onPressed: () => onRemove(path),
                ),
              ),
            ],
          ),
        if (onAdd != null)
          InkWell(
            onTap: uploading ? null : onAdd,
            borderRadius: radius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: FlamGradients.glass,
                border: Border.all(
                  color: FlamColors.pink.withValues(alpha: 0.6),
                ),
              ),
              child: Center(
                child: uploading
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_a_photo_rounded,
                            color: FlamColors.pink,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t.actionAdd,
                            style: const TextStyle(color: FlamColors.textMuted),
                          ),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

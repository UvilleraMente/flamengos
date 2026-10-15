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

  Future<void> _photoActions(int index) async {
    final t = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) {
        Widget action(
          IconData icon,
          String label,
          VoidCallback onTap, {
          bool danger = false,
        }) => ListTile(
          leading: Icon(
            icon,
            color: danger ? FlamColors.danger : FlamColors.pink,
          ),
          title: Text(
            label,
            style: TextStyle(color: danger ? FlamColors.danger : null),
          ),
          onTap: () {
            Navigator.pop(sheet);
            onTap();
          },
        );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              action(
                Icons.fullscreen_rounded,
                t.profilePhotoView,
                () => showPhotoViewer(
                  context,
                  _photos.map(photoUrl).toList(),
                  initial: index,
                ),
              ),
              if (index > 0)
                action(
                  Icons.star_rounded,
                  t.profilePhotoMakeMain,
                  () => setState(
                    () => _photos.insert(0, _photos.removeAt(index)),
                  ),
                ),
              action(
                Icons.delete_outline_rounded,
                t.actionRemove,
                () => setState(() => _photos.removeAt(index)),
                danger: true,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickGender() => showChoiceSheet<Gender?>(
    context,
    title: context.l10n.profileIAm,
    options: [for (final g in Gender.values) (g, g.label(context.l10n))],
    selected: _gender,
    onSelected: (g) => setState(() => _gender = g),
  );

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    const gap = SizedBox(height: 26);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? t.profileCreateTitle : t.profileEditTitle),
        actions: [
          if (_isNew)
            TextButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: Text(t.actionSignOut),
            )
          else
            TextButton(
              onPressed: _saving || _uploading ? null : _save,
              child: Text(
                t.actionSave,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 6),
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
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 18),
                    child: Text(
                      t.profileCreateIntro,
                      style: TextStyle(
                        color: FlamColors.textMuted,
                        fontSize: 15,
                      ),
                    ),
                  ),
                SettingsGroup(
                  title: t.profilePhotos,
                  footer: t.profilePhotosHint(_maxPhotos),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: _PhotoGrid(
                        photos: _photos,
                        uploading: _uploading,
                        onAdd: _photos.length < _maxPhotos ? _addPhoto : null,
                        onTap: _photoActions,
                      ),
                    ),
                  ],
                ),
                gap,
                SettingsGroup(
                  title: t.profileBasics,
                  children: [
                    _InlineField(
                      label: t.profileName,
                      controller: _name,
                      maxLength: 40,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => (v?.trim().length ?? 0) >= 2
                          ? null
                          : t.profileNameTooShort,
                    ),
                    _ValueRow(
                      label: t.profileBirthdateShort,
                      value: _birthdate == null
                          ? t.actionChoose
                          : '${DateFormat.yMMMd(context.localeTag).format(_birthdate!)}'
                                ' · ${t.profileAgeYears(ageOn(_birthdate!, DateTime.now()))}',
                      onTap: _pickBirthdate,
                    ),
                    _ValueRow(
                      label: t.profileIAm,
                      value: _gender?.label(t) ?? t.actionChoose,
                      onTap: _pickGender,
                    ),
                  ],
                ),
                gap,
                SettingsGroup(
                  title: t.profileLookingFor,
                  footer: t.profileLookingForHint,
                  children: [
                    for (final g in Gender.values)
                      _ValueRow(
                        label: g.plural(t),
                        onTap: () => setState(
                          () => _interestedIn.contains(g)
                              ? _interestedIn.remove(g)
                              : _interestedIn.add(g),
                        ),
                        trailing: Icon(
                          _interestedIn.contains(g)
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: _interestedIn.contains(g)
                              ? FlamColors.pink
                              : FlamColors.textFaint,
                        ),
                      ),
                  ],
                ),
                gap,
                SettingsGroup(
                  title: t.profileLocation,
                  footer: t.profileLocationHint,
                  children: [
                    _InlineField(
                      label: t.profileCity,
                      controller: _city,
                      maxLength: 60,
                      textCapitalization: TextCapitalization.words,
                    ),
                    _ValueRow(
                      label: _hasLocation
                          ? t.profileLocationShared
                          : t.locationUseMine,
                      onTap: _locating ? null : _locate,
                      trailing: _locating
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _hasLocation
                                  ? Icons.check_circle_rounded
                                  : Icons.my_location_rounded,
                              color: _hasLocation
                                  ? FlamColors.mint
                                  : FlamColors.pink,
                            ),
                    ),
                  ],
                ),
                gap,
                SettingsGroup(
                  title: t.profileAboutMe,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: TextFormField(
                        controller: _bio,
                        decoration: _bare(t.profileBioHint),
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 500,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
                gap,
                SettingsGroup(
                  title: t.promptsTitle,
                  footer: t.promptsSubtitle(maxPrompts),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: PromptsEditor(
                        prompts: _prompts,
                        onChanged: (p) => setState(() => _prompts = p),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
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

/// Campo sin caja, para ir dentro de una fila de grupo.
InputDecoration _bare(String? hint) => InputDecoration(
  hintText: hint,
  filled: false,
  isDense: true,
  counterText: '',
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
  contentPadding: const EdgeInsets.symmetric(vertical: 14),
);

/// Fila "Etiqueta ........ [campo]" como en Contactos de iOS.
class _InlineField extends StatelessWidget {
  const _InlineField({
    required this.label,
    required this.controller,
    this.maxLength,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final int? maxLength;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: _bare(null),
            maxLength: maxLength,
            validator: validator,
            textCapitalization: textCapitalization,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

/// Fila con valor a la derecha (o un ícono) que se toca para cambiarlo.
class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.onTap,
    this.value,
    this.trailing,
  });

  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (value != null)
              Flexible(
                child: Text(
                  value!,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: FlamColors.textMuted),
                ),
              ),
            if (trailing != null)
              trailing!
            else
              Icon(Icons.chevron_right_rounded, color: FlamColors.textFaint),
          ],
        ),
      ),
    ),
  );
}

/// Fotos: la principal grande a la izquierda, dos a su lado y tres abajo.
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.photos,
    required this.uploading,
    required this.onAdd,
    required this.onTap,
  });

  final List<String> photos;
  final bool uploading;
  final VoidCallback? onAdd;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    return LayoutBuilder(
      builder: (context, box) {
        final small = (box.maxWidth - 2 * gap) / 3;
        final smallH = small * 5 / 4;
        Widget slot(int i, double w, double h) =>
            SizedBox(width: w, height: h, child: _slot(context, i));
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                slot(0, small * 2 + gap, smallH * 2 + gap),
                const SizedBox(width: gap),
                Column(
                  children: [
                    slot(1, small, smallH),
                    const SizedBox(height: gap),
                    slot(2, small, smallH),
                  ],
                ),
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: [
                for (var i = 3; i < _maxPhotos; i++) ...[
                  if (i > 3) const SizedBox(width: gap),
                  slot(i, small, smallH),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _slot(BuildContext context, int i) {
    final t = context.l10n;
    final radius = BorderRadius.circular(FlamRadius.md);
    if (i < photos.length) {
      return GestureDetector(
        onTap: () => onTap(i),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: radius,
              child: FlamImage(photoUrl(photos[i])),
            ),
            if (i == 0)
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(FlamRadius.pill),
                  ),
                  child: Text(
                    t.profileMainPhoto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    // Solo el primer hueco libre recibe la foto nueva.
    final next = i == photos.length && onAdd != null;
    return InkWell(
      onTap: next && !uploading ? onAdd : null,
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: FlamColors.glassFill,
          border: Border.all(
            color: next
                ? FlamColors.pink.withValues(alpha: 0.6)
                : FlamColors.glassBorder,
          ),
        ),
        child: Center(
          child: next && uploading
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.add_rounded,
                  color: next ? FlamColors.pink : FlamColors.textFaint,
                ),
        ),
      ),
    );
  }
}

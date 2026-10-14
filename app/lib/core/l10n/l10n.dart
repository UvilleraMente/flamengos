import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  /// Textos traducidos: `context.l10n.discoverTitle`.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Código de idioma activo ('es', 'en') para intl/DateFormat.
  String get localeTag => Localizations.localeOf(this).toLanguageTag();
}

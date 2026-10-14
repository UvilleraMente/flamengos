import '../../../core/l10n/l10n.dart';
import '../data/location_service.dart';

extension LocationProblemL10n on LocationProblem {
  String message(AppLocalizations t) => switch (this) {
    LocationProblem.serviceDisabled => t.locationServiceDisabled,
    LocationProblem.denied => t.locationDenied,
    LocationProblem.deniedForever => t.locationDeniedForever,
  };
}

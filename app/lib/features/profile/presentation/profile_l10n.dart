import '../../../core/l10n/l10n.dart';
import '../domain/profile.dart';

extension GenderL10n on Gender {
  String label(AppLocalizations t) => switch (this) {
    Gender.woman => t.genderWoman,
    Gender.man => t.genderMan,
    Gender.nonbinary => t.genderNonbinary,
  };

  String plural(AppLocalizations t) => switch (this) {
    Gender.woman => t.genderWomenPlural,
    Gender.man => t.genderMenPlural,
    Gender.nonbinary => t.genderNonbinaryPlural,
  };
}

extension PromptKeyL10n on PromptKey {
  String question(AppLocalizations t) => switch (this) {
    PromptKey.idealDate => t.promptIdealDate,
    PromptKey.greenFlag => t.promptGreenFlag,
    PromptKey.song => t.promptSong,
    PromptKey.weekend => t.promptWeekend,
    PromptKey.unpopularOpinion => t.promptUnpopularOpinion,
    PromptKey.lookingFor => t.promptLookingFor,
  };
}

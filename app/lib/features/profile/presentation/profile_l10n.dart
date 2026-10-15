import 'package:flutter/material.dart';

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

extension ProfileTagL10n on ProfileTag {
  String label(AppLocalizations t) => switch (this) {
    ProfileTag.christian => t.tagChristian,
    ProfileTag.catholic => t.tagCatholic,
    ProfileTag.spiritual => t.tagSpiritual,
    ProfileTag.worker => t.tagWorker,
    ProfileTag.student => t.tagStudent,
    ProfileTag.entrepreneur => t.tagEntrepreneur,
    ProfileTag.sports => t.tagSports,
    ProfileTag.gym => t.tagGym,
    ProfileTag.gamer => t.tagGamer,
    ProfileTag.reader => t.tagReader,
    ProfileTag.traveler => t.tagTraveler,
    ProfileTag.foodie => t.tagFoodie,
    ProfileTag.music => t.tagMusic,
    ProfileTag.dance => t.tagDance,
    ProfileTag.pets => t.tagPets,
    ProfileTag.nature => t.tagNature,
    ProfileTag.beach => t.tagBeach,
    ProfileTag.homebody => t.tagHomebody,
    ProfileTag.party => t.tagParty,
    ProfileTag.family => t.tagFamily,
    ProfileTag.wantsKids => t.tagWantsKids,
    ProfileTag.noSmoking => t.tagNoSmoking,
    ProfileTag.noDrinking => t.tagNoDrinking,
    ProfileTag.serious => t.tagSerious,
  };

  IconData get icon => switch (this) {
    ProfileTag.christian => Icons.church_rounded,
    ProfileTag.catholic => Icons.church_rounded,
    ProfileTag.spiritual => Icons.self_improvement_rounded,
    ProfileTag.worker => Icons.work_rounded,
    ProfileTag.student => Icons.school_rounded,
    ProfileTag.entrepreneur => Icons.rocket_launch_rounded,
    ProfileTag.sports => Icons.sports_soccer_rounded,
    ProfileTag.gym => Icons.fitness_center_rounded,
    ProfileTag.gamer => Icons.sports_esports_rounded,
    ProfileTag.reader => Icons.menu_book_rounded,
    ProfileTag.traveler => Icons.flight_rounded,
    ProfileTag.foodie => Icons.restaurant_rounded,
    ProfileTag.music => Icons.music_note_rounded,
    ProfileTag.dance => Icons.nightlife_rounded,
    ProfileTag.pets => Icons.pets_rounded,
    ProfileTag.nature => Icons.forest_rounded,
    ProfileTag.beach => Icons.beach_access_rounded,
    ProfileTag.homebody => Icons.weekend_rounded,
    ProfileTag.party => Icons.celebration_rounded,
    ProfileTag.family => Icons.family_restroom_rounded,
    ProfileTag.wantsKids => Icons.child_care_rounded,
    ProfileTag.noSmoking => Icons.smoke_free_rounded,
    ProfileTag.noDrinking => Icons.no_drinks_rounded,
    ProfileTag.serious => Icons.favorite_rounded,
  };
}

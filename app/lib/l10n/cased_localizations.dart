// GENERADO por tool/gen_text_case.dart — no editar a mano.
// ignore_for_file: type=lint

import 'app_localizations.dart';

/// Traducciones con el formato de letras elegido por el usuario.
class CasedLocalizations extends AppLocalizations {
  CasedLocalizations(this._inner, this._transform) : super(_inner.localeName);

  final AppLocalizations _inner;
  final String Function(String) _transform;

  @override
  String get appName => _transform(_inner.appName);

  @override
  String get tagline => _transform(_inner.tagline);

  @override
  String get someone => _transform(_inner.someone);

  @override
  String get actionAdd => _transform(_inner.actionAdd);

  @override
  String get actionCancel => _transform(_inner.actionCancel);

  @override
  String get actionChange => _transform(_inner.actionChange);

  @override
  String get actionChoose => _transform(_inner.actionChoose);

  @override
  String get actionRemove => _transform(_inner.actionRemove);

  @override
  String get actionRetry => _transform(_inner.actionRetry);

  @override
  String get actionSave => _transform(_inner.actionSave);

  @override
  String get actionSignOut => _transform(_inner.actionSignOut);

  @override
  String get tabDiscover => _transform(_inner.tabDiscover);

  @override
  String get tabRequests => _transform(_inner.tabRequests);

  @override
  String get tabProfile => _transform(_inner.tabProfile);

  @override
  String get tabCouple => _transform(_inner.tabCouple);

  @override
  String get statusSingle => _transform(_inner.statusSingle);

  @override
  String get statusPaired => _transform(_inner.statusPaired);

  @override
  String get authSignInTab => _transform(_inner.authSignInTab);

  @override
  String get authSignUpTab => _transform(_inner.authSignUpTab);

  @override
  String get authEmail => _transform(_inner.authEmail);

  @override
  String get authEmailInvalid => _transform(_inner.authEmailInvalid);

  @override
  String get authPassword => _transform(_inner.authPassword);

  @override
  String get authPasswordTooShort => _transform(_inner.authPasswordTooShort);

  @override
  String get authShowPassword => _transform(_inner.authShowPassword);

  @override
  String get authHidePassword => _transform(_inner.authHidePassword);

  @override
  String get authSignIn => _transform(_inner.authSignIn);

  @override
  String get authCreateAccount => _transform(_inner.authCreateAccount);

  @override
  String get authCheckEmail => _transform(_inner.authCheckEmail);

  @override
  String get authAgeNotice => _transform(_inner.authAgeNotice);

  @override
  String get splashError => _transform(_inner.splashError);

  @override
  String get authForgotPassword => _transform(_inner.authForgotPassword);

  @override
  String get forgotTitle => _transform(_inner.forgotTitle);

  @override
  String get forgotIntro => _transform(_inner.forgotIntro);

  @override
  String get forgotSend => _transform(_inner.forgotSend);

  @override
  String forgotSentMessage(String email) =>
      _transform(_inner.forgotSentMessage(email));

  @override
  String get forgotCode => _transform(_inner.forgotCode);

  @override
  String get forgotVerify => _transform(_inner.forgotVerify);

  @override
  String get forgotInvalidCode => _transform(_inner.forgotInvalidCode);

  @override
  String get forgotResend => _transform(_inner.forgotResend);

  @override
  String forgotResendIn(int seconds) =>
      _transform(_inner.forgotResendIn(seconds));

  @override
  String get forgotChangeEmail => _transform(_inner.forgotChangeEmail);

  @override
  String get resetTitle => _transform(_inner.resetTitle);

  @override
  String get resetNewPassword => _transform(_inner.resetNewPassword);

  @override
  String get resetConfirmPassword => _transform(_inner.resetConfirmPassword);

  @override
  String get resetMismatch => _transform(_inner.resetMismatch);

  @override
  String get resetSave => _transform(_inner.resetSave);

  @override
  String get resetHint => _transform(_inner.resetHint);

  @override
  String get resetDone => _transform(_inner.resetDone);

  @override
  String get deleteAccount => _transform(_inner.deleteAccount);

  @override
  String get deleteAccountTitle => _transform(_inner.deleteAccountTitle);

  @override
  String get deleteAccountMessage => _transform(_inner.deleteAccountMessage);

  @override
  String get deleteAccountWord => _transform(_inner.deleteAccountWord);

  @override
  String deleteAccountTypeHint(String word) =>
      _transform(_inner.deleteAccountTypeHint(word));

  @override
  String get deleteAccountAction => _transform(_inner.deleteAccountAction);

  @override
  String get deleteAccountDone => _transform(_inner.deleteAccountDone);

  @override
  String get genderWoman => _transform(_inner.genderWoman);

  @override
  String get genderMan => _transform(_inner.genderMan);

  @override
  String get genderNonbinary => _transform(_inner.genderNonbinary);

  @override
  String get genderWomenPlural => _transform(_inner.genderWomenPlural);

  @override
  String get genderMenPlural => _transform(_inner.genderMenPlural);

  @override
  String get genderNonbinaryPlural => _transform(_inner.genderNonbinaryPlural);

  @override
  String get timeLessThanMinute => _transform(_inner.timeLessThanMinute);

  @override
  String timeMinutes(int minutes) => _transform(_inner.timeMinutes(minutes));

  @override
  String timeHoursMinutes(int hours, int minutes) =>
      _transform(_inner.timeHoursMinutes(hours, minutes));

  @override
  String get timeJustNow => _transform(_inner.timeJustNow);

  @override
  String timeMinutesAgo(int minutes) =>
      _transform(_inner.timeMinutesAgo(minutes));

  @override
  String timeHoursAgo(int hours) => _transform(_inner.timeHoursAgo(hours));

  @override
  String expiresIn(String time) => _transform(_inner.expiresIn(time));

  @override
  String distanceAway(int km) => _transform(_inner.distanceAway(km));

  @override
  String get discoverTitle => _transform(_inner.discoverTitle);

  @override
  String get discoverActiveRequestsHint =>
      _transform(_inner.discoverActiveRequestsHint);

  @override
  String discoverRequestSent(String name) =>
      _transform(_inner.discoverRequestSent(name));

  @override
  String get discoverLoadError => _transform(_inner.discoverLoadError);

  @override
  String get discoverEmptyTitle => _transform(_inner.discoverEmptyTitle);

  @override
  String get discoverEmptyMessage => _transform(_inner.discoverEmptyMessage);

  @override
  String get discoverAdjustFilters => _transform(_inner.discoverAdjustFilters);

  @override
  String get discoverSearchAgain => _transform(_inner.discoverSearchAgain);

  @override
  String discoverLimitReached(int max) =>
      _transform(_inner.discoverLimitReached(max));

  @override
  String get discoverLocationBanner =>
      _transform(_inner.discoverLocationBanner);

  @override
  String get discoverPass => _transform(_inner.discoverPass);

  @override
  String get discoverRequest => _transform(_inner.discoverRequest);

  @override
  String get discoverViewProfile => _transform(_inner.discoverViewProfile);

  @override
  String get discoverShowMap => _transform(_inner.discoverShowMap);

  @override
  String get discoverShowCards => _transform(_inner.discoverShowCards);

  @override
  String get mapPrivacyNote => _transform(_inner.mapPrivacyNote);

  @override
  String get stampLike => _transform(_inner.stampLike);

  @override
  String get stampPass => _transform(_inner.stampPass);

  @override
  String get stampLimit => _transform(_inner.stampLimit);

  @override
  String get filtersTitle => _transform(_inner.filtersTitle);

  @override
  String get filtersAge => _transform(_inner.filtersAge);

  @override
  String filtersAgeRange(int min, int max) =>
      _transform(_inner.filtersAgeRange(min, max));

  @override
  String get filtersDistance => _transform(_inner.filtersDistance);

  @override
  String filtersUpToKm(int km) => _transform(_inner.filtersUpToKm(km));

  @override
  String get filtersAnyDistance => _transform(_inner.filtersAnyDistance);

  @override
  String get filtersArea => _transform(_inner.filtersArea);

  @override
  String get filtersNearMe => _transform(_inner.filtersNearMe);

  @override
  String get filtersOtherArea => _transform(_inner.filtersOtherArea);

  @override
  String get filtersNeedLocation => _transform(_inner.filtersNeedLocation);

  @override
  String get filtersApply => _transform(_inner.filtersApply);

  @override
  String get locationPickerTitle => _transform(_inner.locationPickerTitle);

  @override
  String get locationSearchHint => _transform(_inner.locationSearchHint);

  @override
  String get locationTapHint => _transform(_inner.locationTapHint);

  @override
  String get locationSelected => _transform(_inner.locationSelected);

  @override
  String get locationUseThisArea => _transform(_inner.locationUseThisArea);

  @override
  String get locationUseMine => _transform(_inner.locationUseMine);

  @override
  String get locationServiceDisabled =>
      _transform(_inner.locationServiceDisabled);

  @override
  String get locationDenied => _transform(_inner.locationDenied);

  @override
  String get locationDeniedForever => _transform(_inner.locationDeniedForever);

  @override
  String get locationUnavailable => _transform(_inner.locationUnavailable);

  @override
  String get requestsTitle => _transform(_inner.requestsTitle);

  @override
  String requestsReceivedTab(int count) =>
      _transform(_inner.requestsReceivedTab(count));

  @override
  String requestsSentTab(int count, int max) =>
      _transform(_inner.requestsSentTab(count, max));

  @override
  String get requestsLoadError => _transform(_inner.requestsLoadError);

  @override
  String get requestsReceivedEmptyTitle =>
      _transform(_inner.requestsReceivedEmptyTitle);

  @override
  String get requestsReceivedEmptyMessage =>
      _transform(_inner.requestsReceivedEmptyMessage);

  @override
  String get requestsSentEmptyTitle =>
      _transform(_inner.requestsSentEmptyTitle);

  @override
  String requestsSentEmptyMessage(int max) =>
      _transform(_inner.requestsSentEmptyMessage(max));

  @override
  String get requestsAccept => _transform(_inner.requestsAccept);

  @override
  String get requestsDecline => _transform(_inner.requestsDecline);

  @override
  String requestsAcceptTitle(String name) =>
      _transform(_inner.requestsAcceptTitle(name));

  @override
  String get requestsAcceptMessage => _transform(_inner.requestsAcceptMessage);

  @override
  String get requestsAcceptAction => _transform(_inner.requestsAcceptAction);

  @override
  String get matchTitle => _transform(_inner.matchTitle);

  @override
  String get matchMessage => _transform(_inner.matchMessage);

  @override
  String get matchGoToChat => _transform(_inner.matchGoToChat);

  @override
  String coupleTogetherSince(int days) =>
      _transform(_inner.coupleTogetherSince(days));

  @override
  String get coupleViewProfile => _transform(_inner.coupleViewProfile);

  @override
  String get coupleEnd => _transform(_inner.coupleEnd);

  @override
  String get coupleEndTitle => _transform(_inner.coupleEndTitle);

  @override
  String coupleEndMessage(String name) =>
      _transform(_inner.coupleEndMessage(name));

  @override
  String get coupleEndAction => _transform(_inner.coupleEndAction);

  @override
  String get coupleYouAskedToEnd => _transform(_inner.coupleYouAskedToEnd);

  @override
  String couplePartnerAskedToEnd(String name) =>
      _transform(_inner.couplePartnerAskedToEnd(name));

  @override
  String coupleDissolvesIn(String time) =>
      _transform(_inner.coupleDissolvesIn(time));

  @override
  String get coupleUndoEnd => _transform(_inner.coupleUndoEnd);

  @override
  String get coupleEndNow => _transform(_inner.coupleEndNow);

  @override
  String get chatLoadError => _transform(_inner.chatLoadError);

  @override
  String get chatEmptyTitle => _transform(_inner.chatEmptyTitle);

  @override
  String get chatEmptyMessage => _transform(_inner.chatEmptyMessage);

  @override
  String get chatHint => _transform(_inner.chatHint);

  @override
  String get chatSend => _transform(_inner.chatSend);

  @override
  String get chatReply => _transform(_inner.chatReply);

  @override
  String get chatEdit => _transform(_inner.chatEdit);

  @override
  String get chatCopy => _transform(_inner.chatCopy);

  @override
  String get chatCopied => _transform(_inner.chatCopied);

  @override
  String get chatEdited => _transform(_inner.chatEdited);

  @override
  String get chatEditing => _transform(_inner.chatEditing);

  @override
  String get chatYou => _transform(_inner.chatYou);

  @override
  String chatReplyingTo(String name) => _transform(_inner.chatReplyingTo(name));

  @override
  String get chatMessageUnavailable =>
      _transform(_inner.chatMessageUnavailable);

  @override
  String chatSeen(String time) => _transform(_inner.chatSeen(time));

  @override
  String get chatSent => _transform(_inner.chatSent);

  @override
  String get chatTyping => _transform(_inner.chatTyping);

  @override
  String get coupleOnline => _transform(_inner.coupleOnline);

  @override
  String get myProfileTitle => _transform(_inner.myProfileTitle);

  @override
  String get myProfileEdit => _transform(_inner.myProfileEdit);

  @override
  String get myProfilePreview => _transform(_inner.myProfilePreview);

  @override
  String get profileCreateTitle => _transform(_inner.profileCreateTitle);

  @override
  String get profileEditTitle => _transform(_inner.profileEditTitle);

  @override
  String get profileCreateIntro => _transform(_inner.profileCreateIntro);

  @override
  String get profilePhotos => _transform(_inner.profilePhotos);

  @override
  String profilePhotosHint(int max) =>
      _transform(_inner.profilePhotosHint(max));

  @override
  String get profileMainPhoto => _transform(_inner.profileMainPhoto);

  @override
  String get profileBasics => _transform(_inner.profileBasics);

  @override
  String get profileName => _transform(_inner.profileName);

  @override
  String get profileNameTooShort => _transform(_inner.profileNameTooShort);

  @override
  String get profileBirthdate => _transform(_inner.profileBirthdate);

  @override
  String profileAgeYears(int age) => _transform(_inner.profileAgeYears(age));

  @override
  String get profileLocation => _transform(_inner.profileLocation);

  @override
  String get profileLocationHint => _transform(_inner.profileLocationHint);

  @override
  String get profileLocationShared => _transform(_inner.profileLocationShared);

  @override
  String get profileCity => _transform(_inner.profileCity);

  @override
  String get profileIAm => _transform(_inner.profileIAm);

  @override
  String get profileLookingFor => _transform(_inner.profileLookingFor);

  @override
  String get profileLookingForHint => _transform(_inner.profileLookingForHint);

  @override
  String get profileAboutYou => _transform(_inner.profileAboutYou);

  @override
  String get profileBioHint => _transform(_inner.profileBioHint);

  @override
  String get profileStart => _transform(_inner.profileStart);

  @override
  String get profileSave => _transform(_inner.profileSave);

  @override
  String profileMissing(String items) =>
      _transform(_inner.profileMissing(items));

  @override
  String get profileMissingPhoto => _transform(_inner.profileMissingPhoto);

  @override
  String get profileMissingBirthdate =>
      _transform(_inner.profileMissingBirthdate);

  @override
  String get profileMissingGender => _transform(_inner.profileMissingGender);

  @override
  String get profileMissingInterest =>
      _transform(_inner.profileMissingInterest);

  @override
  String get promptsTitle => _transform(_inner.promptsTitle);

  @override
  String promptsSubtitle(int max) => _transform(_inner.promptsSubtitle(max));

  @override
  String get promptsAdd => _transform(_inner.promptsAdd);

  @override
  String get promptsChoose => _transform(_inner.promptsChoose);

  @override
  String get promptsPickFirst => _transform(_inner.promptsPickFirst);

  @override
  String get promptsAnswerHint => _transform(_inner.promptsAnswerHint);

  @override
  String get promptsTip => _transform(_inner.promptsTip);

  @override
  String get promptIdealDate => _transform(_inner.promptIdealDate);

  @override
  String get promptGreenFlag => _transform(_inner.promptGreenFlag);

  @override
  String get promptSong => _transform(_inner.promptSong);

  @override
  String get promptWeekend => _transform(_inner.promptWeekend);

  @override
  String get promptUnpopularOpinion =>
      _transform(_inner.promptUnpopularOpinion);

  @override
  String get promptLookingFor => _transform(_inner.promptLookingFor);

  @override
  String get notificationsTitle => _transform(_inner.notificationsTitle);

  @override
  String get notificationsEmptyTitle =>
      _transform(_inner.notificationsEmptyTitle);

  @override
  String get notificationsEmptyMessage =>
      _transform(_inner.notificationsEmptyMessage);

  @override
  String notifRequestReceived(String name) =>
      _transform(_inner.notifRequestReceived(name));

  @override
  String notifRequestAccepted(String name) =>
      _transform(_inner.notifRequestAccepted(name));

  @override
  String notifRequestExpiring(String name) =>
      _transform(_inner.notifRequestExpiring(name));

  @override
  String notifDissolutionRequested(String name) =>
      _transform(_inner.notifDissolutionRequested(name));

  @override
  String notifDissolutionCancelled(String name) =>
      _transform(_inner.notifDissolutionCancelled(name));

  @override
  String notifCoupleDissolved(String name) =>
      _transform(_inner.notifCoupleDissolved(name));

  @override
  String get safetyReportOrBlock => _transform(_inner.safetyReportOrBlock);

  @override
  String reportTitle(String name) => _transform(_inner.reportTitle(name));

  @override
  String get reportSubtitle => _transform(_inner.reportSubtitle);

  @override
  String get reportFakeProfile => _transform(_inner.reportFakeProfile);

  @override
  String get reportInappropriate => _transform(_inner.reportInappropriate);

  @override
  String get reportHarassment => _transform(_inner.reportHarassment);

  @override
  String get reportUnderage => _transform(_inner.reportUnderage);

  @override
  String get reportSpam => _transform(_inner.reportSpam);

  @override
  String get reportOther => _transform(_inner.reportOther);

  @override
  String get reportDetailsHint => _transform(_inner.reportDetailsHint);

  @override
  String get reportAndBlock => _transform(_inner.reportAndBlock);

  @override
  String get blockOnly => _transform(_inner.blockOnly);

  @override
  String get reportSent => _transform(_inner.reportSent);

  @override
  String blockDone(String name) => _transform(_inner.blockDone(name));

  @override
  String get blockedTitle => _transform(_inner.blockedTitle);

  @override
  String get blockedEmptyTitle => _transform(_inner.blockedEmptyTitle);

  @override
  String get blockedEmptyMessage => _transform(_inner.blockedEmptyMessage);

  @override
  String get unblock => _transform(_inner.unblock);

  @override
  String get settingsAppearance => _transform(_inner.settingsAppearance);

  @override
  String get appearanceTheme => _transform(_inner.appearanceTheme);

  @override
  String get themeFirefly => _transform(_inner.themeFirefly);

  @override
  String get themeSpicebug => _transform(_inner.themeSpicebug);

  @override
  String get themeLight => _transform(_inner.themeLight);

  @override
  String get themeDark => _transform(_inner.themeDark);

  @override
  String get themeFireflyHint => _transform(_inner.themeFireflyHint);

  @override
  String get themeSpicebugHint => _transform(_inner.themeSpicebugHint);

  @override
  String get themeLightHint => _transform(_inner.themeLightHint);

  @override
  String get themeDarkHint => _transform(_inner.themeDarkHint);

  @override
  String get settingsLegal => _transform(_inner.settingsLegal);

  @override
  String get settingsMadeBy => _transform(_inner.settingsMadeBy);

  @override
  String get appearanceFont => _transform(_inner.appearanceFont);

  @override
  String get appearanceTextSize => _transform(_inner.appearanceTextSize);

  @override
  String get appearanceTextCase => _transform(_inner.appearanceTextCase);

  @override
  String get textCaseNormal => _transform(_inner.textCaseNormal);

  @override
  String get textCaseUpper => _transform(_inner.textCaseUpper);

  @override
  String get textCaseLower => _transform(_inner.textCaseLower);

  @override
  String get textCaseTitle => _transform(_inner.textCaseTitle);

  @override
  String coupleMapTitle(int km) => _transform(_inner.coupleMapTitle(km));

  @override
  String get helpTitle => _transform(_inner.helpTitle);

  @override
  String get helpSubtitle => _transform(_inner.helpSubtitle);

  @override
  String get helpContact => _transform(_inner.helpContact);

  @override
  String get legalTerms => _transform(_inner.legalTerms);

  @override
  String get legalPrivacy => _transform(_inner.legalPrivacy);

  @override
  String get faqExclusiveQ => _transform(_inner.faqExclusiveQ);

  @override
  String get faqExclusiveA => _transform(_inner.faqExclusiveA);

  @override
  String get faqRequestsQ => _transform(_inner.faqRequestsQ);

  @override
  String get faqRequestsA => _transform(_inner.faqRequestsA);

  @override
  String get faqAcceptQ => _transform(_inner.faqAcceptQ);

  @override
  String get faqAcceptA => _transform(_inner.faqAcceptA);

  @override
  String get faqEndQ => _transform(_inner.faqEndQ);

  @override
  String get faqEndA => _transform(_inner.faqEndA);

  @override
  String get faqLocationQ => _transform(_inner.faqLocationQ);

  @override
  String get faqLocationA => _transform(_inner.faqLocationA);

  @override
  String get faqSafetyQ => _transform(_inner.faqSafetyQ);

  @override
  String get faqSafetyA => _transform(_inner.faqSafetyA);

  @override
  String get faqVerifyQ => _transform(_inner.faqVerifyQ);

  @override
  String get faqVerifyA => _transform(_inner.faqVerifyA);

  @override
  String get faqDeleteQ => _transform(_inner.faqDeleteQ);

  @override
  String get faqDeleteA => _transform(_inner.faqDeleteA);

  @override
  String get settingsTitle => _transform(_inner.settingsTitle);

  @override
  String get settingsLanguage => _transform(_inner.settingsLanguage);

  @override
  String get languageSystem => _transform(_inner.languageSystem);

  @override
  String get settingsVerification => _transform(_inner.settingsVerification);

  @override
  String get lockTitle => _transform(_inner.lockTitle);

  @override
  String get lockMessage => _transform(_inner.lockMessage);

  @override
  String get lockUnlock => _transform(_inner.lockUnlock);

  @override
  String get lockReason => _transform(_inner.lockReason);

  @override
  String get lockSetting => _transform(_inner.lockSetting);

  @override
  String get lockSettingHint => _transform(_inner.lockSettingHint);

  @override
  String get lockMobileOnly => _transform(_inner.lockMobileOnly);

  @override
  String get lockPasswordTitle => _transform(_inner.lockPasswordTitle);

  @override
  String get lockPasswordMessage => _transform(_inner.lockPasswordMessage);

  @override
  String get lockEnable => _transform(_inner.lockEnable);

  @override
  String get loginBiometric => _transform(_inner.loginBiometric);

  @override
  String get lockUnavailable => _transform(_inner.lockUnavailable);

  @override
  String get settingsSafety => _transform(_inner.settingsSafety);

  @override
  String get settingsAccount => _transform(_inner.settingsAccount);

  @override
  String get premiumTitle => _transform(_inner.premiumTitle);

  @override
  String get premiumFounder => _transform(_inner.premiumFounder);

  @override
  String premiumUntil(String date) => _transform(_inner.premiumUntil(date));

  @override
  String get premiumPerksTitle => _transform(_inner.premiumPerksTitle);

  @override
  String get premiumFree => _transform(_inner.premiumFree);

  @override
  String get premiumComingSoon => _transform(_inner.premiumComingSoon);

  @override
  String premiumPerkRequests(int count) =>
      _transform(_inner.premiumPerkRequests(count));

  @override
  String get premiumPerkIncognito => _transform(_inner.premiumPerkIncognito);

  @override
  String get premiumPerkSeen => _transform(_inner.premiumPerkSeen);

  @override
  String get premiumPerkTyping => _transform(_inner.premiumPerkTyping);

  @override
  String get premiumIncognitoHint => _transform(_inner.premiumIncognitoHint);

  @override
  String get premiumOnly => _transform(_inner.premiumOnly);

  @override
  String get verifiedBadge => _transform(_inner.verifiedBadge);

  @override
  String get verificationCta => _transform(_inner.verificationCta);

  @override
  String get verificationPendingShort =>
      _transform(_inner.verificationPendingShort);

  @override
  String get verificationApprovedShort =>
      _transform(_inner.verificationApprovedShort);

  @override
  String get verificationStatusApproved =>
      _transform(_inner.verificationStatusApproved);

  @override
  String get verificationStatusPending =>
      _transform(_inner.verificationStatusPending);

  @override
  String get verificationStatusRejected =>
      _transform(_inner.verificationStatusRejected);

  @override
  String get verificationTitle => _transform(_inner.verificationTitle);

  @override
  String get verificationIntro => _transform(_inner.verificationIntro);

  @override
  String get verificationTakeSelfie =>
      _transform(_inner.verificationTakeSelfie);

  @override
  String get verificationPrivacy => _transform(_inner.verificationPrivacy);

  @override
  String get verificationSent => _transform(_inner.verificationSent);

  @override
  String get verificationPendingTitle =>
      _transform(_inner.verificationPendingTitle);

  @override
  String get verificationPendingMessage =>
      _transform(_inner.verificationPendingMessage);

  @override
  String get verificationApprovedTitle =>
      _transform(_inner.verificationApprovedTitle);

  @override
  String get verificationApprovedMessage =>
      _transform(_inner.verificationApprovedMessage);

  @override
  String get verificationRejectedMessage =>
      _transform(_inner.verificationRejectedMessage);

  @override
  String get posePeace => _transform(_inner.posePeace);

  @override
  String get poseThumbsUp => _transform(_inner.poseThumbsUp);

  @override
  String get poseOpenHand => _transform(_inner.poseOpenHand);

  @override
  String get posePointUp => _transform(_inner.posePointUp);

  @override
  String get errorGeneric => _transform(_inner.errorGeneric);

  @override
  String get errorUpload => _transform(_inner.errorUpload);

  @override
  String get errorInvalidCredentials =>
      _transform(_inner.errorInvalidCredentials);

  @override
  String get errorEmailTaken => _transform(_inner.errorEmailTaken);

  @override
  String get errorEmailNotConfirmed =>
      _transform(_inner.errorEmailNotConfirmed);

  @override
  String get errorNotAuthenticated => _transform(_inner.errorNotAuthenticated);

  @override
  String get errorProfileIncomplete =>
      _transform(_inner.errorProfileIncomplete);

  @override
  String get errorAlreadyPaired => _transform(_inner.errorAlreadyPaired);

  @override
  String get errorTargetUnavailable =>
      _transform(_inner.errorTargetUnavailable);

  @override
  String get errorTargetPaired => _transform(_inner.errorTargetPaired);

  @override
  String get errorAlreadyRequested => _transform(_inner.errorAlreadyRequested);

  @override
  String errorMaxActiveRequests(int max) =>
      _transform(_inner.errorMaxActiveRequests(max));

  @override
  String get errorRequestUnavailable =>
      _transform(_inner.errorRequestUnavailable);

  @override
  String get errorSomeonePaired => _transform(_inner.errorSomeonePaired);

  @override
  String get errorNotPaired => _transform(_inner.errorNotPaired);

  @override
  String get errorNoDissolutionToCancel =>
      _transform(_inner.errorNoDissolutionToCancel);

  @override
  String get errorEditWindowClosed => _transform(_inner.errorEditWindowClosed);

  @override
  String get errorVerificationPending =>
      _transform(_inner.errorVerificationPending);
}

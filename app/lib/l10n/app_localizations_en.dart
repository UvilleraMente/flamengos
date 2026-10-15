// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Flamengos';

  @override
  String get tagline => 'Flirt with many. Pair with one.';

  @override
  String get someone => 'Someone';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionChange => 'Change';

  @override
  String get actionChoose => 'Choose';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get tabDiscover => 'Discover';

  @override
  String get tabRequests => 'Requests';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabCouple => 'My flamingo';

  @override
  String get statusSingle => 'Single';

  @override
  String get statusPaired => 'Paired';

  @override
  String get authSignInTab => 'Sign in';

  @override
  String get authSignUpTab => 'Sign up';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailInvalid => 'Enter a valid email';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordTooShort => 'At least 6 characters';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authCreateAccount => 'Create my account';

  @override
  String get authCheckEmail => 'We sent you an email to confirm your account.';

  @override
  String get authAgeNotice =>
      'By continuing you confirm you are 18 or older and accept the Terms and Privacy Policy.';

  @override
  String get splashError => 'We couldn\'t load your profile';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get forgotTitle => 'Reset password';

  @override
  String get forgotIntro =>
      'Enter your email and we\'ll send you a code to create a new password.';

  @override
  String get forgotSend => 'Send code';

  @override
  String forgotSentMessage(String email) {
    return 'Check $email. Enter the 6-digit code or open the link in the email.';
  }

  @override
  String get forgotCode => 'Code';

  @override
  String get forgotVerify => 'Verify';

  @override
  String get forgotInvalidCode => 'Wrong or expired code.';

  @override
  String get forgotResend => 'Resend code';

  @override
  String forgotResendIn(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String get forgotChangeEmail => 'Use another email';

  @override
  String get resetTitle => 'Create your new password';

  @override
  String get resetNewPassword => 'New password';

  @override
  String get resetConfirmPassword => 'Repeat the password';

  @override
  String get resetMismatch => 'Passwords don\'t match';

  @override
  String get resetSave => 'Save password';

  @override
  String get resetHint => 'You\'ll go straight into your account afterwards.';

  @override
  String get resetDone => 'Password updated';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountMessage =>
      'Your profile, photos, requests and chats will be erased. If you have a pair, it ends immediately. This can\'t be undone.';

  @override
  String get deleteAccountWord => 'DELETE';

  @override
  String deleteAccountTypeHint(String word) {
    return 'Type $word to confirm';
  }

  @override
  String get deleteAccountAction => 'Delete forever';

  @override
  String get deleteAccountDone => 'Your account was deleted. Fly safe!';

  @override
  String get genderWoman => 'Woman';

  @override
  String get genderMan => 'Man';

  @override
  String get genderNonbinary => 'Non-binary';

  @override
  String get genderWomenPlural => 'Women';

  @override
  String get genderMenPlural => 'Men';

  @override
  String get genderNonbinaryPlural => 'Non-binary people';

  @override
  String get timeLessThanMinute => 'less than 1 min';

  @override
  String timeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String timeHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String expiresIn(String time) {
    return 'Expires in $time';
  }

  @override
  String distanceAway(int km) {
    return '$km km away';
  }

  @override
  String get discoverTitle => 'Discover';

  @override
  String get discoverActiveRequestsHint =>
      'Sent requests waiting for an answer';

  @override
  String discoverRequestSent(String name) {
    return 'Request sent to $name. They have 48 h to answer.';
  }

  @override
  String get discoverLoadError => 'We couldn\'t load profiles';

  @override
  String get discoverEmptyTitle => 'No more flamingos for now';

  @override
  String get discoverEmptyMessage => 'Widen your filters or come back later.';

  @override
  String get discoverAdjustFilters => 'Adjust filters';

  @override
  String get discoverSearchAgain => 'Search again';

  @override
  String get discoverBoosted =>
      'You have a boost: for 24 h you will show up first to others. Improve your profile to make the most of it.';

  @override
  String discoverLimitReached(int max) {
    return 'You have $max requests waiting. Wait for an answer or cancel one to send another.';
  }

  @override
  String get discoverLocationBanner =>
      'Share your location to see flamingos near you.';

  @override
  String get discoverPass => 'Not interested';

  @override
  String get discoverRequest => 'Ask to pair';

  @override
  String get discoverViewProfile => 'View profile';

  @override
  String get discoverShowMap => 'Show map';

  @override
  String get discoverShowCards => 'Show cards';

  @override
  String get mapPrivacyNote => 'Approximate locations (~2 km)';

  @override
  String get stampLike => 'PAIR';

  @override
  String get stampPass => 'PASS';

  @override
  String get stampLimit => 'LIMIT';

  @override
  String get filtersTitle => 'Search filters';

  @override
  String get filtersAge => 'Age';

  @override
  String filtersAgeRange(int min, int max) {
    return '$min–$max years';
  }

  @override
  String get filtersDistance => 'Distance';

  @override
  String filtersUpToKm(int km) {
    return 'Up to $km km';
  }

  @override
  String get filtersAnyDistance => 'Any distance';

  @override
  String get filtersArea => 'Area';

  @override
  String get filtersNearMe => 'Near me';

  @override
  String get filtersOtherArea => 'Another area';

  @override
  String get filtersNeedLocation =>
      'To search near you, share your location from Discover or your profile.';

  @override
  String get filtersApply => 'Apply filters';

  @override
  String get locationPickerTitle => 'Choose an area';

  @override
  String get locationSearchHint => 'Search a city or place…';

  @override
  String get locationTapHint => 'Tap the map or search a place';

  @override
  String get locationSelected => 'Selected area';

  @override
  String get locationUseThisArea => 'Search in this area';

  @override
  String get locationUseMine => 'Use my location';

  @override
  String get locationServiceDisabled => 'Turn on your device\'s location.';

  @override
  String get locationDenied =>
      'We need location permission to search near you.';

  @override
  String get locationDeniedForever =>
      'Location permission is blocked. Turn it on in your device settings.';

  @override
  String get locationUnavailable => 'We couldn\'t get your location.';

  @override
  String get requestsTitle => 'Requests';

  @override
  String requestsReceivedTab(int count) {
    return 'Received · $count';
  }

  @override
  String requestsSentTab(int count, int max) {
    return 'Sent · $count/$max';
  }

  @override
  String get requestsLoadError => 'We couldn\'t load your requests';

  @override
  String get requestsReceivedEmptyTitle => 'No one has asked you yet';

  @override
  String get requestsReceivedEmptyMessage =>
      'When someone does, you\'ll have 48 h to answer.';

  @override
  String get requestsSentEmptyTitle => 'You haven\'t sent any requests';

  @override
  String requestsSentEmptyMessage(int max) {
    return 'Ask someone from Discover. You can have up to $max waiting for an answer.';
  }

  @override
  String get requestsAccept => 'Accept';

  @override
  String get requestsDecline => 'Decline';

  @override
  String requestsAcceptTitle(String name) {
    return 'Pair with $name?';
  }

  @override
  String get requestsAcceptMessage =>
      'You\'ll be exclusive: all your other requests, sent and received, will be cancelled. If one of you later wants to end it, the pair dissolves in 12 h.';

  @override
  String get requestsAcceptAction => 'Accept';

  @override
  String get matchTitle => 'You\'re a pair!';

  @override
  String get matchMessage =>
      'You\'re exclusive now: your other requests were cancelled. Say hi and get to know each other.';

  @override
  String get matchGoToChat => 'Go to chat';

  @override
  String coupleTogetherSince(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Together for $days days',
      one: 'Together since yesterday',
      zero: 'Together since today',
    );
    return '$_temp0';
  }

  @override
  String get coupleViewProfile => 'View their profile';

  @override
  String get coupleEnd => 'End pair';

  @override
  String get coupleEndTitle => 'End the pair?';

  @override
  String coupleEndMessage(String name) {
    return 'It will dissolve in 12 h, unless $name also wants to end it (then it\'s immediate). You can change your mind before time runs out.';
  }

  @override
  String get coupleEndAction => 'End it';

  @override
  String get coupleYouAskedToEnd => 'You asked to end it';

  @override
  String couplePartnerAskedToEnd(String name) {
    return '$name wants to end it';
  }

  @override
  String coupleDissolvesIn(String time) {
    return 'Dissolves in $time';
  }

  @override
  String get coupleUndoEnd => 'I changed my mind';

  @override
  String get coupleEndNow => 'End now';

  @override
  String get chatLoadError => 'We couldn\'t load the chat';

  @override
  String get chatEmptyTitle => 'Break the ice';

  @override
  String get chatEmptyMessage =>
      'You\'re exclusive: it\'s just the two of you here.';

  @override
  String get chatHint => 'Write something sweet…';

  @override
  String get chatSend => 'Send';

  @override
  String get chatReply => 'Reply';

  @override
  String get chatEdit => 'Edit';

  @override
  String get chatCopy => 'Copy';

  @override
  String get chatCopied => 'Copied';

  @override
  String get chatEdited => 'edited';

  @override
  String get chatEditing => 'Editing message';

  @override
  String get chatYou => 'You';

  @override
  String chatReplyingTo(String name) {
    return 'Replying to $name';
  }

  @override
  String get chatMessageUnavailable => 'Message unavailable';

  @override
  String chatSeen(String time) {
    return 'Seen $time';
  }

  @override
  String get chatSent => 'Sent';

  @override
  String get chatTyping => 'typing…';

  @override
  String get coupleOnline => 'Online';

  @override
  String get myProfileTitle => 'My profile';

  @override
  String get myProfileEdit => 'Edit profile';

  @override
  String get tipPhotos =>
      'Add at least 3 photos: profiles with more photos get more requests.';

  @override
  String get tipBio =>
      'Write something about yourself: it is the first thing people read.';

  @override
  String get tipPrompts =>
      'Answer a question: it gives people something to talk about.';

  @override
  String get tipTags =>
      'Pick your tags to show up first to people who share your interests.';

  @override
  String get myProfilePreview => 'See it as others do';

  @override
  String get profileCreateTitle => 'Create your profile';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileCreateIntro =>
      'Tell the world who you are. A good profile gets more requests';

  @override
  String get profilePhotos => 'Photos';

  @override
  String profilePhotosHint(int max) {
    return 'The first one is your main photo · up to $max';
  }

  @override
  String get profilePhotoView => 'View photo';

  @override
  String get profilePhotoMakeMain => 'Make main photo';

  @override
  String get photoCropTitle => 'Adjust your photo';

  @override
  String get photoCropHint => 'Drag and pinch to frame it.';

  @override
  String get photoCropUse => 'Use photo';

  @override
  String get tagChristian => 'Christian faith';

  @override
  String get tagCatholic => 'Catholic faith';

  @override
  String get tagSpiritual => 'Spiritual';

  @override
  String get tagWorker => 'Working';

  @override
  String get tagStudent => 'Studying';

  @override
  String get tagEntrepreneur => 'Entrepreneur';

  @override
  String get tagSports => 'Sports';

  @override
  String get tagGym => 'Gym';

  @override
  String get tagGamer => 'Gaming';

  @override
  String get tagReader => 'Reading';

  @override
  String get tagTraveler => 'Travel';

  @override
  String get tagFoodie => 'Good food';

  @override
  String get tagMusic => 'Music';

  @override
  String get tagDance => 'Dancing';

  @override
  String get tagPets => 'Pets';

  @override
  String get tagNature => 'Nature';

  @override
  String get tagBeach => 'Beach';

  @override
  String get tagHomebody => 'Nights in';

  @override
  String get tagParty => 'Going out';

  @override
  String get tagFamily => 'Family';

  @override
  String get tagWantsKids => 'Wants kids';

  @override
  String get tagNoSmoking => 'Non-smoker';

  @override
  String get tagNoDrinking => 'Doesn\'t drink';

  @override
  String get tagSerious => 'Serious relationship';

  @override
  String get tagsTitle => 'Tags';

  @override
  String tagsHint(int max) {
    return 'Pick up to $max. People who share yours show up first.';
  }

  @override
  String get tagsMustTitle => 'Must-haves';

  @override
  String tagsMustHint(int max) {
    return 'You\'ll only see people with these tags (up to $max).';
  }

  @override
  String tagsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in common',
      one: '1 in common',
    );
    return '$_temp0';
  }

  @override
  String get profileMainPhoto => 'Main';

  @override
  String get profileBasics => 'The basics';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameTooShort => 'At least 2 characters';

  @override
  String get profileBirthdate => 'Date of birth';

  @override
  String get profileBirthdateShort => 'Birthday';

  @override
  String profileAgeYears(int age) {
    return '$age years old';
  }

  @override
  String get profileLocation => 'Location';

  @override
  String get profileLocationHint =>
      'Only an approximate area (~2 km) is saved, never your exact location.';

  @override
  String get profileLocationShared => 'Location shared';

  @override
  String get profileCity => 'City';

  @override
  String get profileIAm => 'I am';

  @override
  String get profileLookingFor => 'Looking for';

  @override
  String get profileLookingForHint => 'You can pick more than one';

  @override
  String get profileAboutMe => 'About me';

  @override
  String get profileAboutYou => 'About you';

  @override
  String get profileBioHint =>
      'What makes you smile, your ideal plan, your song…';

  @override
  String get profileStart => 'Start flying';

  @override
  String get profileSave => 'Save changes';

  @override
  String profileMissing(String items) {
    return 'Missing $items.';
  }

  @override
  String get profileMissingPhoto => 'at least one photo';

  @override
  String get profileMissingBirthdate => 'your date of birth';

  @override
  String get profileMissingGender => 'your gender';

  @override
  String get profileMissingInterest => 'who you\'re looking for';

  @override
  String get promptsTitle => 'Prompts';

  @override
  String promptsSubtitle(int max) {
    return 'Great conversation starters · up to $max';
  }

  @override
  String get promptsAdd => 'Add a prompt';

  @override
  String get promptsChoose => 'Choose a prompt';

  @override
  String get promptsPickFirst => 'Choose a prompt first';

  @override
  String get promptsAnswerHint => 'Your answer…';

  @override
  String get promptsTip => 'Specific, funny answers work best.';

  @override
  String get promptIdealDate => 'My ideal date is…';

  @override
  String get promptGreenFlag => 'A green flag for me is…';

  @override
  String get promptSong => 'The song I can\'t stop playing…';

  @override
  String get promptWeekend => 'A perfect Sunday is…';

  @override
  String get promptUnpopularOpinion => 'My unpopular opinion is…';

  @override
  String get promptLookingFor => 'I\'m looking for someone who…';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmptyTitle => 'All quiet';

  @override
  String get notificationsEmptyMessage =>
      'Requests, pairs and alerts will show up here.';

  @override
  String notifRequestReceived(String name) {
    return '$name asked you to pair';
  }

  @override
  String notifRequestAccepted(String name) {
    return '$name accepted to be your pair';
  }

  @override
  String notifRequestExpiring(String name) {
    return '$name\'s request expires soon';
  }

  @override
  String notifDissolutionRequested(String name) {
    return '$name wants to end the pair';
  }

  @override
  String notifDissolutionCancelled(String name) {
    return '$name changed their mind: you\'re still together';
  }

  @override
  String get notifPhotoRejected =>
      'We removed one of your photos because it breaks the rules.';

  @override
  String get notifBoostStarted =>
      'Your profile has a 24 h boost: you will show up first in Discover.';

  @override
  String notifCoupleDissolved(String name) {
    return 'Your pair with $name ended';
  }

  @override
  String get safetyReportOrBlock => 'Report or block';

  @override
  String reportTitle(String name) {
    return 'Report $name';
  }

  @override
  String get reportSubtitle =>
      'We won\'t tell them. Reporting also blocks them: you won\'t see each other again.';

  @override
  String get reportFakeProfile => 'Fake profile';

  @override
  String get reportInappropriate => 'Inappropriate content';

  @override
  String get reportHarassment => 'Harassment';

  @override
  String get reportUnderage => 'Underage';

  @override
  String get reportSpam => 'Spam or scam';

  @override
  String get reportOther => 'Other';

  @override
  String get reportDetailsHint => 'Tell us more (optional)';

  @override
  String get reportAndBlock => 'Report and block';

  @override
  String get blockOnly => 'Just block';

  @override
  String get reportSent => 'Thanks. We\'ll review the report.';

  @override
  String blockDone(String name) {
    return 'You blocked $name.';
  }

  @override
  String get blockedTitle => 'Blocked users';

  @override
  String get blockedEmptyTitle => 'You haven\'t blocked anyone';

  @override
  String get blockedEmptyMessage =>
      'If you block someone, they\'ll show up here.';

  @override
  String get unblock => 'Unblock';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get appearanceTheme => 'Theme';

  @override
  String get themeFirefly => 'Firefly';

  @override
  String get themeSpicebug => 'Spicebug';

  @override
  String get themeLight => 'Cricket';

  @override
  String get themeDark => 'Cricket';

  @override
  String get themeFireflyHint => 'Pink night';

  @override
  String get themeSpicebugHint => 'Deep green';

  @override
  String get themeLightHint => 'Light';

  @override
  String get themeDarkHint => 'Dark';

  @override
  String get settingsLegal => 'Help & legal';

  @override
  String get settingsMadeBy => 'Flamengos · CreativeMinds by Andresnael';

  @override
  String get appearanceFont => 'Font';

  @override
  String get appearanceTextSize => 'Text size';

  @override
  String get appearanceTextCase => 'Letter case';

  @override
  String get textCaseNormal => 'Normal';

  @override
  String get textCaseUpper => 'UPPERCASE';

  @override
  String get textCaseLower => 'lowercase';

  @override
  String get textCaseTitle => 'Title Case';

  @override
  String coupleMapTitle(int km) {
    return 'You\'re $km km apart';
  }

  @override
  String get helpTitle => 'Help';

  @override
  String get helpSubtitle => 'FAQ and contact';

  @override
  String get helpContact => 'Contact us';

  @override
  String get legalTerms => 'Terms';

  @override
  String get legalPrivacy => 'Privacy';

  @override
  String get faqExclusiveQ => 'How does exclusivity work?';

  @override
  String get faqExclusiveA =>
      'You can ask several flamingos to pair, but once someone accepts (or you accept), you\'re paired only with each other. While paired, you don\'t show up in Discover and can\'t receive requests.';

  @override
  String get faqRequestsQ => 'How many requests can I send?';

  @override
  String get faqRequestsA =>
      'Up to 3 at a time. Each one expires after 48 hours without an answer, and you can cancel it earlier if you get tired of waiting.';

  @override
  String get faqAcceptQ => 'What happens when I accept someone?';

  @override
  String get faqAcceptA =>
      'You become a pair and all your other requests, sent and received, are cancelled automatically.';

  @override
  String get faqEndQ => 'How do I end a pair?';

  @override
  String get faqEndA =>
      'From your pair\'s menu. If only one of you wants to end it, it dissolves in 12 hours (and you can change your mind before). If you both want to, it\'s immediate.';

  @override
  String get faqLocationQ => 'Who can see my location?';

  @override
  String get faqLocationA =>
      'We only store an approximate area (about 2 km), never your exact location. Others see an approximate distance and an approximate point on the map.';

  @override
  String get faqSafetyQ => 'How do I report or block someone?';

  @override
  String get faqSafetyA =>
      'Open their profile and tap \"Report or block\". We won\'t tell them. Once blocked, you stop seeing each other and, if you were a pair, it ends immediately.';

  @override
  String get faqVerifyQ => 'Why should I get verified?';

  @override
  String get faqVerifyA =>
      'Your profile shows a badge confirming it\'s really you. You take a selfie copying a pose and a moderator compares it with your photos.';

  @override
  String get faqDeleteQ => 'How do I delete my account?';

  @override
  String get faqDeleteA =>
      'In Settings → Account → Delete account. Your profile, photos, requests and chats are erased. This can\'t be undone.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Device default';

  @override
  String get settingsVerification => 'Verification';

  @override
  String get lockTitle => 'Flamengos is locked';

  @override
  String get lockMessage =>
      'Use your fingerprint, face or phone PIN to get in.';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockReason => 'Unlock Flamengos';

  @override
  String get lockSetting => 'Fingerprint or face lock';

  @override
  String get lockSettingHint => 'Asked when you open the app.';

  @override
  String get lockMobileOnly => 'Available in the Android and iOS app.';

  @override
  String get lockPasswordTitle => 'Confirm your password';

  @override
  String get lockPasswordMessage =>
      'It is stored encrypted on this phone so you can sign in with your fingerprint or face.';

  @override
  String get lockEnable => 'Turn on';

  @override
  String get loginBiometric => 'Sign in with fingerprint or face';

  @override
  String get lockUnavailable =>
      'This phone has no fingerprint, face or PIN set up.';

  @override
  String get settingsSafety => 'Safety';

  @override
  String get settingsAccount => 'Account';

  @override
  String get insightsTitle => 'My stats';

  @override
  String get insightsLocked =>
      'With Premium you see your time in the app, your connections, how long your pairs lasted and why they ended.';

  @override
  String get insightsTime => 'Time in the app';

  @override
  String get insightsToday => 'Today';

  @override
  String get insights7d => '7 days';

  @override
  String get insights30d => '30 days';

  @override
  String get insightsConnections => 'Connections';

  @override
  String get insightsSent => 'Sent';

  @override
  String get insightsReceived => 'Received';

  @override
  String get insightsAccepted => 'Accepted you';

  @override
  String get insightsDeclined => 'Declined';

  @override
  String get insightsExpired => 'Expired';

  @override
  String get insightsYouAccepted => 'You accepted';

  @override
  String insightsAcceptRate(int pct) {
    return '$pct% of your resolved requests get accepted.';
  }

  @override
  String get insightsCouples => 'Pairs';

  @override
  String get insightsAverage => 'Average';

  @override
  String get insightsLongest => 'Longest';

  @override
  String get insightsWhyEnded => 'Why they ended';

  @override
  String get insightsHistory => 'History';

  @override
  String get insightsOngoing => 'ongoing';

  @override
  String get insightsEmptyCouples =>
      'You have not been paired on Flamengos yet.';

  @override
  String durMinutes(int n) {
    return '$n min';
  }

  @override
  String durHours(int n) {
    return '$n h';
  }

  @override
  String durDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get endNoChemistry => 'No chemistry';

  @override
  String get endDifferentGoals => 'We wanted different things';

  @override
  String get endDistance => 'Distance';

  @override
  String get endCommunication => 'Poor communication';

  @override
  String get endMetSomeone => 'I met someone else';

  @override
  String get endDisrespect => 'Disrespect';

  @override
  String get endOther => 'Other reason';

  @override
  String get endSurveyTitle => 'Why are you ending it?';

  @override
  String get endSurveyMessage =>
      'It is private: only you will see it in your stats.';

  @override
  String get endSurveySkip => 'I would rather not say';

  @override
  String get adminTitle => 'Admin';

  @override
  String get adminVerifications => 'Verifications';

  @override
  String get adminPhotos => 'Photos';

  @override
  String get adminReports => 'Reports';

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminReject => 'Reject';

  @override
  String get adminDismiss => 'Dismiss';

  @override
  String get adminBan => 'Ban account';

  @override
  String get adminEmpty => 'Nothing pending';

  @override
  String get errorNotAdmin => 'This section is for admins only.';

  @override
  String get errorPremiumRequired => 'This is part of Premium.';

  @override
  String adminPose(String pose) {
    return 'Requested pose: $pose';
  }

  @override
  String adminReportedBy(String name) {
    return 'Reported by $name';
  }

  @override
  String adminBanConfirm(String name) {
    return '$name will not be able to sign in, will leave Discover and their pair will end. Are you sure?';
  }

  @override
  String adminApproveAll(int count) {
    return 'Approve all ($count)';
  }

  @override
  String adminOpenReports(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open reports',
      one: '1 open report',
    );
    return '$_temp0';
  }

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumFounder => 'Founder: premium forever';

  @override
  String premiumUntil(String date) {
    return 'Premium until $date';
  }

  @override
  String get premiumPerksTitle => 'Premium perks';

  @override
  String get premiumFree => 'Free account';

  @override
  String get premiumComingSoon =>
      'You will be able to get Premium here very soon.';

  @override
  String premiumPerkRequests(int count) {
    return '$count active requests at a time';
  }

  @override
  String get premiumPerkIncognito => 'Incognito mode';

  @override
  String get premiumPerkSeen => 'Know when your messages are read';

  @override
  String get premiumPerkTyping => 'See when your partner is typing or online';

  @override
  String get premiumIncognitoHint =>
      'You are hidden from Discover. Only people you send a request to can see you.';

  @override
  String get premiumOnly => 'Premium only';

  @override
  String get verifiedBadge => 'Verified profile';

  @override
  String get verificationCta => 'Verify your profile and build trust';

  @override
  String get verificationPendingShort => 'Your verification is under review';

  @override
  String get verificationApprovedShort => 'Your profile is verified';

  @override
  String get verificationStatusApproved => 'Verified';

  @override
  String get verificationStatusPending => 'In review';

  @override
  String get verificationStatusRejected => 'Rejected';

  @override
  String get verificationTitle => 'Verify it\'s you';

  @override
  String get verificationIntro =>
      'Take a selfie copying this pose. A moderator will compare it with your photos.';

  @override
  String get verificationTakeSelfie => 'Take selfie';

  @override
  String get verificationPrivacy =>
      'Your selfie is private: only the moderation team sees it.';

  @override
  String get verificationSent =>
      'Done! We\'ll let you know once it\'s reviewed.';

  @override
  String get verificationPendingTitle => 'In review';

  @override
  String get verificationPendingMessage =>
      'We\'re reviewing your selfie. It usually takes less than 24 h.';

  @override
  String get verificationApprovedTitle => 'You\'re verified!';

  @override
  String get verificationApprovedMessage =>
      'Your profile shows the verified badge.';

  @override
  String get verificationRejectedMessage =>
      'Your last selfie couldn\'t be verified. Try again with good light and your face visible.';

  @override
  String get posePeace => 'Make a peace sign next to your face';

  @override
  String get poseThumbsUp => 'Give a thumbs up next to your face';

  @override
  String get poseOpenHand => 'Show an open hand next to your face';

  @override
  String get posePointUp => 'Point up with your index finger';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorUpload => 'We couldn\'t upload the image. Please try again.';

  @override
  String get errorInvalidCredentials => 'Wrong email or password.';

  @override
  String get errorEmailTaken => 'That email already has an account.';

  @override
  String get errorEmailNotConfirmed => 'Confirm your email before signing in.';

  @override
  String get errorNotAuthenticated =>
      'Your session expired. Please sign in again.';

  @override
  String get errorProfileIncomplete => 'Complete your profile first.';

  @override
  String get errorAlreadyPaired => 'You already have a pair.';

  @override
  String get errorTargetUnavailable => 'That flamingo isn\'t available.';

  @override
  String get errorTargetPaired => 'That flamingo already has a pair.';

  @override
  String get errorAlreadyRequested => 'You already sent them a request.';

  @override
  String errorMaxActiveRequests(int max) {
    return 'You can only have $max active requests.';
  }

  @override
  String get errorRequestUnavailable => 'This request is no longer available.';

  @override
  String get errorSomeonePaired => 'One of you already has a pair.';

  @override
  String get errorNotPaired => 'You don\'t have a pair.';

  @override
  String get errorNoDissolutionToCancel =>
      'There\'s no ending of yours to cancel.';

  @override
  String get errorEditWindowClosed =>
      'The 1-minute window to edit that message has passed.';

  @override
  String get errorVerificationPending =>
      'You already have a verification in review.';
}

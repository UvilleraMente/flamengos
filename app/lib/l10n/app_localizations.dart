import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Flamengos'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In es, this message translates to:
  /// **'Coquetea con varios. Empareja con uno.'**
  String get tagline;

  /// No description provided for @someone.
  ///
  /// In es, this message translates to:
  /// **'Alguien'**
  String get someone;

  /// No description provided for @actionAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get actionAdd;

  /// No description provided for @actionCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get actionChange;

  /// No description provided for @actionChoose.
  ///
  /// In es, this message translates to:
  /// **'Elegir'**
  String get actionChoose;

  /// No description provided for @actionRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get actionRemove;

  /// No description provided for @actionRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get actionRetry;

  /// No description provided for @actionSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get actionSave;

  /// No description provided for @actionSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get actionSignOut;

  /// No description provided for @tabDiscover.
  ///
  /// In es, this message translates to:
  /// **'Descubrir'**
  String get tabDiscover;

  /// No description provided for @tabRequests.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get tabRequests;

  /// No description provided for @tabProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get tabProfile;

  /// No description provided for @tabCouple.
  ///
  /// In es, this message translates to:
  /// **'Mi flamengo'**
  String get tabCouple;

  /// No description provided for @statusSingle.
  ///
  /// In es, this message translates to:
  /// **'Libre'**
  String get statusSingle;

  /// No description provided for @statusPaired.
  ///
  /// In es, this message translates to:
  /// **'En pareja'**
  String get statusPaired;

  /// No description provided for @authSignInTab.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get authSignInTab;

  /// No description provided for @authSignUpTab.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authSignUpTab;

  /// No description provided for @authEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get authEmail;

  /// No description provided for @authEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe un correo válido'**
  String get authEmailInvalid;

  /// No description provided for @authPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPassword;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get authPasswordTooShort;

  /// No description provided for @authShowPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get authHidePassword;

  /// No description provided for @authSignIn.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get authSignIn;

  /// No description provided for @authCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear mi cuenta'**
  String get authCreateAccount;

  /// No description provided for @authCheckEmail.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un correo para confirmar tu cuenta.'**
  String get authCheckEmail;

  /// No description provided for @authAgeNotice.
  ///
  /// In es, this message translates to:
  /// **'Al continuar confirmas que tienes 18 años o más y aceptas los Términos y la Política de privacidad.'**
  String get authAgeNotice;

  /// No description provided for @splashError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu perfil'**
  String get splashError;

  /// No description provided for @authForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authForgotPassword;

  /// No description provided for @forgotTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get forgotTitle;

  /// No description provided for @forgotIntro.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo y te enviaremos un código para crear una contraseña nueva.'**
  String get forgotIntro;

  /// No description provided for @forgotSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get forgotSend;

  /// No description provided for @forgotSentMessage.
  ///
  /// In es, this message translates to:
  /// **'Revisa {email}. Escribe el código de 6 dígitos o abre el enlace del correo.'**
  String forgotSentMessage(String email);

  /// No description provided for @forgotCode.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get forgotCode;

  /// No description provided for @forgotVerify.
  ///
  /// In es, this message translates to:
  /// **'Verificar'**
  String get forgotVerify;

  /// No description provided for @forgotInvalidCode.
  ///
  /// In es, this message translates to:
  /// **'Código incorrecto o vencido.'**
  String get forgotInvalidCode;

  /// No description provided for @forgotResend.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get forgotResend;

  /// No description provided for @forgotResendIn.
  ///
  /// In es, this message translates to:
  /// **'Reenviar en {seconds} s'**
  String forgotResendIn(int seconds);

  /// No description provided for @forgotChangeEmail.
  ///
  /// In es, this message translates to:
  /// **'Usar otro correo'**
  String get forgotChangeEmail;

  /// No description provided for @resetTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu contraseña nueva'**
  String get resetTitle;

  /// No description provided for @resetNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña nueva'**
  String get resetNewPassword;

  /// No description provided for @resetConfirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Repite la contraseña'**
  String get resetConfirmPassword;

  /// No description provided for @resetMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get resetMismatch;

  /// No description provided for @resetSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar contraseña'**
  String get resetSave;

  /// No description provided for @resetHint.
  ///
  /// In es, this message translates to:
  /// **'Después entrarás directo a tu cuenta.'**
  String get resetHint;

  /// No description provided for @resetDone.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada 🦩'**
  String get resetDone;

  /// No description provided for @deleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar tu cuenta?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán tu perfil, fotos, solicitudes y conversaciones. Si tienes pareja, terminará de inmediato. No se puede deshacer.'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountWord.
  ///
  /// In es, this message translates to:
  /// **'ELIMINAR'**
  String get deleteAccountWord;

  /// No description provided for @deleteAccountTypeHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe {word} para confirmar'**
  String deleteAccountTypeHint(String word);

  /// No description provided for @deleteAccountAction.
  ///
  /// In es, this message translates to:
  /// **'Eliminar para siempre'**
  String get deleteAccountAction;

  /// No description provided for @deleteAccountDone.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta fue eliminada. ¡Buen vuelo! 🦩'**
  String get deleteAccountDone;

  /// No description provided for @genderWoman.
  ///
  /// In es, this message translates to:
  /// **'Mujer'**
  String get genderWoman;

  /// No description provided for @genderMan.
  ///
  /// In es, this message translates to:
  /// **'Hombre'**
  String get genderMan;

  /// No description provided for @genderNonbinary.
  ///
  /// In es, this message translates to:
  /// **'No binario'**
  String get genderNonbinary;

  /// No description provided for @genderWomenPlural.
  ///
  /// In es, this message translates to:
  /// **'Mujeres'**
  String get genderWomenPlural;

  /// No description provided for @genderMenPlural.
  ///
  /// In es, this message translates to:
  /// **'Hombres'**
  String get genderMenPlural;

  /// No description provided for @genderNonbinaryPlural.
  ///
  /// In es, this message translates to:
  /// **'Personas no binarias'**
  String get genderNonbinaryPlural;

  /// No description provided for @timeLessThanMinute.
  ///
  /// In es, this message translates to:
  /// **'menos de 1 min'**
  String get timeLessThanMinute;

  /// No description provided for @timeMinutes.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min'**
  String timeMinutes(int minutes);

  /// No description provided for @timeHoursMinutes.
  ///
  /// In es, this message translates to:
  /// **'{hours} h {minutes} min'**
  String timeHoursMinutes(int hours, int minutes);

  /// No description provided for @timeJustNow.
  ///
  /// In es, this message translates to:
  /// **'Justo ahora'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In es, this message translates to:
  /// **'hace {minutes} min'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'hace {hours} h'**
  String timeHoursAgo(int hours);

  /// No description provided for @expiresIn.
  ///
  /// In es, this message translates to:
  /// **'Expira en {time}'**
  String expiresIn(String time);

  /// No description provided for @distanceAway.
  ///
  /// In es, this message translates to:
  /// **'a {km} km'**
  String distanceAway(int km);

  /// No description provided for @discoverTitle.
  ///
  /// In es, this message translates to:
  /// **'Descubrir'**
  String get discoverTitle;

  /// No description provided for @discoverActiveRequestsHint.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes enviadas esperando respuesta'**
  String get discoverActiveRequestsHint;

  /// No description provided for @discoverRequestSent.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada a {name} 🦩 Tiene 48 h para responder.'**
  String discoverRequestSent(String name);

  /// No description provided for @discoverLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar perfiles'**
  String get discoverLoadError;

  /// No description provided for @discoverEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay más flamengos por ahora'**
  String get discoverEmptyTitle;

  /// No description provided for @discoverEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Amplía tus filtros o vuelve más tarde.'**
  String get discoverEmptyMessage;

  /// No description provided for @discoverAdjustFilters.
  ///
  /// In es, this message translates to:
  /// **'Ajustar filtros'**
  String get discoverAdjustFilters;

  /// No description provided for @discoverSearchAgain.
  ///
  /// In es, this message translates to:
  /// **'Buscar de nuevo'**
  String get discoverSearchAgain;

  /// No description provided for @discoverLimitReached.
  ///
  /// In es, this message translates to:
  /// **'Tienes {max} solicitudes esperando. Espera respuesta o cancela una para enviar otra.'**
  String discoverLimitReached(int max);

  /// No description provided for @discoverLocationBanner.
  ///
  /// In es, this message translates to:
  /// **'Comparte tu ubicación para ver flamengos cerca de ti.'**
  String get discoverLocationBanner;

  /// No description provided for @discoverPass.
  ///
  /// In es, this message translates to:
  /// **'No me interesa'**
  String get discoverPass;

  /// No description provided for @discoverRequest.
  ///
  /// In es, this message translates to:
  /// **'Pedir pareja'**
  String get discoverRequest;

  /// No description provided for @discoverViewProfile.
  ///
  /// In es, this message translates to:
  /// **'Ver perfil'**
  String get discoverViewProfile;

  /// No description provided for @discoverShowMap.
  ///
  /// In es, this message translates to:
  /// **'Ver mapa'**
  String get discoverShowMap;

  /// No description provided for @discoverShowCards.
  ///
  /// In es, this message translates to:
  /// **'Ver tarjetas'**
  String get discoverShowCards;

  /// No description provided for @mapPrivacyNote.
  ///
  /// In es, this message translates to:
  /// **'Ubicaciones aproximadas (~2 km)'**
  String get mapPrivacyNote;

  /// No description provided for @stampLike.
  ///
  /// In es, this message translates to:
  /// **'PAREJA'**
  String get stampLike;

  /// No description provided for @stampPass.
  ///
  /// In es, this message translates to:
  /// **'PASO'**
  String get stampPass;

  /// No description provided for @stampLimit.
  ///
  /// In es, this message translates to:
  /// **'LÍMITE'**
  String get stampLimit;

  /// No description provided for @filtersTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtros de búsqueda'**
  String get filtersTitle;

  /// No description provided for @filtersAge.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get filtersAge;

  /// No description provided for @filtersAgeRange.
  ///
  /// In es, this message translates to:
  /// **'{min}–{max} años'**
  String filtersAgeRange(int min, int max);

  /// No description provided for @filtersDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia'**
  String get filtersDistance;

  /// No description provided for @filtersUpToKm.
  ///
  /// In es, this message translates to:
  /// **'Hasta {km} km'**
  String filtersUpToKm(int km);

  /// No description provided for @filtersAnyDistance.
  ///
  /// In es, this message translates to:
  /// **'Sin límite'**
  String get filtersAnyDistance;

  /// No description provided for @filtersArea.
  ///
  /// In es, this message translates to:
  /// **'Zona'**
  String get filtersArea;

  /// No description provided for @filtersNearMe.
  ///
  /// In es, this message translates to:
  /// **'Cerca de mí'**
  String get filtersNearMe;

  /// No description provided for @filtersOtherArea.
  ///
  /// In es, this message translates to:
  /// **'Otra zona'**
  String get filtersOtherArea;

  /// No description provided for @filtersNeedLocation.
  ///
  /// In es, this message translates to:
  /// **'Para buscar cerca de ti, comparte tu ubicación desde Descubrir o tu perfil.'**
  String get filtersNeedLocation;

  /// No description provided for @filtersApply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get filtersApply;

  /// No description provided for @locationPickerTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una zona'**
  String get locationPickerTitle;

  /// No description provided for @locationSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar ciudad o lugar…'**
  String get locationSearchHint;

  /// No description provided for @locationTapHint.
  ///
  /// In es, this message translates to:
  /// **'Toca el mapa o busca un lugar'**
  String get locationTapHint;

  /// No description provided for @locationSelected.
  ///
  /// In es, this message translates to:
  /// **'Zona seleccionada'**
  String get locationSelected;

  /// No description provided for @locationUseThisArea.
  ///
  /// In es, this message translates to:
  /// **'Buscar en esta zona'**
  String get locationUseThisArea;

  /// No description provided for @locationUseMine.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación'**
  String get locationUseMine;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In es, this message translates to:
  /// **'Activa la ubicación de tu dispositivo.'**
  String get locationServiceDisabled;

  /// No description provided for @locationDenied.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos permiso de ubicación para buscar cerca de ti.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In es, this message translates to:
  /// **'El permiso de ubicación está bloqueado. Actívalo en los ajustes del dispositivo.'**
  String get locationDeniedForever;

  /// No description provided for @locationUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos obtener tu ubicación.'**
  String get locationUnavailable;

  /// No description provided for @requestsTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get requestsTitle;

  /// No description provided for @requestsReceivedTab.
  ///
  /// In es, this message translates to:
  /// **'Recibidas · {count}'**
  String requestsReceivedTab(int count);

  /// No description provided for @requestsSentTab.
  ///
  /// In es, this message translates to:
  /// **'Enviadas · {count}/{max}'**
  String requestsSentTab(int count, int max);

  /// No description provided for @requestsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus solicitudes'**
  String get requestsLoadError;

  /// No description provided for @requestsReceivedEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Nadie te ha pedido pareja todavía'**
  String get requestsReceivedEmptyTitle;

  /// No description provided for @requestsReceivedEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Cuando alguien lo haga, tendrás 48 h para responder.'**
  String get requestsReceivedEmptyMessage;

  /// No description provided for @requestsSentEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No has enviado solicitudes'**
  String get requestsSentEmptyTitle;

  /// No description provided for @requestsSentEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Pide pareja desde Descubrir. Puedes tener hasta {max} esperando respuesta.'**
  String requestsSentEmptyMessage(int max);

  /// No description provided for @requestsAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get requestsAccept;

  /// No description provided for @requestsDecline.
  ///
  /// In es, this message translates to:
  /// **'Declinar'**
  String get requestsDecline;

  /// No description provided for @requestsAcceptTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Emparejarte con {name}?'**
  String requestsAcceptTitle(String name);

  /// No description provided for @requestsAcceptMessage.
  ///
  /// In es, this message translates to:
  /// **'Serán exclusivos: se anularán todas tus demás solicitudes, enviadas y recibidas. Si luego uno quiere terminar, la pareja se disuelve en 12 h.'**
  String get requestsAcceptMessage;

  /// No description provided for @requestsAcceptAction.
  ///
  /// In es, this message translates to:
  /// **'Aceptar 🦩'**
  String get requestsAcceptAction;

  /// No description provided for @matchTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Tienen pareja!'**
  String get matchTitle;

  /// No description provided for @matchMessage.
  ///
  /// In es, this message translates to:
  /// **'Ahora son exclusivos: sus demás solicitudes se anularon. Escríbanse y conózcanse.'**
  String get matchMessage;

  /// No description provided for @matchGoToChat.
  ///
  /// In es, this message translates to:
  /// **'Ir al chat'**
  String get matchGoToChat;

  /// No description provided for @coupleTogetherSince.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =0{Juntos desde hoy} =1{Juntos desde ayer} other{Juntos hace {days} días}}'**
  String coupleTogetherSince(int days);

  /// No description provided for @coupleViewProfile.
  ///
  /// In es, this message translates to:
  /// **'Ver su perfil'**
  String get coupleViewProfile;

  /// No description provided for @coupleEnd.
  ///
  /// In es, this message translates to:
  /// **'Terminar pareja'**
  String get coupleEnd;

  /// No description provided for @coupleEndTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Terminar la pareja?'**
  String get coupleEndTitle;

  /// No description provided for @coupleEndMessage.
  ///
  /// In es, this message translates to:
  /// **'Se disolverá en 12 h, a menos que {name} también quiera terminar (entonces es inmediato). Puedes arrepentirte antes de que pase el tiempo.'**
  String coupleEndMessage(String name);

  /// No description provided for @coupleEndAction.
  ///
  /// In es, this message translates to:
  /// **'Terminar'**
  String get coupleEndAction;

  /// No description provided for @coupleYouAskedToEnd.
  ///
  /// In es, this message translates to:
  /// **'Pediste terminar 💔'**
  String get coupleYouAskedToEnd;

  /// No description provided for @couplePartnerAskedToEnd.
  ///
  /// In es, this message translates to:
  /// **'{name} quiere terminar 💔'**
  String couplePartnerAskedToEnd(String name);

  /// No description provided for @coupleDissolvesIn.
  ///
  /// In es, this message translates to:
  /// **'Se disuelve en {time}'**
  String coupleDissolvesIn(String time);

  /// No description provided for @coupleUndoEnd.
  ///
  /// In es, this message translates to:
  /// **'Me arrepentí'**
  String get coupleUndoEnd;

  /// No description provided for @coupleEndNow.
  ///
  /// In es, this message translates to:
  /// **'Terminar ya'**
  String get coupleEndNow;

  /// No description provided for @chatLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el chat'**
  String get chatLoadError;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Rompan el hielo'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Son exclusivos: aquí solo están ustedes dos.'**
  String get chatEmptyMessage;

  /// No description provided for @chatHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe algo bonito…'**
  String get chatHint;

  /// No description provided for @chatSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get chatSend;

  /// No description provided for @myProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get myProfileTitle;

  /// No description provided for @myProfileEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get myProfileEdit;

  /// No description provided for @myProfilePreview.
  ///
  /// In es, this message translates to:
  /// **'Ver como lo ven otros'**
  String get myProfilePreview;

  /// No description provided for @profileCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu perfil'**
  String get profileCreateTitle;

  /// No description provided for @profileEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get profileEditTitle;

  /// No description provided for @profileCreateIntro.
  ///
  /// In es, this message translates to:
  /// **'Cuéntale al mundo quién eres. Un buen perfil consigue más solicitudes 🦩'**
  String get profileCreateIntro;

  /// No description provided for @profilePhotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get profilePhotos;

  /// No description provided for @profilePhotosHint.
  ///
  /// In es, this message translates to:
  /// **'La primera es tu foto principal · hasta {max}'**
  String profilePhotosHint(int max);

  /// No description provided for @profileMainPhoto.
  ///
  /// In es, this message translates to:
  /// **'Principal'**
  String get profileMainPhoto;

  /// No description provided for @profileBasics.
  ///
  /// In es, this message translates to:
  /// **'Lo básico'**
  String get profileBasics;

  /// No description provided for @profileName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get profileName;

  /// No description provided for @profileNameTooShort.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 2 caracteres'**
  String get profileNameTooShort;

  /// No description provided for @profileBirthdate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get profileBirthdate;

  /// No description provided for @profileAgeYears.
  ///
  /// In es, this message translates to:
  /// **'{age} años'**
  String profileAgeYears(int age);

  /// No description provided for @profileLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get profileLocation;

  /// No description provided for @profileLocationHint.
  ///
  /// In es, this message translates to:
  /// **'Solo se guarda una zona aproximada (~2 km), nunca tu ubicación exacta.'**
  String get profileLocationHint;

  /// No description provided for @profileLocationShared.
  ///
  /// In es, this message translates to:
  /// **'Ubicación compartida'**
  String get profileLocationShared;

  /// No description provided for @profileCity.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get profileCity;

  /// No description provided for @profileIAm.
  ///
  /// In es, this message translates to:
  /// **'Soy'**
  String get profileIAm;

  /// No description provided for @profileLookingFor.
  ///
  /// In es, this message translates to:
  /// **'Busco'**
  String get profileLookingFor;

  /// No description provided for @profileLookingForHint.
  ///
  /// In es, this message translates to:
  /// **'Puedes elegir varias opciones'**
  String get profileLookingForHint;

  /// No description provided for @profileAboutYou.
  ///
  /// In es, this message translates to:
  /// **'Sobre ti'**
  String get profileAboutYou;

  /// No description provided for @profileBioHint.
  ///
  /// In es, this message translates to:
  /// **'Lo que te hace sonreír, tu plan ideal, tu canción…'**
  String get profileBioHint;

  /// No description provided for @profileStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar a volar 🦩'**
  String get profileStart;

  /// No description provided for @profileSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get profileSave;

  /// No description provided for @profileMissing.
  ///
  /// In es, this message translates to:
  /// **'Falta {items}.'**
  String profileMissing(String items);

  /// No description provided for @profileMissingPhoto.
  ///
  /// In es, this message translates to:
  /// **'al menos una foto'**
  String get profileMissingPhoto;

  /// No description provided for @profileMissingBirthdate.
  ///
  /// In es, this message translates to:
  /// **'tu fecha de nacimiento'**
  String get profileMissingBirthdate;

  /// No description provided for @profileMissingGender.
  ///
  /// In es, this message translates to:
  /// **'tu género'**
  String get profileMissingGender;

  /// No description provided for @profileMissingInterest.
  ///
  /// In es, this message translates to:
  /// **'a quién buscas'**
  String get profileMissingInterest;

  /// No description provided for @promptsTitle.
  ///
  /// In es, this message translates to:
  /// **'Preguntas'**
  String get promptsTitle;

  /// No description provided for @promptsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Dan de qué hablar · hasta {max}'**
  String promptsSubtitle(int max);

  /// No description provided for @promptsAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar pregunta'**
  String get promptsAdd;

  /// No description provided for @promptsChoose.
  ///
  /// In es, this message translates to:
  /// **'Elige una pregunta'**
  String get promptsChoose;

  /// No description provided for @promptsPickFirst.
  ///
  /// In es, this message translates to:
  /// **'Primero elige una pregunta'**
  String get promptsPickFirst;

  /// No description provided for @promptsAnswerHint.
  ///
  /// In es, this message translates to:
  /// **'Tu respuesta…'**
  String get promptsAnswerHint;

  /// No description provided for @promptsTip.
  ///
  /// In es, this message translates to:
  /// **'Las respuestas concretas y con humor funcionan mejor.'**
  String get promptsTip;

  /// No description provided for @promptIdealDate.
  ///
  /// In es, this message translates to:
  /// **'Mi cita ideal es…'**
  String get promptIdealDate;

  /// No description provided for @promptGreenFlag.
  ///
  /// In es, this message translates to:
  /// **'Una señal verde para mí es…'**
  String get promptGreenFlag;

  /// No description provided for @promptSong.
  ///
  /// In es, this message translates to:
  /// **'La canción que no puedo dejar de escuchar…'**
  String get promptSong;

  /// No description provided for @promptWeekend.
  ///
  /// In es, this message translates to:
  /// **'Un domingo perfecto es…'**
  String get promptWeekend;

  /// No description provided for @promptUnpopularOpinion.
  ///
  /// In es, this message translates to:
  /// **'Mi opinión impopular es…'**
  String get promptUnpopularOpinion;

  /// No description provided for @promptLookingFor.
  ///
  /// In es, this message translates to:
  /// **'Busco a alguien que…'**
  String get promptLookingFor;

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todo tranquilo'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás solicitudes, parejas y avisos.'**
  String get notificationsEmptyMessage;

  /// No description provided for @notifRequestReceived.
  ///
  /// In es, this message translates to:
  /// **'{name} te pidió pareja'**
  String notifRequestReceived(String name);

  /// No description provided for @notifRequestAccepted.
  ///
  /// In es, this message translates to:
  /// **'{name} aceptó ser tu pareja'**
  String notifRequestAccepted(String name);

  /// No description provided for @notifRequestExpiring.
  ///
  /// In es, this message translates to:
  /// **'La solicitud de {name} expira pronto'**
  String notifRequestExpiring(String name);

  /// No description provided for @notifDissolutionRequested.
  ///
  /// In es, this message translates to:
  /// **'{name} quiere terminar la pareja'**
  String notifDissolutionRequested(String name);

  /// No description provided for @notifDissolutionCancelled.
  ///
  /// In es, this message translates to:
  /// **'{name} se arrepintió: siguen juntos'**
  String notifDissolutionCancelled(String name);

  /// No description provided for @notifCoupleDissolved.
  ///
  /// In es, this message translates to:
  /// **'Tu pareja con {name} terminó'**
  String notifCoupleDissolved(String name);

  /// No description provided for @safetyReportOrBlock.
  ///
  /// In es, this message translates to:
  /// **'Reportar o bloquear'**
  String get safetyReportOrBlock;

  /// No description provided for @reportTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar a {name}'**
  String reportTitle(String name);

  /// No description provided for @reportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'No le avisaremos. Al reportar también lo bloqueas: no volverán a verse.'**
  String get reportSubtitle;

  /// No description provided for @reportFakeProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil falso'**
  String get reportFakeProfile;

  /// No description provided for @reportInappropriate.
  ///
  /// In es, this message translates to:
  /// **'Contenido inapropiado'**
  String get reportInappropriate;

  /// No description provided for @reportHarassment.
  ///
  /// In es, this message translates to:
  /// **'Acoso'**
  String get reportHarassment;

  /// No description provided for @reportUnderage.
  ///
  /// In es, this message translates to:
  /// **'Menor de edad'**
  String get reportUnderage;

  /// No description provided for @reportSpam.
  ///
  /// In es, this message translates to:
  /// **'Spam o estafa'**
  String get reportSpam;

  /// No description provided for @reportOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get reportOther;

  /// No description provided for @reportDetailsHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos más (opcional)'**
  String get reportDetailsHint;

  /// No description provided for @reportAndBlock.
  ///
  /// In es, this message translates to:
  /// **'Reportar y bloquear'**
  String get reportAndBlock;

  /// No description provided for @blockOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo bloquear'**
  String get blockOnly;

  /// No description provided for @reportSent.
  ///
  /// In es, this message translates to:
  /// **'Gracias. Revisaremos el reporte.'**
  String get reportSent;

  /// No description provided for @blockDone.
  ///
  /// In es, this message translates to:
  /// **'Bloqueaste a {name}.'**
  String blockDone(String name);

  /// No description provided for @blockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Usuarios bloqueados'**
  String get blockedTitle;

  /// No description provided for @blockedEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No has bloqueado a nadie'**
  String get blockedEmptyTitle;

  /// No description provided for @blockedEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Si bloqueas a alguien, aparecerá aquí.'**
  String get blockedEmptyMessage;

  /// No description provided for @unblock.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get unblock;

  /// No description provided for @settingsAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearance;

  /// No description provided for @appearanceTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get appearanceTheme;

  /// No description provided for @themeFirefly.
  ///
  /// In es, this message translates to:
  /// **'Firefly'**
  String get themeFirefly;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @appearanceFont.
  ///
  /// In es, this message translates to:
  /// **'Fuente'**
  String get appearanceFont;

  /// No description provided for @appearanceTextSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño del texto'**
  String get appearanceTextSize;

  /// No description provided for @appearanceTextCase.
  ///
  /// In es, this message translates to:
  /// **'Formato de letras'**
  String get appearanceTextCase;

  /// No description provided for @textCaseNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get textCaseNormal;

  /// No description provided for @textCaseUpper.
  ///
  /// In es, this message translates to:
  /// **'MAYÚSCULAS'**
  String get textCaseUpper;

  /// No description provided for @textCaseLower.
  ///
  /// In es, this message translates to:
  /// **'minúsculas'**
  String get textCaseLower;

  /// No description provided for @textCaseTitle.
  ///
  /// In es, this message translates to:
  /// **'Tipo Título'**
  String get textCaseTitle;

  /// No description provided for @coupleMapTitle.
  ///
  /// In es, this message translates to:
  /// **'Están a {km} km 💕'**
  String coupleMapTitle(int km);

  /// No description provided for @helpTitle.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get helpTitle;

  /// No description provided for @helpSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Preguntas frecuentes y contacto'**
  String get helpSubtitle;

  /// No description provided for @helpContact.
  ///
  /// In es, this message translates to:
  /// **'Escríbenos'**
  String get helpContact;

  /// No description provided for @legalTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get legalTerms;

  /// No description provided for @legalPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get legalPrivacy;

  /// No description provided for @faqExclusiveQ.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo funciona la exclusividad?'**
  String get faqExclusiveQ;

  /// No description provided for @faqExclusiveA.
  ///
  /// In es, this message translates to:
  /// **'Puedes pedirle pareja a varios flamengos, pero cuando alguien acepta (o tú aceptas), quedan emparejados solo entre ustedes dos. Mientras sean pareja no aparecen en Descubrir ni pueden recibir solicitudes.'**
  String get faqExclusiveA;

  /// No description provided for @faqRequestsQ.
  ///
  /// In es, this message translates to:
  /// **'¿Cuántas solicitudes puedo enviar?'**
  String get faqRequestsQ;

  /// No description provided for @faqRequestsA.
  ///
  /// In es, this message translates to:
  /// **'Hasta 3 a la vez. Cada una expira en 48 horas si no responden, y puedes cancelarla antes si te cansas de esperar.'**
  String get faqRequestsA;

  /// No description provided for @faqAcceptQ.
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasa cuando acepto a alguien?'**
  String get faqAcceptQ;

  /// No description provided for @faqAcceptA.
  ///
  /// In es, this message translates to:
  /// **'Se crea la pareja y todas sus demás solicitudes, enviadas y recibidas, se anulan automáticamente.'**
  String get faqAcceptA;

  /// No description provided for @faqEndQ.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo termino una pareja?'**
  String get faqEndQ;

  /// No description provided for @faqEndA.
  ///
  /// In es, this message translates to:
  /// **'Desde el menú de tu pareja. Si solo uno quiere terminar, se disuelve en 12 horas (y puedes arrepentirte antes). Si los dos quieren, es inmediato.'**
  String get faqEndA;

  /// No description provided for @faqLocationQ.
  ///
  /// In es, this message translates to:
  /// **'¿Quién ve mi ubicación?'**
  String get faqLocationQ;

  /// No description provided for @faqLocationA.
  ///
  /// In es, this message translates to:
  /// **'Solo guardamos una zona aproximada (unos 2 km), nunca tu ubicación exacta. Los demás ven la distancia aproximada y un punto aproximado en el mapa.'**
  String get faqLocationA;

  /// No description provided for @faqSafetyQ.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo reporto o bloqueo a alguien?'**
  String get faqSafetyQ;

  /// No description provided for @faqSafetyA.
  ///
  /// In es, this message translates to:
  /// **'Abre su perfil y toca \"Reportar o bloquear\". No le avisaremos. Al bloquear, dejan de verse y, si eran pareja, se termina de inmediato.'**
  String get faqSafetyA;

  /// No description provided for @faqVerifyQ.
  ///
  /// In es, this message translates to:
  /// **'¿Para qué sirve verificarme?'**
  String get faqVerifyQ;

  /// No description provided for @faqVerifyA.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil muestra una insignia que confirma que eres tú. Te tomas una selfie imitando una pose y un moderador la compara con tus fotos.'**
  String get faqVerifyA;

  /// No description provided for @faqDeleteQ.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo elimino mi cuenta?'**
  String get faqDeleteQ;

  /// No description provided for @faqDeleteA.
  ///
  /// In es, this message translates to:
  /// **'En Ajustes → Cuenta → Eliminar cuenta. Se borran tu perfil, fotos, solicitudes y conversaciones. No se puede deshacer.'**
  String get faqDeleteA;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In es, this message translates to:
  /// **'Del dispositivo'**
  String get languageSystem;

  /// No description provided for @settingsVerification.
  ///
  /// In es, this message translates to:
  /// **'Verificación'**
  String get settingsVerification;

  /// No description provided for @settingsSafety.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get settingsSafety;

  /// No description provided for @settingsAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get settingsAccount;

  /// No description provided for @verifiedBadge.
  ///
  /// In es, this message translates to:
  /// **'Perfil verificado'**
  String get verifiedBadge;

  /// No description provided for @verificationCta.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu perfil y gana confianza'**
  String get verificationCta;

  /// No description provided for @verificationPendingShort.
  ///
  /// In es, this message translates to:
  /// **'Tu verificación está en revisión'**
  String get verificationPendingShort;

  /// No description provided for @verificationApprovedShort.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil está verificado'**
  String get verificationApprovedShort;

  /// No description provided for @verificationStatusApproved.
  ///
  /// In es, this message translates to:
  /// **'Verificado'**
  String get verificationStatusApproved;

  /// No description provided for @verificationStatusPending.
  ///
  /// In es, this message translates to:
  /// **'En revisión'**
  String get verificationStatusPending;

  /// No description provided for @verificationStatusRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazada'**
  String get verificationStatusRejected;

  /// No description provided for @verificationTitle.
  ///
  /// In es, this message translates to:
  /// **'Verifica que eres tú'**
  String get verificationTitle;

  /// No description provided for @verificationIntro.
  ///
  /// In es, this message translates to:
  /// **'Tómate una selfie imitando esta pose. Un moderador la comparará con tus fotos.'**
  String get verificationIntro;

  /// No description provided for @verificationTakeSelfie.
  ///
  /// In es, this message translates to:
  /// **'Tomar selfie'**
  String get verificationTakeSelfie;

  /// No description provided for @verificationPrivacy.
  ///
  /// In es, this message translates to:
  /// **'La selfie es privada: solo la ve el equipo de moderación.'**
  String get verificationPrivacy;

  /// No description provided for @verificationSent.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Te avisaremos cuando la revisemos.'**
  String get verificationSent;

  /// No description provided for @verificationPendingTitle.
  ///
  /// In es, this message translates to:
  /// **'En revisión'**
  String get verificationPendingTitle;

  /// No description provided for @verificationPendingMessage.
  ///
  /// In es, this message translates to:
  /// **'Estamos revisando tu selfie. Suele tardar menos de 24 h.'**
  String get verificationPendingMessage;

  /// No description provided for @verificationApprovedTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Estás verificado!'**
  String get verificationApprovedTitle;

  /// No description provided for @verificationApprovedMessage.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil muestra la insignia de verificado.'**
  String get verificationApprovedMessage;

  /// No description provided for @verificationRejectedMessage.
  ///
  /// In es, this message translates to:
  /// **'Tu última selfie no se pudo verificar. Inténtalo de nuevo con buena luz y la cara visible.'**
  String get verificationRejectedMessage;

  /// No description provided for @posePeace.
  ///
  /// In es, this message translates to:
  /// **'Haz el signo de paz junto a tu cara'**
  String get posePeace;

  /// No description provided for @poseThumbsUp.
  ///
  /// In es, this message translates to:
  /// **'Levanta el pulgar junto a tu cara'**
  String get poseThumbsUp;

  /// No description provided for @poseOpenHand.
  ///
  /// In es, this message translates to:
  /// **'Muestra la mano abierta junto a tu cara'**
  String get poseOpenHand;

  /// No description provided for @posePointUp.
  ///
  /// In es, this message translates to:
  /// **'Apunta hacia arriba con el índice'**
  String get posePointUp;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Intenta de nuevo.'**
  String get errorGeneric;

  /// No description provided for @errorUpload.
  ///
  /// In es, this message translates to:
  /// **'No pudimos subir la imagen. Intenta de nuevo.'**
  String get errorUpload;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailTaken.
  ///
  /// In es, this message translates to:
  /// **'Ese correo ya tiene una cuenta.'**
  String get errorEmailTaken;

  /// No description provided for @errorEmailNotConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu correo antes de entrar.'**
  String get errorEmailNotConfirmed;

  /// No description provided for @errorNotAuthenticated.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión expiró. Vuelve a entrar.'**
  String get errorNotAuthenticated;

  /// No description provided for @errorProfileIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Completa tu perfil primero.'**
  String get errorProfileIncomplete;

  /// No description provided for @errorAlreadyPaired.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes pareja.'**
  String get errorAlreadyPaired;

  /// No description provided for @errorTargetUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Ese flamengo no está disponible.'**
  String get errorTargetUnavailable;

  /// No description provided for @errorTargetPaired.
  ///
  /// In es, this message translates to:
  /// **'Ese flamengo ya tiene pareja.'**
  String get errorTargetPaired;

  /// No description provided for @errorAlreadyRequested.
  ///
  /// In es, this message translates to:
  /// **'Ya le enviaste una solicitud.'**
  String get errorAlreadyRequested;

  /// No description provided for @errorMaxActiveRequests.
  ///
  /// In es, this message translates to:
  /// **'Solo puedes tener {max} solicitudes activas.'**
  String errorMaxActiveRequests(int max);

  /// No description provided for @errorRequestUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Esta solicitud ya no está disponible.'**
  String get errorRequestUnavailable;

  /// No description provided for @errorSomeonePaired.
  ///
  /// In es, this message translates to:
  /// **'Uno de los dos ya tiene pareja.'**
  String get errorSomeonePaired;

  /// No description provided for @errorNotPaired.
  ///
  /// In es, this message translates to:
  /// **'No tienes pareja.'**
  String get errorNotPaired;

  /// No description provided for @errorNoDissolutionToCancel.
  ///
  /// In es, this message translates to:
  /// **'No hay una disolución tuya que cancelar.'**
  String get errorNoDissolutionToCancel;

  /// No description provided for @errorVerificationPending.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes una verificación en revisión.'**
  String get errorVerificationPending;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

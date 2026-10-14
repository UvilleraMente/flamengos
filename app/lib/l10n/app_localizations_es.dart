// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Flamengos';

  @override
  String get tagline => 'Coquetea con varios. Empareja con uno.';

  @override
  String get someone => 'Alguien';

  @override
  String get actionAdd => 'Agregar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionChange => 'Cambiar';

  @override
  String get actionChoose => 'Elegir';

  @override
  String get actionRemove => 'Quitar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionSignOut => 'Cerrar sesión';

  @override
  String get tabDiscover => 'Descubrir';

  @override
  String get tabRequests => 'Solicitudes';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get tabCouple => 'Mi flamengo';

  @override
  String get statusSingle => 'Libre';

  @override
  String get statusPaired => 'En pareja';

  @override
  String get authSignInTab => 'Entrar';

  @override
  String get authSignUpTab => 'Crear cuenta';

  @override
  String get authEmail => 'Correo';

  @override
  String get authEmailInvalid => 'Escribe un correo válido';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authPasswordTooShort => 'Mínimo 6 caracteres';

  @override
  String get authShowPassword => 'Mostrar contraseña';

  @override
  String get authHidePassword => 'Ocultar contraseña';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authCreateAccount => 'Crear mi cuenta';

  @override
  String get authCheckEmail =>
      'Te enviamos un correo para confirmar tu cuenta.';

  @override
  String get authAgeNotice =>
      'Al continuar confirmas que tienes 18 años o más.';

  @override
  String get splashError => 'No pudimos cargar tu perfil';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get forgotTitle => 'Recuperar contraseña';

  @override
  String get forgotIntro =>
      'Escribe tu correo y te enviaremos un código para crear una contraseña nueva.';

  @override
  String get forgotSend => 'Enviar código';

  @override
  String forgotSentMessage(String email) {
    return 'Revisa $email. Escribe el código de 6 dígitos o abre el enlace del correo.';
  }

  @override
  String get forgotCode => 'Código';

  @override
  String get forgotVerify => 'Verificar';

  @override
  String get forgotInvalidCode => 'Código incorrecto o vencido.';

  @override
  String get forgotResend => 'Reenviar código';

  @override
  String forgotResendIn(int seconds) {
    return 'Reenviar en $seconds s';
  }

  @override
  String get forgotChangeEmail => 'Usar otro correo';

  @override
  String get resetTitle => 'Crea tu contraseña nueva';

  @override
  String get resetNewPassword => 'Contraseña nueva';

  @override
  String get resetConfirmPassword => 'Repite la contraseña';

  @override
  String get resetMismatch => 'Las contraseñas no coinciden';

  @override
  String get resetSave => 'Guardar contraseña';

  @override
  String get resetHint => 'Después entrarás directo a tu cuenta.';

  @override
  String get resetDone => 'Contraseña actualizada 🦩';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountTitle => '¿Eliminar tu cuenta?';

  @override
  String get deleteAccountMessage =>
      'Se borrarán tu perfil, fotos, solicitudes y conversaciones. Si tienes pareja, terminará de inmediato. No se puede deshacer.';

  @override
  String get deleteAccountWord => 'ELIMINAR';

  @override
  String deleteAccountTypeHint(String word) {
    return 'Escribe $word para confirmar';
  }

  @override
  String get deleteAccountAction => 'Eliminar para siempre';

  @override
  String get deleteAccountDone => 'Tu cuenta fue eliminada. ¡Buen vuelo! 🦩';

  @override
  String get genderWoman => 'Mujer';

  @override
  String get genderMan => 'Hombre';

  @override
  String get genderNonbinary => 'No binario';

  @override
  String get genderWomenPlural => 'Mujeres';

  @override
  String get genderMenPlural => 'Hombres';

  @override
  String get genderNonbinaryPlural => 'Personas no binarias';

  @override
  String get timeLessThanMinute => 'menos de 1 min';

  @override
  String timeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String timeHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get timeJustNow => 'Justo ahora';

  @override
  String timeMinutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String timeHoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String expiresIn(String time) {
    return 'Expira en $time';
  }

  @override
  String distanceAway(int km) {
    return 'a $km km';
  }

  @override
  String get discoverTitle => 'Descubrir';

  @override
  String get discoverActiveRequestsHint =>
      'Solicitudes enviadas esperando respuesta';

  @override
  String discoverRequestSent(String name) {
    return 'Solicitud enviada a $name 🦩 Tiene 48 h para responder.';
  }

  @override
  String get discoverLoadError => 'No pudimos cargar perfiles';

  @override
  String get discoverEmptyTitle => 'No hay más flamengos por ahora';

  @override
  String get discoverEmptyMessage => 'Amplía tus filtros o vuelve más tarde.';

  @override
  String get discoverAdjustFilters => 'Ajustar filtros';

  @override
  String get discoverSearchAgain => 'Buscar de nuevo';

  @override
  String discoverLimitReached(int max) {
    return 'Tienes $max solicitudes esperando. Espera respuesta o cancela una para enviar otra.';
  }

  @override
  String get discoverLocationBanner =>
      'Comparte tu ubicación para ver flamengos cerca de ti.';

  @override
  String get discoverPass => 'No me interesa';

  @override
  String get discoverRequest => 'Pedir pareja';

  @override
  String get discoverViewProfile => 'Ver perfil';

  @override
  String get discoverShowMap => 'Ver mapa';

  @override
  String get discoverShowCards => 'Ver tarjetas';

  @override
  String get mapPrivacyNote => 'Ubicaciones aproximadas (~2 km)';

  @override
  String get stampLike => 'PAREJA';

  @override
  String get stampPass => 'PASO';

  @override
  String get stampLimit => 'LÍMITE';

  @override
  String get filtersTitle => 'Filtros de búsqueda';

  @override
  String get filtersAge => 'Edad';

  @override
  String filtersAgeRange(int min, int max) {
    return '$min–$max años';
  }

  @override
  String get filtersDistance => 'Distancia';

  @override
  String filtersUpToKm(int km) {
    return 'Hasta $km km';
  }

  @override
  String get filtersAnyDistance => 'Sin límite';

  @override
  String get filtersArea => 'Zona';

  @override
  String get filtersNearMe => 'Cerca de mí';

  @override
  String get filtersOtherArea => 'Otra zona';

  @override
  String get filtersNeedLocation =>
      'Para buscar cerca de ti, comparte tu ubicación desde Descubrir o tu perfil.';

  @override
  String get filtersApply => 'Aplicar filtros';

  @override
  String get locationPickerTitle => 'Elige una zona';

  @override
  String get locationSearchHint => 'Buscar ciudad o lugar…';

  @override
  String get locationTapHint => 'Toca el mapa o busca un lugar';

  @override
  String get locationSelected => 'Zona seleccionada';

  @override
  String get locationUseThisArea => 'Buscar en esta zona';

  @override
  String get locationUseMine => 'Usar mi ubicación';

  @override
  String get locationServiceDisabled =>
      'Activa la ubicación de tu dispositivo.';

  @override
  String get locationDenied =>
      'Necesitamos permiso de ubicación para buscar cerca de ti.';

  @override
  String get locationDeniedForever =>
      'El permiso de ubicación está bloqueado. Actívalo en los ajustes del dispositivo.';

  @override
  String get locationUnavailable => 'No pudimos obtener tu ubicación.';

  @override
  String get requestsTitle => 'Solicitudes';

  @override
  String requestsReceivedTab(int count) {
    return 'Recibidas · $count';
  }

  @override
  String requestsSentTab(int count, int max) {
    return 'Enviadas · $count/$max';
  }

  @override
  String get requestsLoadError => 'No pudimos cargar tus solicitudes';

  @override
  String get requestsReceivedEmptyTitle => 'Nadie te ha pedido pareja todavía';

  @override
  String get requestsReceivedEmptyMessage =>
      'Cuando alguien lo haga, tendrás 48 h para responder.';

  @override
  String get requestsSentEmptyTitle => 'No has enviado solicitudes';

  @override
  String requestsSentEmptyMessage(int max) {
    return 'Pide pareja desde Descubrir. Puedes tener hasta $max esperando respuesta.';
  }

  @override
  String get requestsAccept => 'Aceptar';

  @override
  String get requestsDecline => 'Declinar';

  @override
  String requestsAcceptTitle(String name) {
    return '¿Emparejarte con $name?';
  }

  @override
  String get requestsAcceptMessage =>
      'Serán exclusivos: se anularán todas tus demás solicitudes, enviadas y recibidas. Si luego uno quiere terminar, la pareja se disuelve en 12 h.';

  @override
  String get requestsAcceptAction => 'Aceptar 🦩';

  @override
  String get matchTitle => '¡Tienen pareja!';

  @override
  String get matchMessage =>
      'Ahora son exclusivos: sus demás solicitudes se anularon. Escríbanse y conózcanse.';

  @override
  String get matchGoToChat => 'Ir al chat';

  @override
  String coupleTogetherSince(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Juntos hace $days días',
      one: 'Juntos desde ayer',
      zero: 'Juntos desde hoy',
    );
    return '$_temp0';
  }

  @override
  String get coupleViewProfile => 'Ver su perfil';

  @override
  String get coupleEnd => 'Terminar pareja';

  @override
  String get coupleEndTitle => '¿Terminar la pareja?';

  @override
  String coupleEndMessage(String name) {
    return 'Se disolverá en 12 h, a menos que $name también quiera terminar (entonces es inmediato). Puedes arrepentirte antes de que pase el tiempo.';
  }

  @override
  String get coupleEndAction => 'Terminar';

  @override
  String get coupleYouAskedToEnd => 'Pediste terminar 💔';

  @override
  String couplePartnerAskedToEnd(String name) {
    return '$name quiere terminar 💔';
  }

  @override
  String coupleDissolvesIn(String time) {
    return 'Se disuelve en $time';
  }

  @override
  String get coupleUndoEnd => 'Me arrepentí';

  @override
  String get coupleEndNow => 'Terminar ya';

  @override
  String get chatLoadError => 'No pudimos cargar el chat';

  @override
  String get chatEmptyTitle => 'Rompan el hielo';

  @override
  String get chatEmptyMessage => 'Son exclusivos: aquí solo están ustedes dos.';

  @override
  String get chatHint => 'Escribe algo bonito…';

  @override
  String get chatSend => 'Enviar';

  @override
  String get myProfileTitle => 'Mi perfil';

  @override
  String get myProfileEdit => 'Editar perfil';

  @override
  String get myProfilePreview => 'Ver como lo ven otros';

  @override
  String get profileCreateTitle => 'Crea tu perfil';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileCreateIntro =>
      'Cuéntale al mundo quién eres. Un buen perfil consigue más solicitudes 🦩';

  @override
  String get profilePhotos => 'Fotos';

  @override
  String profilePhotosHint(int max) {
    return 'La primera es tu foto principal · hasta $max';
  }

  @override
  String get profileMainPhoto => 'Principal';

  @override
  String get profileBasics => 'Lo básico';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileNameTooShort => 'Mínimo 2 caracteres';

  @override
  String get profileBirthdate => 'Fecha de nacimiento';

  @override
  String profileAgeYears(int age) {
    return '$age años';
  }

  @override
  String get profileLocation => 'Ubicación';

  @override
  String get profileLocationHint =>
      'Solo se guarda una zona aproximada (~2 km), nunca tu ubicación exacta.';

  @override
  String get profileLocationShared => 'Ubicación compartida';

  @override
  String get profileCity => 'Ciudad';

  @override
  String get profileIAm => 'Soy';

  @override
  String get profileLookingFor => 'Busco';

  @override
  String get profileLookingForHint => 'Puedes elegir varias opciones';

  @override
  String get profileAboutYou => 'Sobre ti';

  @override
  String get profileBioHint =>
      'Lo que te hace sonreír, tu plan ideal, tu canción…';

  @override
  String get profileStart => 'Empezar a volar 🦩';

  @override
  String get profileSave => 'Guardar cambios';

  @override
  String profileMissing(String items) {
    return 'Falta $items.';
  }

  @override
  String get profileMissingPhoto => 'al menos una foto';

  @override
  String get profileMissingBirthdate => 'tu fecha de nacimiento';

  @override
  String get profileMissingGender => 'tu género';

  @override
  String get profileMissingInterest => 'a quién buscas';

  @override
  String get promptsTitle => 'Preguntas';

  @override
  String promptsSubtitle(int max) {
    return 'Dan de qué hablar · hasta $max';
  }

  @override
  String get promptsAdd => 'Agregar pregunta';

  @override
  String get promptsChoose => 'Elige una pregunta';

  @override
  String get promptsPickFirst => 'Primero elige una pregunta';

  @override
  String get promptsAnswerHint => 'Tu respuesta…';

  @override
  String get promptsTip =>
      'Las respuestas concretas y con humor funcionan mejor.';

  @override
  String get promptIdealDate => 'Mi cita ideal es…';

  @override
  String get promptGreenFlag => 'Una señal verde para mí es…';

  @override
  String get promptSong => 'La canción que no puedo dejar de escuchar…';

  @override
  String get promptWeekend => 'Un domingo perfecto es…';

  @override
  String get promptUnpopularOpinion => 'Mi opinión impopular es…';

  @override
  String get promptLookingFor => 'Busco a alguien que…';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsEmptyTitle => 'Todo tranquilo';

  @override
  String get notificationsEmptyMessage =>
      'Aquí verás solicitudes, parejas y avisos.';

  @override
  String notifRequestReceived(String name) {
    return '$name te pidió pareja';
  }

  @override
  String notifRequestAccepted(String name) {
    return '$name aceptó ser tu pareja';
  }

  @override
  String notifRequestExpiring(String name) {
    return 'La solicitud de $name expira pronto';
  }

  @override
  String notifDissolutionRequested(String name) {
    return '$name quiere terminar la pareja';
  }

  @override
  String notifDissolutionCancelled(String name) {
    return '$name se arrepintió: siguen juntos';
  }

  @override
  String notifCoupleDissolved(String name) {
    return 'Tu pareja con $name terminó';
  }

  @override
  String get safetyReportOrBlock => 'Reportar o bloquear';

  @override
  String reportTitle(String name) {
    return 'Reportar a $name';
  }

  @override
  String get reportSubtitle =>
      'No le avisaremos. Al reportar también lo bloqueas: no volverán a verse.';

  @override
  String get reportFakeProfile => 'Perfil falso';

  @override
  String get reportInappropriate => 'Contenido inapropiado';

  @override
  String get reportHarassment => 'Acoso';

  @override
  String get reportUnderage => 'Menor de edad';

  @override
  String get reportSpam => 'Spam o estafa';

  @override
  String get reportOther => 'Otro';

  @override
  String get reportDetailsHint => 'Cuéntanos más (opcional)';

  @override
  String get reportAndBlock => 'Reportar y bloquear';

  @override
  String get blockOnly => 'Solo bloquear';

  @override
  String get reportSent => 'Gracias. Revisaremos el reporte.';

  @override
  String blockDone(String name) {
    return 'Bloqueaste a $name.';
  }

  @override
  String get blockedTitle => 'Usuarios bloqueados';

  @override
  String get blockedEmptyTitle => 'No has bloqueado a nadie';

  @override
  String get blockedEmptyMessage => 'Si bloqueas a alguien, aparecerá aquí.';

  @override
  String get unblock => 'Desbloquear';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Del dispositivo';

  @override
  String get settingsVerification => 'Verificación';

  @override
  String get settingsSafety => 'Seguridad';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get verifiedBadge => 'Perfil verificado';

  @override
  String get verificationCta => 'Verifica tu perfil y gana confianza';

  @override
  String get verificationPendingShort => 'Tu verificación está en revisión';

  @override
  String get verificationApprovedShort => 'Tu perfil está verificado';

  @override
  String get verificationStatusApproved => 'Verificado';

  @override
  String get verificationStatusPending => 'En revisión';

  @override
  String get verificationStatusRejected => 'Rechazada';

  @override
  String get verificationTitle => 'Verifica que eres tú';

  @override
  String get verificationIntro =>
      'Tómate una selfie imitando esta pose. Un moderador la comparará con tus fotos.';

  @override
  String get verificationTakeSelfie => 'Tomar selfie';

  @override
  String get verificationPrivacy =>
      'La selfie es privada: solo la ve el equipo de moderación.';

  @override
  String get verificationSent => '¡Listo! Te avisaremos cuando la revisemos.';

  @override
  String get verificationPendingTitle => 'En revisión';

  @override
  String get verificationPendingMessage =>
      'Estamos revisando tu selfie. Suele tardar menos de 24 h.';

  @override
  String get verificationApprovedTitle => '¡Estás verificado!';

  @override
  String get verificationApprovedMessage =>
      'Tu perfil muestra la insignia de verificado.';

  @override
  String get verificationRejectedMessage =>
      'Tu última selfie no se pudo verificar. Inténtalo de nuevo con buena luz y la cara visible.';

  @override
  String get posePeace => 'Haz el signo de paz junto a tu cara';

  @override
  String get poseThumbsUp => 'Levanta el pulgar junto a tu cara';

  @override
  String get poseOpenHand => 'Muestra la mano abierta junto a tu cara';

  @override
  String get posePointUp => 'Apunta hacia arriba con el índice';

  @override
  String get errorGeneric => 'Algo salió mal. Intenta de nuevo.';

  @override
  String get errorUpload => 'No pudimos subir la imagen. Intenta de nuevo.';

  @override
  String get errorInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get errorEmailTaken => 'Ese correo ya tiene una cuenta.';

  @override
  String get errorEmailNotConfirmed => 'Confirma tu correo antes de entrar.';

  @override
  String get errorNotAuthenticated => 'Tu sesión expiró. Vuelve a entrar.';

  @override
  String get errorProfileIncomplete => 'Completa tu perfil primero.';

  @override
  String get errorAlreadyPaired => 'Ya tienes pareja.';

  @override
  String get errorTargetUnavailable => 'Ese flamengo no está disponible.';

  @override
  String get errorTargetPaired => 'Ese flamengo ya tiene pareja.';

  @override
  String get errorAlreadyRequested => 'Ya le enviaste una solicitud.';

  @override
  String errorMaxActiveRequests(int max) {
    return 'Solo puedes tener $max solicitudes activas.';
  }

  @override
  String get errorRequestUnavailable => 'Esta solicitud ya no está disponible.';

  @override
  String get errorSomeonePaired => 'Uno de los dos ya tiene pareja.';

  @override
  String get errorNotPaired => 'No tienes pareja.';

  @override
  String get errorNoDissolutionToCancel =>
      'No hay una disolución tuya que cancelar.';

  @override
  String get errorVerificationPending =>
      'Ya tienes una verificación en revisión.';
}

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
      'Al continuar confirmas que tienes 18 años o más y aceptas los Términos y la Política de privacidad.';

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
    return 'Revisa $email. Escribe el código o abre el enlace del correo.';
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
  String get resetDone => 'Contraseña actualizada';

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
  String get deleteAccountDone => 'Tu cuenta fue eliminada. ¡Buen vuelo!';

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
    return 'Solicitud enviada a $name. Tiene 48 h para responder.';
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
  String get discoverBoosted =>
      'Tienes un impulso: por 24 h saldrás primero para los demás. Mejora tu perfil para aprovecharlo.';

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
  String get requestsAcceptAction => 'Aceptar';

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
  String get coupleYouAskedToEnd => 'Pediste terminar';

  @override
  String couplePartnerAskedToEnd(String name) {
    return '$name quiere terminar';
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
  String get chatReply => 'Responder';

  @override
  String get chatEdit => 'Editar';

  @override
  String get chatCopy => 'Copiar';

  @override
  String get chatCopied => 'Copiado';

  @override
  String get chatEdited => 'editado';

  @override
  String get chatEditing => 'Editando mensaje';

  @override
  String get chatYou => 'Tú';

  @override
  String chatReplyingTo(String name) {
    return 'Respondiendo a $name';
  }

  @override
  String get chatMessageUnavailable => 'Mensaje no disponible';

  @override
  String chatSeen(String time) {
    return 'Visto $time';
  }

  @override
  String get chatSent => 'Enviado';

  @override
  String get chatTyping => 'escribiendo…';

  @override
  String get coupleOnline => 'En línea';

  @override
  String get myProfileTitle => 'Mi perfil';

  @override
  String get myProfileEdit => 'Editar perfil';

  @override
  String get tipPhotos =>
      'Sube al menos 3 fotos: los perfiles con más fotos reciben más solicitudes.';

  @override
  String get tipBio => 'Escribe algo sobre ti: es lo primero que leen.';

  @override
  String get tipPrompts => 'Responde una pregunta: dan de qué hablar.';

  @override
  String get tipTags =>
      'Elige tus etiquetas para aparecer primero a quien comparte tus gustos.';

  @override
  String get myProfilePreview => 'Ver como lo ven otros';

  @override
  String get profileCreateTitle => 'Crea tu perfil';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileCreateIntro =>
      'Cuéntale al mundo quién eres. Un buen perfil consigue más solicitudes';

  @override
  String get profilePhotos => 'Fotos';

  @override
  String profilePhotosHint(int max) {
    return 'La primera es tu foto principal · hasta $max';
  }

  @override
  String get profilePhotoView => 'Ver foto';

  @override
  String get profilePhotoMakeMain => 'Hacer principal';

  @override
  String get photoCropTitle => 'Ajusta tu foto';

  @override
  String get photoCropHint => 'Mueve y amplía con dos dedos para encuadrarla.';

  @override
  String get photoCropUse => 'Usar foto';

  @override
  String get tagChristian => 'Fe cristiana';

  @override
  String get tagCatholic => 'Fe católica';

  @override
  String get tagSpiritual => 'Espiritual';

  @override
  String get tagWorker => 'Trabaja';

  @override
  String get tagStudent => 'Estudia';

  @override
  String get tagEntrepreneur => 'Emprende';

  @override
  String get tagSports => 'Deportes';

  @override
  String get tagGym => 'Gimnasio';

  @override
  String get tagGamer => 'Videojuegos';

  @override
  String get tagReader => 'Lectura';

  @override
  String get tagTraveler => 'Viajes';

  @override
  String get tagFoodie => 'Buena comida';

  @override
  String get tagMusic => 'Música';

  @override
  String get tagDance => 'Baile';

  @override
  String get tagPets => 'Mascotas';

  @override
  String get tagNature => 'Naturaleza';

  @override
  String get tagBeach => 'Playa';

  @override
  String get tagHomebody => 'Planes en casa';

  @override
  String get tagParty => 'Fiesta';

  @override
  String get tagFamily => 'Familia';

  @override
  String get tagWantsKids => 'Quiere hijos';

  @override
  String get tagNoSmoking => 'No fuma';

  @override
  String get tagNoDrinking => 'No bebe';

  @override
  String get tagSerious => 'Relación seria';

  @override
  String get tagsTitle => 'Etiquetas';

  @override
  String tagsHint(int max) {
    return 'Elige hasta $max. Te mostramos primero a quien comparte las tuyas.';
  }

  @override
  String get tagsMustTitle => 'Imprescindibles';

  @override
  String tagsMustHint(int max) {
    return 'Solo verás a quien tenga estas etiquetas (hasta $max).';
  }

  @override
  String tagsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en común',
      one: '1 en común',
    );
    return '$_temp0';
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
  String get profileBirthdateShort => 'Nacimiento';

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
  String get genderEveryone => 'Todos';

  @override
  String get profileLookingFor => 'Busco';

  @override
  String get profileLookingForHint => 'Puedes elegir varias opciones';

  @override
  String get profileAboutMe => 'Sobre mí';

  @override
  String get profileAboutYou => 'Sobre ti';

  @override
  String get profileBioHint =>
      'Lo que te hace sonreír, tu plan ideal, tu canción…';

  @override
  String get profileStart => 'Empezar a volar';

  @override
  String get profileSave => 'Guardar cambios';

  @override
  String profileMissing(String items) {
    return 'Falta $items.';
  }

  @override
  String get profileMissingName => 'tu nombre';

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
  String get notifPhotoRejected =>
      'Quitamos una de tus fotos porque no cumple las normas.';

  @override
  String get notifBoostStarted =>
      'Tu perfil tiene un impulso de 24 h: saldrás primero en Descubrir.';

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
  String get settingsAppearance => 'Apariencia';

  @override
  String get appearanceTheme => 'Tema';

  @override
  String get themeFirefly => 'Firefly';

  @override
  String get themeSpicebug => 'Spicebug';

  @override
  String get themeLight => 'Cricket';

  @override
  String get themeDark => 'Cricket';

  @override
  String get themeCaribe => 'Caribe';

  @override
  String get themeCaribeHint => 'Turquesa';

  @override
  String get themeCoral => 'Coral';

  @override
  String get themeCoralHint => 'Durazno';

  @override
  String get themeMidnight => 'Medianoche';

  @override
  String get themeMidnightHint => 'Azul y oro';

  @override
  String get themeLavender => 'Lavanda';

  @override
  String get themeLavenderHint => 'Lila pastel';

  @override
  String get themeGraphite => 'Grafito';

  @override
  String get themeGraphiteHint => 'Gris y rojo';

  @override
  String get themeFireflyHint => 'Noche rosa';

  @override
  String get themeSpicebugHint => 'Verde profundo';

  @override
  String get themeLightHint => 'Claro';

  @override
  String get themeDarkHint => 'Oscuro';

  @override
  String get settingsLegal => 'Ayuda y legal';

  @override
  String get settingsMadeBy => 'Flamengos · CreativeMinds by Andresnael';

  @override
  String get appearanceFont => 'Fuente';

  @override
  String get appearanceTextSize => 'Tamaño del texto';

  @override
  String get appearanceTextCase => 'Formato de letras';

  @override
  String get textCaseNormal => 'Normal';

  @override
  String get textCaseUpper => 'MAYÚSCULAS';

  @override
  String get textCaseLower => 'minúsculas';

  @override
  String get textCaseTitle => 'Tipo Título';

  @override
  String coupleMapTitle(int km) {
    return 'Están a $km km';
  }

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get helpSubtitle => 'Preguntas frecuentes y contacto';

  @override
  String get helpContact => 'Escríbenos';

  @override
  String get legalTerms => 'Términos';

  @override
  String get legalPrivacy => 'Privacidad';

  @override
  String get faqExclusiveQ => '¿Cómo funciona la exclusividad?';

  @override
  String get faqExclusiveA =>
      'Puedes pedirle pareja a varios flamengos, pero cuando alguien acepta (o tú aceptas), quedan emparejados solo entre ustedes dos. Mientras sean pareja no aparecen en Descubrir ni pueden recibir solicitudes.';

  @override
  String get faqRequestsQ => '¿Cuántas solicitudes puedo enviar?';

  @override
  String get faqRequestsA =>
      'Hasta 3 a la vez. Cada una expira en 48 horas si no responden, y puedes cancelarla antes si te cansas de esperar.';

  @override
  String get faqAcceptQ => '¿Qué pasa cuando acepto a alguien?';

  @override
  String get faqAcceptA =>
      'Se crea la pareja y todas sus demás solicitudes, enviadas y recibidas, se anulan automáticamente.';

  @override
  String get faqEndQ => '¿Cómo termino una pareja?';

  @override
  String get faqEndA =>
      'Desde el menú de tu pareja. Si solo uno quiere terminar, se disuelve en 12 horas (y puedes arrepentirte antes). Si los dos quieren, es inmediato.';

  @override
  String get faqLocationQ => '¿Quién ve mi ubicación?';

  @override
  String get faqLocationA =>
      'Solo guardamos una zona aproximada (unos 2 km), nunca tu ubicación exacta. Los demás ven la distancia aproximada y un punto aproximado en el mapa.';

  @override
  String get faqSafetyQ => '¿Cómo reporto o bloqueo a alguien?';

  @override
  String get faqSafetyA =>
      'Abre su perfil y toca \"Reportar o bloquear\". No le avisaremos. Al bloquear, dejan de verse y, si eran pareja, se termina de inmediato.';

  @override
  String get faqVerifyQ => '¿Para qué sirve verificarme?';

  @override
  String get faqVerifyA =>
      'Tu perfil muestra una insignia que confirma que eres tú. Te tomas una selfie imitando una pose y un moderador la compara con tus fotos.';

  @override
  String get faqDeleteQ => '¿Cómo elimino mi cuenta?';

  @override
  String get faqDeleteA =>
      'En Ajustes → Cuenta → Eliminar cuenta. Se borran tu perfil, fotos, solicitudes y conversaciones. No se puede deshacer.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Del dispositivo';

  @override
  String get settingsVerification => 'Verificación';

  @override
  String get lockTitle => 'Flamengos está bloqueado';

  @override
  String get lockMessage =>
      'Usa tu huella, tu rostro o el PIN del teléfono para entrar.';

  @override
  String get lockUnlock => 'Desbloquear';

  @override
  String get lockReason => 'Desbloquea Flamengos';

  @override
  String get lockSetting => 'Bloqueo con huella o rostro';

  @override
  String get lockSettingHint => 'Se pide al abrir la app.';

  @override
  String get lockMobileOnly => 'Disponible en la app de Android e iOS.';

  @override
  String get lockPasswordTitle => 'Confirma tu contraseña';

  @override
  String get lockPasswordMessage =>
      'Se guarda cifrada en este teléfono para que puedas entrar con tu huella o rostro.';

  @override
  String get lockEnable => 'Activar';

  @override
  String get loginBiometric => 'Entrar con huella o rostro';

  @override
  String get lockUnavailable =>
      'Este teléfono no tiene huella, rostro ni PIN configurado.';

  @override
  String get settingsSafety => 'Seguridad';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get insightsTitle => 'Mis estadísticas';

  @override
  String get insightsLocked =>
      'Con Premium ves tu tiempo en la app, tus conexiones, cuánto duraron tus parejas y por qué terminaron.';

  @override
  String get insightsTime => 'Tiempo en la app';

  @override
  String get insightsToday => 'Hoy';

  @override
  String get insights7d => '7 días';

  @override
  String get insights30d => '30 días';

  @override
  String get insightsConnections => 'Conexiones';

  @override
  String get insightsSent => 'Enviadas';

  @override
  String get insightsReceived => 'Recibidas';

  @override
  String get insightsAccepted => 'Te aceptaron';

  @override
  String get insightsDeclined => 'Rechazadas';

  @override
  String get insightsExpired => 'Expiraron';

  @override
  String get insightsYouAccepted => 'Aceptaste';

  @override
  String insightsAcceptRate(int pct) {
    return 'Te aceptan el $pct% de las solicitudes que se resuelven.';
  }

  @override
  String get insightsCouples => 'Parejas';

  @override
  String get insightsAverage => 'Promedio';

  @override
  String get insightsLongest => 'La más larga';

  @override
  String get insightsWhyEnded => 'Por qué terminaron';

  @override
  String get insightsHistory => 'Historial';

  @override
  String get insightsOngoing => 'en curso';

  @override
  String get insightsEmptyCouples => 'Aún no has tenido pareja en Flamengos.';

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
      other: '$n días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get endNoChemistry => 'No hubo química';

  @override
  String get endDifferentGoals => 'Buscábamos cosas distintas';

  @override
  String get endDistance => 'La distancia';

  @override
  String get endCommunication => 'Falta de comunicación';

  @override
  String get endMetSomeone => 'Conocí a alguien más';

  @override
  String get endDisrespect => 'Falta de respeto';

  @override
  String get endOther => 'Otra razón';

  @override
  String get endSurveyTitle => '¿Por qué terminan?';

  @override
  String get endSurveyMessage =>
      'Es privado: solo tú lo verás en tus estadísticas.';

  @override
  String get endSurveySkip => 'Prefiero no decirlo';

  @override
  String get adminTitle => 'Administración';

  @override
  String get adminVerifications => 'Verificaciones';

  @override
  String get adminPhotos => 'Fotos';

  @override
  String get adminReports => 'Reportes';

  @override
  String get adminApprove => 'Aprobar';

  @override
  String get adminReject => 'Rechazar';

  @override
  String get adminDismiss => 'Descartar';

  @override
  String get adminBan => 'Bloquear cuenta';

  @override
  String get adminEmpty => 'Nada pendiente';

  @override
  String get errorNotAdmin => 'Esta sección es solo para administradores.';

  @override
  String get errorPremiumRequired => 'Esto es parte de Premium.';

  @override
  String adminPose(String pose) {
    return 'Pose pedida: $pose';
  }

  @override
  String adminReportedBy(String name) {
    return 'Reportado por $name';
  }

  @override
  String adminBanConfirm(String name) {
    return '$name no podrá entrar más, saldrá de Descubrir y se terminará su pareja. ¿Seguro?';
  }

  @override
  String adminApproveAll(int count) {
    return 'Aprobar todas ($count)';
  }

  @override
  String adminOpenReports(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reportes abiertos',
      one: '1 reporte abierto',
    );
    return '$_temp0';
  }

  @override
  String get notifDailyPicks => 'Tus flamengos del día están listos.';

  @override
  String notifNewNearby(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $count personas nuevas cerca que comparten tus gustos.',
      one: 'Hay 1 persona nueva cerca que comparte tus gustos.',
    );
    return '$_temp0';
  }

  @override
  String notifDailyAnswer(String name) {
    return '$name respondió la pregunta del día.';
  }

  @override
  String get dailyPicksButton => 'Del día';

  @override
  String get dailyPicksTitle => 'Flamengos del día';

  @override
  String get dailyPicksSubtitle =>
      'Escogidos para ti por lo que tienen en común. Mañana hay nuevos.';

  @override
  String get dailyPicksEmpty =>
      'Hoy no hay sugerencias. Prueba ampliar tus filtros.';

  @override
  String get dailyQuestionTitle => 'Pregunta del día';

  @override
  String get dailyQuestionHint => 'Tu respuesta…';

  @override
  String get dailyQuestionSend => 'Responder';

  @override
  String dailyQuestionWaiting(String name) {
    return '$name aún no responde.';
  }

  @override
  String dailyQuestionPartnerAnswered(String name) {
    return '$name ya respondió. Responde para ver qué dijo.';
  }

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días de racha',
      one: '1 día de racha',
    );
    return '$_temp0';
  }

  @override
  String get streakHint =>
      'La racha sube cada día que los dos se escriben o responden la pregunta del día.';

  @override
  String get streakTodayPending =>
      'Hoy aún no cuenta: falta que los dos se escriban.';

  @override
  String get dailyQuestion0 => '¿Cuál fue el mejor momento de tu semana?';

  @override
  String get dailyQuestion1 => '¿Qué canción te recuerda a nosotros?';

  @override
  String get dailyQuestion2 => 'Si pudiéramos viajar mañana, ¿a dónde iríamos?';

  @override
  String get dailyQuestion3 => '¿Qué es lo primero que notaste de mí?';

  @override
  String get dailyQuestion4 => '¿Cuál es tu comida favorita para compartir?';

  @override
  String get dailyQuestion5 => '¿Qué te hace sentir amor?';

  @override
  String get dailyQuestion6 => 'Describe tu domingo perfecto.';

  @override
  String get dailyQuestion7 => '¿Qué meta tienes para este año?';

  @override
  String get dailyQuestion8 => '¿Qué película veríamos juntos esta noche?';

  @override
  String get dailyQuestion9 => '¿Qué recuerdo de tu infancia te hace sonreír?';

  @override
  String get dailyQuestion10 => '¿Qué valoras más en una pareja?';

  @override
  String get dailyQuestion11 => '¿Playa o montaña? ¿Por qué?';

  @override
  String get dailyQuestion12 =>
      '¿Qué te gustaría que hiciéramos juntos por primera vez?';

  @override
  String get dailyQuestion13 => '¿Qué te ha tenido pensando últimamente?';

  @override
  String get dailyQuestion14 => '¿Qué tradición familiar te gustaría mantener?';

  @override
  String get dailyQuestion15 => '¿Cuál es tu lenguaje del amor?';

  @override
  String get dailyQuestion16 => 'Si ganaras la lotería, ¿qué harías primero?';

  @override
  String get dailyQuestion17 => '¿Qué es algo que poca gente sabe de ti?';

  @override
  String get dailyQuestion18 => '¿Cómo sería nuestra cita ideal?';

  @override
  String get dailyQuestion19 => '¿Qué te hizo reír hoy?';

  @override
  String get dailyQuestion20 => '¿Qué libro, serie o podcast me recomiendas?';

  @override
  String get dailyQuestion21 => '¿Dónde te ves en cinco años?';

  @override
  String get dailyQuestion22 => '¿Qué detalle pequeño te alegra el día?';

  @override
  String get dailyQuestion23 => '¿Cuál es tu plato dominicano favorito?';

  @override
  String get dailyQuestion24 => '¿Qué cualidad mía te gusta más?';

  @override
  String get dailyQuestion25 => '¿Qué harías en un día sin teléfono?';

  @override
  String get dailyQuestion26 => '¿Cuál ha sido tu mejor viaje?';

  @override
  String get dailyQuestion27 => '¿Qué te gustaría aprender este año?';

  @override
  String get dailyQuestion28 => 'Si fueras un animal, ¿cuál serías?';

  @override
  String get dailyQuestion29 => '¿Qué significa para ti una relación sana?';

  @override
  String get rulesTitle => 'Así funciona Flamengos';

  @override
  String get rulesSubtitle =>
      'Antes de empezar, lee las reglas. Son las que hacen distinta a esta app.';

  @override
  String get rulesExclusiveTitle => 'Una sola pareja';

  @override
  String get rulesExclusiveBody =>
      'Cuando aceptas a alguien (o te acepta), quedan en exclusiva: mientras la pareja esté activa no podrás pedir ni aceptar a nadie más, y todas sus demás solicitudes se anulan.';

  @override
  String get rulesLeaveTitle => 'Siempre puedes salir';

  @override
  String get rulesLeaveBody =>
      'Terminar toma 12 horas y puedes arrepentirte antes. Si los dos quieren terminar, es inmediato.';

  @override
  String get rulesRequestsTitle => 'Solicitudes con tiempo';

  @override
  String get rulesRequestsBody =>
      'Puedes tener hasta 3 solicitudes a la vez (5 con Premium) y cada una expira en 48 horas.';

  @override
  String get rulesRespectTitle => 'Respeto y seguridad';

  @override
  String get rulesRespectBody =>
      'Solo mayores de 18, con fotos reales. Revisamos fotos y reportes, y puedes bloquear a quien quieras.';

  @override
  String get rulesAgree =>
      'Tengo 18 años o más, entiendo la exclusividad y acepto los Términos y la Política de privacidad.';

  @override
  String get rulesAccept => 'Aceptar y continuar';

  @override
  String get signOutEverywhere => 'Cerrar sesión en todos los dispositivos';

  @override
  String get signOutEverywhereMessage =>
      'Se cerrará tu sesión aquí y en cualquier otro teléfono o navegador donde hayas entrado.';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumFounder => 'Fundador: premium para siempre';

  @override
  String premiumUntil(String date) {
    return 'Premium hasta el $date';
  }

  @override
  String get premiumPerksTitle => 'Beneficios Premium';

  @override
  String get premiumFree => 'Cuenta gratis';

  @override
  String get premiumComingSoon =>
      'Muy pronto podrás activar Premium desde aquí.';

  @override
  String premiumPerkRequests(int count) {
    return '$count solicitudes activas a la vez';
  }

  @override
  String get premiumPerkIncognito => 'Modo incógnito';

  @override
  String get premiumPerkSeen => 'Saber cuándo leen tus mensajes';

  @override
  String get premiumPerkTyping =>
      'Ver si tu pareja está escribiendo o en línea';

  @override
  String get premiumIncognitoHint =>
      'No apareces en Descubrir. Solo te ve quien recibe tu solicitud.';

  @override
  String get premiumOnly => 'Solo con Premium';

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
  String get errorEditWindowClosed =>
      'Ya pasó el minuto para editar ese mensaje.';

  @override
  String get errorVerificationPending =>
      'Ya tienes una verificación en revisión.';
}

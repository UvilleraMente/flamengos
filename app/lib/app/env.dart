/// Configuración de Supabase. La anon key es pública por diseño: la seguridad
/// la imponen las políticas RLS y las funciones del servidor.
///
/// Se puede sobreescribir con:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://rwtaqddyfgeyueiqkjfr.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3dGFxZGR5ZmdleXVlaXFramZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIwMDEzNTIsImV4cCI6MjEwNzU3NzM1Mn0.TZnHU7p0EfRXTYItckbCNNXbKnhJf50bctQcaqjWb34',
  );

  /// MapTiler (mapas y búsqueda de lugares). Es una clave de cliente:
  /// protégela restringiendo los dominios/apps permitidos en
  /// cloud.maptiler.com → Account → Keys.
  static const mapTilerKey = String.fromEnvironment(
    'MAPTILER_KEY',
    defaultValue: 'uXYSJvxRc9r63hrqOHRX',
  );

  /// Clave VAPID de Firebase para push en web (Firebase → Configuración del
  /// proyecto → Cloud Messaging → Certificados push web). Vacía = sin push web.
  static const firebaseVapidKey = String.fromEnvironment('FIREBASE_VAPID_KEY');

  /// Sitio público (Firebase Hosting): términos, privacidad, borrar cuenta.
  static const websiteUrl = 'https://flamengos-app.web.app';
  static const termsUrl = '$websiteUrl/terminos';
  static const privacyUrl = '$websiteUrl/privacidad';

  /// Versión de los términos y la privacidad. Al cambiarla, la app vuelve a
  /// pedir que se acepten (ver terms_acceptances en el SQL).
  static const termsVersion = '2026-10-16';

  /// Correo de soporte (vacío = se oculta el botón de contacto).
  static const supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'creativeminds.devs@gmail.com',
  );

  /// Deben coincidir con max_active_requests() en el SQL.
  static const maxActiveRequests = 3;
  static const premiumMaxActiveRequests = 5;
}

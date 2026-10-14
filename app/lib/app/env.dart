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

  /// Estilo del mapa (versión oscura del "streets-v4" de MapTiler).
  static const mapTilerStyle = 'streets-v4-dark';

  /// Debe coincidir con cfg_max_active_requests() en el SQL.
  static const maxActiveRequests = 3;
}

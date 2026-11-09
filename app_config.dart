/// Build-time configuration, injected with --dart-define-from-file=env.json.
/// Only PUBLIC values belong here (Supabase URL + anon key). Never put the AI key
/// or the Supabase service_role key in the app.
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static const appName = 'Student Buddy';
  static const version = '0.1.0';
}

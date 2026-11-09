import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/state/settings_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/logo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isConfigured) {
    // Honest failure instead of a half-working app.
    runApp(const _ConfigMissingApp());
    return;
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const StudentBuddyApp(),
  ));
}

class _ConfigMissingApp extends StatelessWidget {
  const _ConfigMissingApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LogoMark(size: 88),
                  SizedBox(height: 24),
                  Text('Student Buddy is not configured',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),
                  SizedBox(height: 12),
                  Text(
                    'SUPABASE_URL and SUPABASE_ANON_KEY were not provided at build time.\n\n'
                    'Create env.json from env.example.json and run:\n'
                    'flutter run --dart-define-from-file=env.json',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLang { english, urdu, romanUrdu }

/// Overridden in main() with the real SharedPreferences instance.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider not overridden'),
);

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.lang,
    required this.guest,
  });
  final ThemeMode themeMode;
  final AppLang lang;
  final bool guest;

  SettingsState copyWith({ThemeMode? themeMode, AppLang? lang, bool? guest}) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        lang: lang ?? this.lang,
        guest: guest ?? this.guest,
      );
}

class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _prefs;

  @override
  SettingsState build() {
    _prefs = ref.read(sharedPrefsProvider);
    final theme = _prefs.getString('theme');
    final lang = _prefs.getString('lang');
    return SettingsState(
      themeMode: ThemeMode.values.firstWhere((m) => m.name == theme,
          orElse: () => ThemeMode.system),
      lang: AppLang.values.firstWhere((l) => l.name == lang,
          orElse: () => AppLang.english),
      guest: _prefs.getBool('guest') ?? false,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString('theme', mode.name);
  }

  Future<void> setLang(AppLang lang) async {
    state = state.copyWith(lang: lang);
    await _prefs.setString('lang', lang.name);
  }

  Future<void> setGuest(bool value) async {
    state = state.copyWith(guest: value);
    await _prefs.setBool('guest', value);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

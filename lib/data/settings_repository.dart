import 'package:shared_preferences/shared_preferences.dart';

enum ThemePref { system, light, dark }

class SettingsRepository {
  static const _kTheme = 'settings_theme';
  static const _kSound = 'settings_sound';
  static const _kMusic = 'settings_music';
  static const _kHaptics = 'settings_haptics';
  static const _kTutorialSeen = 'settings_tutorial_seen';

  final SharedPreferences prefs;

  SettingsRepository(this.prefs);

  ThemePref get theme {
    final v = prefs.getString(_kTheme);
    return ThemePref.values.firstWhere(
      (e) => e.name == v,
      orElse: () => ThemePref.system,
    );
  }

  Future<void> setTheme(ThemePref value) =>
      prefs.setString(_kTheme, value.name);

  bool get soundEnabled => prefs.getBool(_kSound) ?? true;
  Future<void> setSoundEnabled(bool value) => prefs.setBool(_kSound, value);

  bool get musicEnabled => prefs.getBool(_kMusic) ?? true;
  Future<void> setMusicEnabled(bool value) => prefs.setBool(_kMusic, value);

  bool get hapticsEnabled => prefs.getBool(_kHaptics) ?? true;
  Future<void> setHapticsEnabled(bool value) => prefs.setBool(_kHaptics, value);

  bool get tutorialSeen => prefs.getBool(_kTutorialSeen) ?? false;
  Future<void> setTutorialSeen(bool value) =>
      prefs.setBool(_kTutorialSeen, value);
}

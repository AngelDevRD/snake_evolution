import 'package:shared_preferences/shared_preferences.dart';

enum ThemePref { system, light, dark }

/// Movement speed presets. [tickMs] is the base tick interval consumed by
/// the game loop; lower is faster. Values chosen so `normal` matches the
/// game's original fixed 160ms tick (classic Snake pacing).
enum SpeedLevel {
  muyLenta(260, 'Muy lenta'),
  lenta(200, 'Lenta'),
  normal(160, 'Normal'),
  rapida(120, 'Rápida'),
  muyRapida(90, 'Muy rápida'),
  extrema(60, 'Extrema');

  final int tickMs;
  final String label;
  const SpeedLevel(this.tickMs, this.label);
}

/// Board size presets. [cells] is the width/height of the (square) grid;
/// `normal` matches the game's original fixed 20x20 board.
enum BoardSizeLevel {
  pequeno(14, 'Pequeño'),
  normal(20, 'Normal'),
  grande(26, 'Grande'),
  muyGrande(32, 'Muy grande');

  final int cells;
  final String label;
  const BoardSizeLevel(this.cells, this.label);
}

class SettingsRepository {
  static const _kTheme = 'settings_theme';
  static const _kSound = 'settings_sound';
  static const _kMusic = 'settings_music';
  static const _kHaptics = 'settings_haptics';
  static const _kTutorialSeen = 'settings_tutorial_seen';
  static const _kSpeed = 'settings_speed';
  static const _kBoardSize = 'settings_board_size';

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

  SpeedLevel get speed {
    final v = prefs.getString(_kSpeed);
    return SpeedLevel.values.firstWhere(
      (e) => e.name == v,
      orElse: () => SpeedLevel.normal,
    );
  }

  Future<void> setSpeed(SpeedLevel value) =>
      prefs.setString(_kSpeed, value.name);

  BoardSizeLevel get boardSize {
    final v = prefs.getString(_kBoardSize);
    return BoardSizeLevel.values.firstWhere(
      (e) => e.name == v,
      orElse: () => BoardSizeLevel.normal,
    );
  }

  Future<void> setBoardSize(BoardSizeLevel value) =>
      prefs.setString(_kBoardSize, value.name);
}

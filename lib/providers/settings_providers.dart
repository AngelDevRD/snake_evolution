import 'package:flutter_riverpod/legacy.dart';

import '../data/settings_repository.dart';
import 'repository_providers.dart';

class SettingsState {
  final ThemePref theme;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool tutorialSeen;

  const SettingsState({
    required this.theme,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.hapticsEnabled,
    required this.tutorialSeen,
  });

  SettingsState copyWith({
    ThemePref? theme,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? tutorialSeen,
  }) => SettingsState(
    theme: theme ?? this.theme,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    musicEnabled: musicEnabled ?? this.musicEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    tutorialSeen: tutorialSeen ?? this.tutorialSeen,
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo)
    : super(
        SettingsState(
          theme: _repo.theme,
          soundEnabled: _repo.soundEnabled,
          musicEnabled: _repo.musicEnabled,
          hapticsEnabled: _repo.hapticsEnabled,
          tutorialSeen: _repo.tutorialSeen,
        ),
      );

  Future<void> setTheme(ThemePref value) async {
    await _repo.setTheme(value);
    state = state.copyWith(theme: value);
  }

  Future<void> setSoundEnabled(bool value) async {
    await _repo.setSoundEnabled(value);
    state = state.copyWith(soundEnabled: value);
  }

  Future<void> setMusicEnabled(bool value) async {
    await _repo.setMusicEnabled(value);
    state = state.copyWith(musicEnabled: value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    await _repo.setHapticsEnabled(value);
    state = state.copyWith(hapticsEnabled: value);
  }

  Future<void> setTutorialSeen(bool value) async {
    await _repo.setTutorialSeen(value);
    state = state.copyWith(tutorialSeen: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier(ref.watch(settingsRepositoryProvider));
  },
);

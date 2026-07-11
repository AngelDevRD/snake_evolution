import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings_repository.dart';
import '../../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(_themeLabel(settings.theme)),
            trailing: SegmentedButton<ThemePref>(
              segments: const [
                ButtonSegment(
                  value: ThemePref.system,
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemePref.light,
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemePref.dark,
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {settings.theme},
              onSelectionChanged: (value) => notifier.setTheme(value.first),
            ),
          ),
          ListTile(
            title: const Text('Velocidad'),
            subtitle: Text(settings.speed.label),
            leading: const Icon(Icons.speed),
            trailing: DropdownButton<SpeedLevel>(
              value: settings.speed,
              underline: const SizedBox.shrink(),
              items: SpeedLevel.values
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) notifier.setSpeed(value);
              },
            ),
          ),
          ListTile(
            title: const Text('Tamaño del tablero'),
            subtitle: Text(
              '${settings.boardSize.label} (${settings.boardSize.cells}x${settings.boardSize.cells})',
            ),
            leading: const Icon(Icons.grid_4x4),
            trailing: DropdownButton<BoardSizeLevel>(
              value: settings.boardSize,
              underline: const SizedBox.shrink(),
              items: BoardSizeLevel.values
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) notifier.setBoardSize(value);
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Sonido'),
            secondary: const Icon(Icons.volume_up),
            value: settings.soundEnabled,
            onChanged: notifier.setSoundEnabled,
          ),
          SwitchListTile(
            title: const Text('Música'),
            secondary: const Icon(Icons.music_note),
            value: settings.musicEnabled,
            onChanged: notifier.setMusicEnabled,
          ),
          SwitchListTile(
            title: const Text('Vibración'),
            secondary: const Icon(Icons.vibration),
            value: settings.hapticsEnabled,
            onChanged: notifier.setHapticsEnabled,
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ver tutorial de nuevo'),
            onTap: () => notifier.setTutorialSeen(false),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemePref pref) {
    switch (pref) {
      case ThemePref.system:
        return 'Automático (sistema)';
      case ThemePref.light:
        return 'Claro';
      case ThemePref.dark:
        return 'Oscuro';
    }
  }
}

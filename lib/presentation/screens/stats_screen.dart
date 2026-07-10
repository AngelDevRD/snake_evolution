import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/progress_providers.dart';
import '../../providers/stats_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final progress = ref.watch(progressProvider);
    final minutes = stats.totalPlayTimeSeconds ~/ 60;
    final seconds = stats.totalPlayTimeSeconds % 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatTile(
            icon: Icons.videogame_asset,
            label: 'Partidas jugadas',
            value: '${stats.gamesPlayed}',
          ),
          _StatTile(
            icon: Icons.straighten,
            label: 'Mejor longitud',
            value: '${stats.bestLength}',
          ),
          _StatTile(
            icon: Icons.restaurant,
            label: 'Alimentos comidos',
            value: '${stats.totalFoodEaten}',
          ),
          _StatTile(
            icon: Icons.timer,
            label: 'Tiempo total jugado',
            value: '${minutes}m ${seconds}s',
          ),
          _StatTile(
            icon: Icons.emoji_events,
            label: 'Mejor puntaje',
            value: '${progress.bestScore}',
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

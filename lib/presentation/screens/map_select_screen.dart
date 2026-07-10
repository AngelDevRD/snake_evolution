import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/game_map.dart';

class MapSelectScreen extends StatelessWidget {
  const MapSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elige un mapa')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MapCard(
                  title: GameMapDef.classicArena().name,
                  subtitle: 'Tablero abierto, sin obstáculos.',
                  icon: Icons.crop_square,
                  onTap: () => context.push('/game', extra: MapId.classicArena),
                ),
                const SizedBox(height: 16),
                _MapCard(
                  title: GameMapDef.obstacleField().name,
                  subtitle: 'Bloques fijos que también terminan la partida.',
                  icon: Icons.grid_view,
                  onTap: () =>
                      context.push('/game', extra: MapId.obstacleField),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MapCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

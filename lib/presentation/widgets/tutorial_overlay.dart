import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_providers.dart';

/// First-launch overlay explaining controls and power-ups. Dismissal is
/// persisted via SettingsRepository.tutorialSeen so it only shows once.
class TutorialOverlay extends ConsumerWidget {
  const TutorialOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cómo jugar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Desliza el dedo sobre el tablero o usa los botones '
                  'direccionales para mover la serpiente. Come la comida '
                  'para crecer y evita chocar contra paredes, obstáculos '
                  'o tu propio cuerpo.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Power-ups',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const _PowerUpRow(
                  icon: Icons.bolt,
                  color: Colors.yellow,
                  label: 'Velocidad: acelera el juego temporalmente',
                ),
                const _PowerUpRow(
                  icon: Icons.shield,
                  color: Colors.blueAccent,
                  label: 'Escudo: absorbe un choque',
                ),
                const _PowerUpRow(
                  icon: Icons.control_camera,
                  color: Colors.purpleAccent,
                  label: 'Imán: atrae la comida hacia ti',
                ),
                const _PowerUpRow(
                  icon: Icons.star,
                  color: Colors.orangeAccent,
                  label: 'Multiplicador: puntos x2',
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => ref
                        .read(settingsProvider.notifier)
                        .setTutorialSeen(true),
                    child: const Text('Entendido'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PowerUpRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _PowerUpRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../domain/power_up.dart';

/// Shows currently-active power-up effects with their remaining duration.
class ActiveEffectsBar extends StatelessWidget {
  final ActiveEffects effects;

  const ActiveEffectsBar({super.key, required this.effects});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (effects.isSpeedActive) {
      chips.add(_chip(Icons.bolt, Colors.yellow, effects.speedTicks));
    }
    if (effects.hasShield) {
      chips.add(_chip(Icons.shield, Colors.blueAccent, null));
    }
    if (effects.isMagnetActive) {
      chips.add(
        _chip(Icons.control_camera, Colors.purpleAccent, effects.magnetTicks),
      );
    }
    if (effects.isMultiplierActive) {
      chips.add(
        _chip(Icons.star, Colors.orangeAccent, effects.multiplierTicks),
      );
    }
    if (chips.isEmpty) return const SizedBox(height: 32);
    return SizedBox(
      height: 32,
      child: Row(mainAxisSize: MainAxisSize.min, children: chips),
    );
  }

  Widget _chip(IconData icon, Color color, int? ticks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Chip(
        avatar: Icon(icon, color: color, size: 18),
        label: Text(ticks != null ? '$ticks' : ''),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

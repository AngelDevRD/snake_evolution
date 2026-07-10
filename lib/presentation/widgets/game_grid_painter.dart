import 'package:flutter/material.dart';

import '../../domain/game_engine.dart';
import '../../domain/game_map.dart';
import '../../domain/power_up.dart';
import '../../domain/skin.dart';
import 'snake_skin_preview.dart';

class GameGridPainter extends CustomPainter {
  final GameState game;
  final GameMapDef map;
  final SkinDef skin;
  final double particleProgress; // 0..1, drives the food/power-up pop effect
  final bool particleActive;

  GameGridPainter({
    required this.game,
    required this.map,
    required this.skin,
    required this.particleProgress,
    required this.particleActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / map.width;

    final bgPaint = Paint()..color = const Color(0xFF10151A);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final obstaclePaint = Paint()..color = const Color(0xFF4A4A4A);
    for (final o in map.obstacles) {
      canvas.drawRect(
        Rect.fromLTWH(o.x * cell, o.y * cell, cell, cell).deflate(1),
        obstaclePaint,
      );
    }

    if (game.food != null) {
      final foodPaint = Paint()..color = const Color(0xFFE53935);
      final center = Offset(
        game.food!.x * cell + cell / 2,
        game.food!.y * cell + cell / 2,
      );
      canvas.drawCircle(center, cell / 2.4, foodPaint);
    }

    if (game.powerUp != null) {
      final p = game.powerUp!;
      final center = Offset(
        p.position.x * cell + cell / 2,
        p.position.y * cell + cell / 2,
      );
      canvas.drawCircle(
        center,
        cell / 2.2,
        Paint()..color = _powerUpColor(p.type),
      );
    }

    for (var i = 0; i < game.snake.length; i++) {
      final segment = game.snake[i];
      final color = segmentColor(skin, i);
      final rect = Rect.fromLTWH(
        segment.x * cell,
        segment.y * cell,
        cell,
        cell,
      ).deflate(1.2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..color = i == 0
              ? color.withValues(alpha: 1)
              : color.withValues(alpha: 0.9),
      );
    }

    if (particleActive) {
      _paintParticles(canvas, cell);
    }
  }

  void _paintParticles(Canvas canvas, double cell) {
    final origin = game.food ?? game.snake.first;
    final center = Offset(
      origin.x * cell + cell / 2,
      origin.y * cell + cell / 2,
    );
    final paint = Paint()
      ..color = Colors.white.withValues(
        alpha: (1 - particleProgress).clamp(0.0, 1.0),
      );
    final radius = cell * (0.4 + particleProgress * 1.2);
    canvas.drawCircle(
      center,
      radius,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  Color _powerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.speed:
        return Colors.yellow;
      case PowerUpType.shield:
        return Colors.blueAccent;
      case PowerUpType.magnet:
        return Colors.purpleAccent;
      case PowerUpType.multiplier:
        return Colors.orangeAccent;
    }
  }

  @override
  bool shouldRepaint(covariant GameGridPainter oldDelegate) => true;
}

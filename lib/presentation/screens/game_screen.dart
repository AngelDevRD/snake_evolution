import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/game_engine.dart';
import '../../domain/game_map.dart';
import '../../domain/position.dart';
import '../../domain/skin.dart';
import '../../providers/game_providers.dart';
import '../../providers/progress_providers.dart';
import '../widgets/active_effects_bar.dart';
import '../widgets/dpad_controls.dart';
import '../widgets/game_grid_painter.dart';

class GameScreen extends ConsumerStatefulWidget {
  final MapId mapId;

  const GameScreen({super.key, required this.mapId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  static const _swipeThreshold = 12.0;
  late final AnimationController _particleController;
  bool _particleActive = false;
  int _lastFoodEaten = 0;
  int _lastPowerUps = 0;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startGame(widget.mapId);
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _handlePan(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;
    if (dx.abs() < _swipeThreshold && dy.abs() < _swipeThreshold) return;
    final notifier = ref.read(gameProvider.notifier);
    if (dx.abs() > dy.abs()) {
      notifier.queueDirection(dx > 0 ? Direction.right : Direction.left);
    } else {
      notifier.queueDirection(dy > 0 ? Direction.down : Direction.up);
    }
  }

  void _maybeTriggerParticle(GameState game) {
    if (game.foodEaten != _lastFoodEaten ||
        game.powerUpsCollected != _lastPowerUps) {
      _lastFoodEaten = game.foodEaten;
      _lastPowerUps = game.powerUpsCollected;
      setState(() => _particleActive = true);
      _particleController.forward(from: 0).then((_) {
        if (mounted) setState(() => _particleActive = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final runState = ref.watch(gameProvider);
    final skin = skinById(ref.watch(progressProvider).selectedSkinId);
    final map = GameMapDef.byId(widget.mapId);

    ref.listen(gameProvider, (previous, next) {
      _maybeTriggerParticle(next.game);
      if (next.game.status == GameStatus.gameOver && !_dialogShown) {
        _dialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _showGameOverDialog(next),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Puntaje: ${runState.game.score}')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final boardSize = isWide
                ? constraints.maxHeight - 32
                : constraints.maxWidth - 32;

            final board = GestureDetector(
              onPanUpdate: _handlePan,
              child: SizedBox(
                width: boardSize,
                height: boardSize,
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: GameGridPainter(
                        game: runState.game,
                        map: map,
                        skin: skin,
                        particleProgress: _particleController.value,
                        particleActive: _particleActive,
                      ),
                    );
                  },
                ),
              ),
            );

            final controls = Padding(
              padding: const EdgeInsets.all(16),
              child: DpadControls(
                onDirection: (d) =>
                    ref.read(gameProvider.notifier).queueDirection(d),
              ),
            );

            final effectsBar = ActiveEffectsBar(effects: runState.game.effects);

            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [effectsBar, board],
                  ),
                  controls,
                ],
              );
            }
            return Column(
              children: [
                effectsBar,
                Expanded(child: Center(child: board)),
                controls,
              ],
            );
          },
        ),
      ),
    );
  }

  void _showGameOverDialog(GameRunState runState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final progress = ref.read(progressProvider);
        return AlertDialog(
          title: const Text('Fin de la partida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Puntaje: ${runState.game.score}'),
              Text('Longitud: ${runState.game.snake.length}'),
              Text('Mejor puntaje: ${progress.bestScore}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Inicio'),
            ),
            FilledButton(
              onPressed: () {
                _dialogShown = false;
                _lastFoodEaten = 0;
                _lastPowerUps = 0;
                Navigator.of(context).pop();
                ref.read(gameProvider.notifier).startGame(widget.mapId);
              },
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }
}

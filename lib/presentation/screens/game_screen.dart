import 'dart:math' as math;

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
    // Only the map (grid dimensions) is watched here: it's fixed for the
    // whole run (set once in startGame from the board-size setting), so this
    // doesn't cause a rebuild on every tick. Per-tick game state is read by
    // the narrow Consumer widgets below (score, board, effects bar) so the
    // rest of this tree (Scaffold chrome, DpadControls, layout math) is only
    // rebuilt when the map or skin actually change, not 5-10 times/second.
    final map = ref.watch(gameProvider.select((s) => s.map));
    final skin = skinById(ref.watch(progressProvider).selectedSkinId);

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
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final score = ref.watch(gameProvider.select((s) => s.game.score));
            return Text('Puntaje: $score');
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > constraints.maxHeight;
            // Reserve room for the effects bar and dpad controls so the
            // square board fills the rest of the available space without
            // overflowing or leaving dead margins, on any device size or
            // board grid dimension. The board is always the smaller of the
            // two available dimensions once chrome is subtracted, so cells
            // stay perfectly square.
            const effectsBarReserve = 32.0;
            const controlsReserve = 200.0;
            final mainAxisAvailable = isWide
                ? constraints.maxHeight - effectsBarReserve
                : constraints.maxWidth;
            final crossAxisAvailable = isWide
                ? constraints.maxWidth - controlsReserve
                : constraints.maxHeight - effectsBarReserve - controlsReserve;
            final boardSize = math.max(
              0.0,
              math.min(mainAxisAvailable, crossAxisAvailable),
            );

            final board = GestureDetector(
              onPanUpdate: _handlePan,
              child: SizedBox(
                width: boardSize,
                height: boardSize,
                child: Consumer(
                  builder: (context, ref, _) {
                    final game = ref.watch(gameProvider.select((s) => s.game));
                    return AnimatedBuilder(
                      animation: _particleController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: GameGridPainter(
                            game: game,
                            map: map,
                            skin: skin,
                            particleProgress: _particleController.value,
                            particleActive: _particleActive,
                          ),
                        );
                      },
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

            final effectsBar = Consumer(
              builder: (context, ref, _) {
                final effects = ref.watch(
                  gameProvider.select((s) => s.game.effects),
                );
                return ActiveEffectsBar(effects: effects);
              },
            );

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

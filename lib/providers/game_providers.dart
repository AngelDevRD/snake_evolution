import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../domain/achievement.dart';
import '../domain/game_engine.dart';
import '../domain/game_map.dart';
import '../domain/position.dart';
import '../domain/mission.dart';
import 'missions_providers.dart';
import 'progress_providers.dart';
import 'repository_providers.dart';
import 'settings_providers.dart';
import 'stats_providers.dart';

class GameRunState {
  final GameState game;
  final GameMapDef map;
  final DateTime? startedAt;

  const GameRunState({required this.game, required this.map, this.startedAt});

  GameRunState copyWith({
    GameState? game,
    GameMapDef? map,
    DateTime? startedAt,
  }) => GameRunState(
    game: game ?? this.game,
    map: map ?? this.map,
    startedAt: startedAt ?? this.startedAt,
  );
}

/// Drives the snake game loop with a self-rescheduling [Timer] (rather than
/// a fixed-interval Timer.periodic) so the tick rate can speed up while the
/// Speed power-up is active.
class GameNotifier extends StateNotifier<GameRunState> {
  final Ref ref;
  Timer? _timer;
  Direction? _queuedDirection;
  int _tickCount = 0;
  late GameEngine _engine;

  GameNotifier(this.ref)
    : _engine = GameEngine(GameMapDef.classicArena()),
      super(
        GameRunState(
          game: GameEngine(GameMapDef.classicArena()).initialState(),
          map: GameMapDef.classicArena(),
        ),
      );

  void startGame(MapId mapId) {
    _timer?.cancel();
    final boardSize = ref.read(settingsProvider).boardSize.cells;
    final map = GameMapDef.byId(mapId, size: boardSize);
    _engine = GameEngine(map);
    _tickCount = 0;
    _queuedDirection = null;
    state = GameRunState(
      game: _engine.initialState(),
      map: map,
      startedAt: DateTime.now(),
    );
    _scheduleTick();
  }

  void queueDirection(Direction direction) {
    _queuedDirection = direction;
  }

  void _scheduleTick() {
    final baseTickMs = ref.read(settingsProvider).speed.tickMs;
    final ms = state.game.effects.isSpeedActive
        ? (baseTickMs * 0.55).round()
        : baseTickMs;
    _timer = Timer(Duration(milliseconds: ms), _tick);
  }

  void _tick() {
    if (!mounted || state.game.status == GameStatus.gameOver) return;

    var game = state.game;
    if (_queuedDirection != null) {
      game = _engine.changeDirection(game, _queuedDirection!);
      _queuedDirection = null;
    }

    _tickCount++;
    if (_tickCount % 25 == 0) {
      game = _engine.maybeSpawnPowerUp(game, chance: 0.6);
    }

    final result = _engine.step(game);
    state = state.copyWith(game: result.state);

    final settings = ref.read(settingsProvider);
    if (result.ateFood || result.collectedPowerUp) {
      if (settings.hapticsEnabled) HapticFeedback.lightImpact();
      if (settings.soundEnabled) {
        ref
            .read(audioServiceProvider)
            .playSfx(result.ateFood ? 'eat.mp3' : 'powerup.mp3');
      }
    }

    if (result.ateFood) {
      ref.read(progressProvider.notifier).addCoins(1);
      ref
          .read(missionsProvider.notifier)
          .reportProgress(MissionType.eatFood, result.state.foodEaten);
      ref
          .read(missionsProvider.notifier)
          .reportProgress(MissionType.reachLength, result.state.snake.length);
    }

    if (result.gameOverJustNow) {
      if (settings.hapticsEnabled) HapticFeedback.heavyImpact();
      _finishGame();
      return;
    }

    _scheduleTick();
  }

  void _finishGame() {
    final game = state.game;
    final playSeconds = state.startedAt == null
        ? 0
        : DateTime.now().difference(state.startedAt!).inSeconds;

    ref
        .read(statsProvider.notifier)
        .recordGame(
          length: game.snake.length,
          foodEaten: game.foodEaten,
          playTimeSeconds: playSeconds,
          powerUpsCollected: game.powerUpsCollected,
        );
    ref.read(progressProvider.notifier).updateBestScore(game.score);
    ref
        .read(missionsProvider.notifier)
        .reportProgress(MissionType.surviveSeconds, playSeconds);

    _checkAchievements(playSeconds);
  }

  void _checkAchievements(int playSeconds) {
    final stats = ref.read(statsProvider);
    final progressNotifier = ref.read(progressProvider.notifier);
    for (final a in allAchievements) {
      final bool reached;
      switch (a.metric) {
        case AchievementMetric.maxLength:
          reached = stats.bestLength >= a.target;
          break;
        case AchievementMetric.gamesPlayed:
          reached = stats.gamesPlayed >= a.target;
          break;
        case AchievementMetric.powerUpsCollected:
          reached = stats.totalPowerUpsCollected >= a.target;
          break;
        case AchievementMetric.surviveSeconds:
          reached = playSeconds >= a.target;
          break;
      }
      if (reached) progressNotifier.unlockAchievement(a.id);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameRunState>((ref) {
  return GameNotifier(ref);
});

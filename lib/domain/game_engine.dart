import 'dart:math';

import 'game_map.dart';
import 'position.dart';
import 'power_up.dart';

enum GameStatus { playing, gameOver }

class GameState {
  final List<Position> snake; // snake.first is head
  final Direction direction;
  final Position? food;
  final PowerUp? powerUp;
  final ActiveEffects effects;
  final int score;
  final int foodEaten;
  final int powerUpsCollected;
  final GameStatus status;

  const GameState({
    required this.snake,
    required this.direction,
    required this.food,
    required this.powerUp,
    required this.effects,
    required this.score,
    required this.foodEaten,
    required this.powerUpsCollected,
    required this.status,
  });

  Position get head => snake.first;

  GameState copyWith({
    List<Position>? snake,
    Direction? direction,
    Position? food,
    bool clearFood = false,
    PowerUp? powerUp,
    bool clearPowerUp = false,
    ActiveEffects? effects,
    int? score,
    int? foodEaten,
    int? powerUpsCollected,
    GameStatus? status,
  }) => GameState(
    snake: snake ?? this.snake,
    direction: direction ?? this.direction,
    food: clearFood ? null : (food ?? this.food),
    powerUp: clearPowerUp ? null : (powerUp ?? this.powerUp),
    effects: effects ?? this.effects,
    score: score ?? this.score,
    foodEaten: foodEaten ?? this.foodEaten,
    powerUpsCollected: powerUpsCollected ?? this.powerUpsCollected,
    status: status ?? this.status,
  );
}

/// Result of stepping the engine one tick, used by callers to react to
/// discrete events (haptics, sound, achievement checks) without re-deriving
/// them from a state diff.
class StepResult {
  final GameState state;
  final bool ateFood;
  final bool collectedPowerUp;
  final bool gameOverJustNow;
  final bool shieldConsumed;

  const StepResult({
    required this.state,
    required this.ateFood,
    required this.collectedPowerUp,
    required this.gameOverJustNow,
    required this.shieldConsumed,
  });
}

/// Pure Dart game engine: no Flutter dependency, fully unit-testable.
/// Collision policy: hitting a wall or obstacle ends the game (unless a
/// shield is active) rather than wrapping around — this keeps difficulty
/// consistent regardless of map size and matches player expectations from
/// classic Snake more closely than teleport-wrap would.
class GameEngine {
  final GameMapDef map;
  final Random random;

  GameEngine(this.map, {Random? random}) : random = random ?? Random();

  GameState initialState() {
    final center = Position(map.width ~/ 2, map.height ~/ 2);
    final snake = [
      center,
      Position(center.x - 1, center.y),
      Position(center.x - 2, center.y),
    ];
    final state = GameState(
      snake: snake,
      direction: Direction.right,
      food: null,
      powerUp: null,
      effects: const ActiveEffects(),
      score: 0,
      foodEaten: 0,
      powerUpsCollected: 0,
      status: GameStatus.playing,
    );
    return state.copyWith(food: _placeRandom(state, avoidPowerUp: null));
  }

  Position _placeRandom(GameState state, {Position? avoidPowerUp}) {
    final occupied = <Position>{...state.snake, ...map.obstacles};
    if (state.food != null) occupied.add(state.food!);
    if (avoidPowerUp != null) occupied.add(avoidPowerUp);
    final free = <Position>[];
    for (var x = 0; x < map.width; x++) {
      for (var y = 0; y < map.height; y++) {
        final p = Position(x, y);
        if (!occupied.contains(p)) free.add(p);
      }
    }
    if (free.isEmpty) return state.snake.first;
    return free[random.nextInt(free.length)];
  }

  GameState changeDirection(GameState state, Direction newDirection) {
    if (newDirection.isOppositeOf(state.direction)) return state;
    return state.copyWith(direction: newDirection);
  }

  /// Maybe spawns a power-up if none is present. Callers control spawn
  /// probability/cadence; this just performs the placement.
  GameState maybeSpawnPowerUp(GameState state, {double chance = 1.0}) {
    if (state.powerUp != null) return state;
    if (random.nextDouble() > chance) return state;
    final types = PowerUpType.values;
    final type = types[random.nextInt(types.length)];
    final pos = _placeRandom(state);
    return state.copyWith(powerUp: PowerUp(type, pos));
  }

  StepResult step(GameState state) {
    if (state.status == GameStatus.gameOver) {
      return StepResult(
        state: state,
        ateFood: false,
        collectedPowerUp: false,
        gameOverJustNow: false,
        shieldConsumed: false,
      );
    }

    var effects = state.effects.tick();

    // Magnet: each tick, move food one cell closer (Chebyshev-adjacent step)
    // toward the head if within range, rather than teleporting it — keeps
    // the effect readable on screen while still meaningfully helping.
    var food = state.food;
    if (effects.isMagnetActive && food != null) {
      food = _stepTowards(food, state.head, radius: 8);
    }

    final newHead = state.head + state.direction.delta;

    final hitWall = map.isOutOfBounds(newHead);
    final hitObstacle = map.isObstacle(newHead);
    // Self-collision: colliding with own body, excluding the tail cell that
    // will vacate this tick (unless the snake is about to grow, in which
    // case the tail stays and a hit there is a real collision).
    final willGrow = food != null && newHead == food;
    final bodyToCheck = willGrow
        ? state.snake
        : state.snake.sublist(0, state.snake.length - 1);
    final hitSelf = bodyToCheck.contains(newHead);

    final collided = hitWall || hitObstacle || hitSelf;

    if (collided) {
      if (effects.hasShield) {
        // Shield absorbs the hit: snake stops advancing this tick, effect
        // consumed, game continues.
        return StepResult(
          state: state.copyWith(effects: effects.consumeShield()),
          ateFood: false,
          collectedPowerUp: false,
          gameOverJustNow: false,
          shieldConsumed: true,
        );
      }
      return StepResult(
        state: state.copyWith(status: GameStatus.gameOver, effects: effects),
        ateFood: false,
        collectedPowerUp: false,
        gameOverJustNow: true,
        shieldConsumed: false,
      );
    }

    final newSnake = [newHead, ...state.snake];
    var ateFood = false;
    var collectedPowerUp = false;
    var score = state.score;
    var foodEaten = state.foodEaten;
    var powerUpsCollected = state.powerUpsCollected;
    Position? newFood = food;
    var powerUp = state.powerUp;

    if (food != null && newHead == food) {
      ateFood = true;
      foodEaten++;
      final points = effects.isMultiplierActive ? 2 : 1;
      score += points;
      newFood = null; // placed below once snake/food state is consistent
    } else {
      newSnake.removeLast();
    }

    if (powerUp != null && newHead == powerUp.position) {
      collectedPowerUp = true;
      powerUpsCollected++;
      effects = effects.apply(powerUp.type);
      powerUp = null;
    }

    var nextState = state.copyWith(
      snake: newSnake,
      food: newFood,
      clearFood: newFood == null,
      powerUp: powerUp,
      clearPowerUp: powerUp == null,
      effects: effects,
      score: score,
      foodEaten: foodEaten,
      powerUpsCollected: powerUpsCollected,
    );

    if (ateFood) {
      nextState = nextState.copyWith(food: _placeRandom(nextState));
    }

    return StepResult(
      state: nextState,
      ateFood: ateFood,
      collectedPowerUp: collectedPowerUp,
      gameOverJustNow: false,
      shieldConsumed: false,
    );
  }

  Position _stepTowards(Position from, Position to, {required int radius}) {
    final dx = to.x - from.x;
    final dy = to.y - from.y;
    if (dx.abs() > radius || dy.abs() > radius) return from;
    if (dx == 0 && dy == 0) return from;
    final stepX = dx == 0 ? 0 : (dx > 0 ? 1 : -1);
    final stepY = dy == 0 ? 0 : (dy > 0 ? 1 : -1);
    return Position(from.x + stepX, from.y + stepY);
  }
}

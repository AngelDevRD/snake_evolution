import 'package:flutter_test/flutter_test.dart';
import 'package:snake_evolution/domain/game_engine.dart';
import 'package:snake_evolution/domain/game_map.dart';
import 'package:snake_evolution/domain/position.dart';
import 'package:snake_evolution/domain/power_up.dart';

void main() {
  group('GameEngine movement', () {
    test('snake moves forward one cell per tick without growing', () {
      final engine = GameEngine(GameMapDef.classicArena());
      var state = engine.initialState();
      // Force food far away so this tick doesn't eat.
      state = state.copyWith(food: const Position(0, 0));
      final headBefore = state.head;
      final result = engine.step(state);
      expect(result.state.head, headBefore + Direction.right.delta);
      expect(result.state.snake.length, state.snake.length);
    });

    test('snake grows when eating food', () {
      final engine = GameEngine(GameMapDef.classicArena());
      var state = engine.initialState();
      final nextHead = state.head + Direction.right.delta;
      state = state.copyWith(food: nextHead);
      final result = engine.step(state);
      expect(result.ateFood, isTrue);
      expect(result.state.snake.length, state.snake.length + 1);
      expect(result.state.score, 1);
    });
  });

  group('GameEngine collisions', () {
    test('wall collision ends the game', () {
      final map = GameMapDef.classicArena();
      final engine = GameEngine(map);
      var state = engine.initialState();
      // Place head at right edge moving right -> next step is out of bounds.
      state = state.copyWith(
        snake: [Position(map.width - 1, 5), Position(map.width - 2, 5)],
        direction: Direction.right,
        food: const Position(0, 0),
      );
      final result = engine.step(state);
      expect(result.gameOverJustNow, isTrue);
      expect(result.state.status, GameStatus.gameOver);
    });

    test('obstacle collision ends the game', () {
      final map = GameMapDef.obstacleField();
      final engine = GameEngine(map);
      final obstacle = map.obstacles.first;
      var state = engine.initialState();
      state = state.copyWith(
        snake: [
          Position(obstacle.x - 1, obstacle.y),
          Position(obstacle.x - 2, obstacle.y),
        ],
        direction: Direction.right,
        food: const Position(0, 0),
      );
      final result = engine.step(state);
      expect(result.gameOverJustNow, isTrue);
    });

    test('self collision ends the game', () {
      final engine = GameEngine(GameMapDef.classicArena());
      var state = engine.initialState();
      // Build a snake that will bite itself on the next left turn: a hook
      // shape where the head moving up hits an existing body segment.
      const head = Position(10, 10);
      state = state.copyWith(
        snake: [
          head,
          Position(10, 9),
          Position(9, 9),
          Position(9, 10),
          Position(9, 11),
        ],
        direction: Direction.right,
        food: const Position(0, 0),
      );
      state = engine.changeDirection(state, Direction.down);
      // Moving down from (10,10) -> (10,11), not a hit; instead directly
      // test collision by aiming at an occupied cell explicitly.
      final result = engine.step(
        GameState(
          snake: const [
            Position(10, 10),
            Position(10, 9),
            Position(9, 9),
            Position(9, 10),
            Position(9, 11),
          ],
          direction: Direction.left,
          food: const Position(0, 0),
          powerUp: null,
          effects: const ActiveEffects(),
          score: 0,
          foodEaten: 0,
          powerUpsCollected: 0,
          status: GameStatus.playing,
        ),
      );
      expect(result.gameOverJustNow, isTrue);
      // On collision the engine freezes state at the moment of impact rather
      // than advancing into the colliding cell, so the head stays put.
      expect(result.state.head, const Position(10, 10));
    });
  });

  group('Power-up effects', () {
    test('shield absorbs one collision instead of ending the game', () {
      final map = GameMapDef.classicArena();
      final engine = GameEngine(map);
      var state = engine.initialState();
      state = state.copyWith(
        snake: [Position(map.width - 1, 5), Position(map.width - 2, 5)],
        direction: Direction.right,
        food: const Position(0, 0),
        effects: const ActiveEffects(hasShield: true),
      );
      final result = engine.step(state);
      expect(result.gameOverJustNow, isFalse);
      expect(result.shieldConsumed, isTrue);
      expect(result.state.effects.hasShield, isFalse);
      expect(result.state.status, GameStatus.playing);
    });

    test('multiplier doubles score gained from eating food', () {
      final engine = GameEngine(GameMapDef.classicArena());
      var state = engine.initialState();
      final nextHead = state.head + Direction.right.delta;
      state = state.copyWith(
        food: nextHead,
        effects: const ActiveEffects(multiplierTicks: 10),
      );
      final result = engine.step(state);
      expect(result.state.score, 2);
    });

    test('magnet moves food one cell closer to the head each tick', () {
      final engine = GameEngine(GameMapDef.classicArena());
      var state = engine.initialState();
      final head = state.head;
      final farFood = Position(head.x + 5, head.y);
      state = state.copyWith(
        food: farFood,
        effects: const ActiveEffects(magnetTicks: 5),
      );
      final result = engine.step(state);
      // Food should have moved one cell closer on the x axis.
      expect(result.state.food!.x, farFood.x - 1);
    });

    test('power-up types carry the expected duration semantics', () {
      expect(PowerUpType.shield.durationTicks, 0);
      expect(PowerUpType.speed.durationTicks, greaterThan(0));
      expect(PowerUpType.magnet.durationTicks, greaterThan(0));
      expect(PowerUpType.multiplier.durationTicks, greaterThan(0));
    });
  });
}

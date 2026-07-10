import 'dart:collection';

import 'position.dart';

class Snake {
  final Queue<Position> body;
  final Direction direction;

  Snake({required this.body, required this.direction});

  factory Snake.initial(
    Position start, {
    Direction direction = Direction.right,
  }) {
    return Snake(body: Queue.of([start]), direction: direction);
  }

  Position get head => body.first;

  int get length => body.length;

  bool occupies(Position p) => body.contains(p);

  /// Body cells excluding the head, used for self-collision checks against
  /// the *new* head position (the tail cell is handled by the caller since
  /// it moves away unless the snake just grew).
  Iterable<Position> get bodyWithoutHead => body.skip(1);

  Snake move(Direction newDirection, {required bool grow}) {
    final dir = newDirection.isOppositeOf(direction) ? direction : newDirection;
    final newHead = head + dir.delta;
    final newBody = Queue.of(body)..addFirst(newHead);
    if (!grow) {
      newBody.removeLast();
    }
    return Snake(body: newBody, direction: dir);
  }
}

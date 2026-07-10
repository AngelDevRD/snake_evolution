class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  Position operator +(Position other) => Position(x + other.x, y + other.y);

  @override
  bool operator ==(Object other) =>
      other is Position && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Position($x, $y)';
}

enum Direction { up, down, left, right }

extension DirectionDelta on Direction {
  Position get delta {
    switch (this) {
      case Direction.up:
        return const Position(0, -1);
      case Direction.down:
        return const Position(0, 1);
      case Direction.left:
        return const Position(-1, 0);
      case Direction.right:
        return const Position(1, 0);
    }
  }

  bool get isOpposite => false;

  bool isOppositeOf(Direction other) {
    switch (this) {
      case Direction.up:
        return other == Direction.down;
      case Direction.down:
        return other == Direction.up;
      case Direction.left:
        return other == Direction.right;
      case Direction.right:
        return other == Direction.left;
    }
  }
}

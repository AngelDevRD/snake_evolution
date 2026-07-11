import 'position.dart';

enum MapId { classicArena, obstacleField }

class GameMapDef {
  final MapId id;
  final String name;
  final int width;
  final int height;
  final List<Position> obstacles;

  const GameMapDef({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.obstacles,
  });

  static const int defaultSize = 20;

  static GameMapDef classicArena({int size = defaultSize}) => GameMapDef(
    id: MapId.classicArena,
    name: 'Arena Clásica',
    width: size,
    height: size,
    obstacles: const [],
  );

  // Symmetric obstacle pattern: a cross of four block clusters near the
  // quarter-points of the board, kept away from the center spawn point so
  // the snake never starts blocked in. The margin scales with board size
  // (quarter-point based) so the safe gap around the center spawn row/col
  // is preserved on every board-size option, not just the default 20x20.
  static GameMapDef obstacleField({int size = defaultSize}) {
    final w = size;
    final h = size;
    final q = (size / 4).floor().clamp(2, size);
    final blocks = [
      Position(q, q),
      Position(q + 1, q),
      Position(q, q + 1),
      Position(w - 1 - q, q),
      Position(w - 2 - q, q),
      Position(w - 1 - q, q + 1),
      Position(q, h - 1 - q),
      Position(q + 1, h - 1 - q),
      Position(q, h - 2 - q),
      Position(w - 1 - q, h - 1 - q),
      Position(w - 2 - q, h - 1 - q),
      Position(w - 1 - q, h - 2 - q),
    ];
    return GameMapDef(
      id: MapId.obstacleField,
      name: 'Campo de Obstáculos',
      width: w,
      height: h,
      obstacles: blocks,
    );
  }

  static GameMapDef byId(MapId id, {int size = defaultSize}) {
    switch (id) {
      case MapId.classicArena:
        return classicArena(size: size);
      case MapId.obstacleField:
        return obstacleField(size: size);
    }
  }

  bool isObstacle(Position p) => obstacles.contains(p);

  bool isOutOfBounds(Position p) =>
      p.x < 0 || p.y < 0 || p.x >= width || p.y >= height;
}

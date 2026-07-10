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

  static GameMapDef classicArena() => const GameMapDef(
    id: MapId.classicArena,
    name: 'Arena Clásica',
    width: defaultSize,
    height: defaultSize,
    obstacles: [],
  );

  // Fixed symmetric obstacle pattern: a cross of four block clusters,
  // kept away from the center spawn point so the snake never starts blocked in.
  static GameMapDef obstacleField() {
    final obstacles = <Position>[];
    const w = defaultSize;
    const h = defaultSize;
    final blocks = [
      const Position(5, 5),
      const Position(6, 5),
      const Position(5, 6),
      Position(w - 6, 5),
      Position(w - 7, 5),
      Position(w - 6, 6),
      Position(5, h - 6),
      Position(6, h - 6),
      Position(5, h - 7),
      Position(w - 6, h - 6),
      Position(w - 7, h - 6),
      Position(w - 6, h - 7),
    ];
    obstacles.addAll(blocks);
    return GameMapDef(
      id: MapId.obstacleField,
      name: 'Campo de Obstáculos',
      width: w,
      height: h,
      obstacles: obstacles,
    );
  }

  static GameMapDef byId(MapId id) {
    switch (id) {
      case MapId.classicArena:
        return classicArena();
      case MapId.obstacleField:
        return obstacleField();
    }
  }

  bool isObstacle(Position p) => obstacles.contains(p);

  bool isOutOfBounds(Position p) =>
      p.x < 0 || p.y < 0 || p.x >= width || p.y >= height;
}

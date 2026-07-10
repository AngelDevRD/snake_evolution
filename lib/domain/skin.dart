enum SkinPattern { solid, gradient, rainbow }

class SkinDef {
  final String id;
  final String name;
  final int price;
  final List<int> colors; // ARGB ints, interpreted by presentation layer
  final SkinPattern pattern;

  const SkinDef({
    required this.id,
    required this.name,
    required this.price,
    required this.colors,
    required this.pattern,
  });
}

const List<SkinDef> allSkins = [
  SkinDef(
    id: 'classic_green',
    name: 'Verde Clásico',
    price: 0,
    colors: [0xFF4CAF50],
    pattern: SkinPattern.solid,
  ),
  SkinDef(
    id: 'neon_blue',
    name: 'Azul Neón',
    price: 50,
    colors: [0xFF00E5FF],
    pattern: SkinPattern.solid,
  ),
  SkinDef(
    id: 'fire',
    name: 'Fuego',
    price: 100,
    colors: [0xFFFF5722, 0xFFFFC107],
    pattern: SkinPattern.gradient,
  ),
  SkinDef(
    id: 'rainbow',
    name: 'Arcoíris',
    price: 150,
    colors: [
      0xFFF44336,
      0xFFFF9800,
      0xFFFFEB3B,
      0xFF4CAF50,
      0xFF2196F3,
      0xFF9C27B0,
    ],
    pattern: SkinPattern.rainbow,
  ),
];

SkinDef skinById(String id) =>
    allSkins.firstWhere((s) => s.id == id, orElse: () => allSkins.first);

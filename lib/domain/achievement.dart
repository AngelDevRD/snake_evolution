enum AchievementMetric {
  maxLength,
  gamesPlayed,
  powerUpsCollected,
  surviveSeconds,
}

class AchievementDef {
  final String id;
  final String name;
  final String description;
  final AchievementMetric metric;
  final int target;

  const AchievementDef({
    required this.id,
    required this.name,
    required this.description,
    required this.metric,
    required this.target,
  });
}

const List<AchievementDef> allAchievements = [
  AchievementDef(
    id: 'length_20',
    name: 'Serpiente Larga',
    description: 'Alcanza una longitud de 20',
    metric: AchievementMetric.maxLength,
    target: 20,
  ),
  AchievementDef(
    id: 'games_20',
    name: 'Jugador Constante',
    description: 'Juega 20 partidas',
    metric: AchievementMetric.gamesPlayed,
    target: 20,
  ),
  AchievementDef(
    id: 'powerups_50',
    name: 'Coleccionista',
    description: 'Recolecta 50 power-ups',
    metric: AchievementMetric.powerUpsCollected,
    target: 50,
  ),
  AchievementDef(
    id: 'survive_120',
    name: 'Superviviente',
    description: 'Sobrevive 2 minutos en una partida',
    metric: AchievementMetric.surviveSeconds,
    target: 120,
  ),
];

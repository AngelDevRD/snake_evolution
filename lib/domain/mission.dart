enum MissionType { eatFood, surviveSeconds, reachLength }

class MissionDef {
  final MissionType type;
  final String description;
  final int target;
  final int coinReward;

  const MissionDef({
    required this.type,
    required this.description,
    required this.target,
    required this.coinReward,
  });
}

/// Fixed pool of possible daily missions; a small deterministic subset is
/// chosen each day rather than a full quest engine.
const List<MissionDef> missionPool = [
  MissionDef(
    type: MissionType.eatFood,
    description: 'Come 10 alimentos en una partida',
    target: 10,
    coinReward: 15,
  ),
  MissionDef(
    type: MissionType.surviveSeconds,
    description: 'Sobrevive 60 segundos',
    target: 60,
    coinReward: 15,
  ),
  MissionDef(
    type: MissionType.reachLength,
    description: 'Alcanza una longitud de 15',
    target: 15,
    coinReward: 20,
  ),
];

/// Selects today's missions deterministically from the pool based on the
/// date, so the same day always yields the same missions without needing
/// to persist the selection itself (only progress + last-reset date).
List<MissionDef> selectDailyMissions(DateTime date, {int count = 2}) {
  final seed = date.year * 10000 + date.month * 100 + date.day;
  final indices = List<int>.generate(missionPool.length, (i) => i);
  indices.sort(
    (a, b) => ((a + seed) % missionPool.length).compareTo(
      (b + seed) % missionPool.length,
    ),
  );
  return indices.take(count).map((i) => missionPool[i]).toList();
}

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Pure function: true if the stored last-reset date differs from today,
/// meaning missions/progress should reset. Comparing formatted date keys
/// (not DateTime instants) avoids issues with time-of-day components.
bool shouldResetMissions(String? lastResetDateKey, DateTime today) {
  if (lastResetDateKey == null) return true;
  return lastResetDateKey != dateKey(today);
}

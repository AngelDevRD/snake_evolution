import 'package:shared_preferences/shared_preferences.dart';

import '../domain/mission.dart';

class MissionProgress {
  final MissionDef def;
  final int progress;
  final bool claimed;

  const MissionProgress({
    required this.def,
    required this.progress,
    required this.claimed,
  });

  bool get isComplete => progress >= def.target;
}

/// Wraps the pure `shouldResetMissions`/`selectDailyMissions` domain logic
/// with shared_preferences storage of per-mission progress and claim state.
class MissionsRepository {
  static const _kLastReset = 'missions_last_reset';
  static const _kProgressPrefix = 'missions_progress_';
  static const _kClaimedPrefix = 'missions_claimed_';

  final SharedPreferences prefs;

  MissionsRepository(this.prefs);

  Future<List<MissionProgress>> getTodaysMissions({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final lastReset = prefs.getString(_kLastReset);
    if (shouldResetMissions(lastReset, today)) {
      await _reset(today);
    }
    final missions = selectDailyMissions(today);
    return missions
        .map(
          (def) => MissionProgress(
            def: def,
            progress: prefs.getInt('$_kProgressPrefix${def.type.name}') ?? 0,
            claimed: prefs.getBool('$_kClaimedPrefix${def.type.name}') ?? false,
          ),
        )
        .toList();
  }

  Future<void> _reset(DateTime today) async {
    for (final def in missionPool) {
      await prefs.remove('$_kProgressPrefix${def.type.name}');
      await prefs.remove('$_kClaimedPrefix${def.type.name}');
    }
    await prefs.setString(_kLastReset, dateKey(today));
  }

  Future<void> updateProgress(MissionType type, int value) async {
    final key = '$_kProgressPrefix${type.name}';
    final current = prefs.getInt(key) ?? 0;
    if (value > current) {
      await prefs.setInt(key, value);
    }
  }

  Future<void> incrementProgress(MissionType type, int delta) async {
    final key = '$_kProgressPrefix${type.name}';
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + delta);
  }

  Future<void> claim(MissionType type) async {
    await prefs.setBool('$_kClaimedPrefix${type.name}', true);
  }
}

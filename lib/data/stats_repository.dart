import 'package:shared_preferences/shared_preferences.dart';

class StatsRepository {
  static const _kGamesPlayed = 'stats_games_played';
  static const _kBestLength = 'stats_best_length';
  static const _kTotalFood = 'stats_total_food';
  static const _kTotalPlayTimeSec = 'stats_total_play_time_sec';
  static const _kTotalPowerUps = 'stats_total_powerups';

  final SharedPreferences prefs;

  StatsRepository(this.prefs);

  int get gamesPlayed => prefs.getInt(_kGamesPlayed) ?? 0;
  int get bestLength => prefs.getInt(_kBestLength) ?? 0;
  int get totalFoodEaten => prefs.getInt(_kTotalFood) ?? 0;
  int get totalPlayTimeSeconds => prefs.getInt(_kTotalPlayTimeSec) ?? 0;
  int get totalPowerUpsCollected => prefs.getInt(_kTotalPowerUps) ?? 0;

  Future<void> recordGame({
    required int length,
    required int foodEaten,
    required int playTimeSeconds,
    required int powerUpsCollected,
  }) async {
    await prefs.setInt(_kGamesPlayed, gamesPlayed + 1);
    if (length > bestLength) {
      await prefs.setInt(_kBestLength, length);
    }
    await prefs.setInt(_kTotalFood, totalFoodEaten + foodEaten);
    await prefs.setInt(
      _kTotalPlayTimeSec,
      totalPlayTimeSeconds + playTimeSeconds,
    );
    await prefs.setInt(
      _kTotalPowerUps,
      totalPowerUpsCollected + powerUpsCollected,
    );
  }
}

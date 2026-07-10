import 'package:flutter_riverpod/legacy.dart';

import '../data/stats_repository.dart';
import 'repository_providers.dart';

class StatsState {
  final int gamesPlayed;
  final int bestLength;
  final int totalFoodEaten;
  final int totalPlayTimeSeconds;
  final int totalPowerUpsCollected;

  const StatsState({
    required this.gamesPlayed,
    required this.bestLength,
    required this.totalFoodEaten,
    required this.totalPlayTimeSeconds,
    required this.totalPowerUpsCollected,
  });
}

class StatsNotifier extends StateNotifier<StatsState> {
  final StatsRepository _repo;

  StatsNotifier(this._repo) : super(_readState(_repo));

  static StatsState _readState(StatsRepository repo) => StatsState(
    gamesPlayed: repo.gamesPlayed,
    bestLength: repo.bestLength,
    totalFoodEaten: repo.totalFoodEaten,
    totalPlayTimeSeconds: repo.totalPlayTimeSeconds,
    totalPowerUpsCollected: repo.totalPowerUpsCollected,
  );

  Future<void> recordGame({
    required int length,
    required int foodEaten,
    required int playTimeSeconds,
    required int powerUpsCollected,
  }) async {
    await _repo.recordGame(
      length: length,
      foodEaten: foodEaten,
      playTimeSeconds: playTimeSeconds,
      powerUpsCollected: powerUpsCollected,
    );
    state = _readState(_repo);
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(ref.watch(statsRepositoryProvider));
});

import 'package:flutter_riverpod/legacy.dart';

import '../data/progress_repository.dart';
import '../domain/skin.dart';
import 'repository_providers.dart';

class ProgressState {
  final int coins;
  final List<String> unlockedSkinIds;
  final String selectedSkinId;
  final List<String> unlockedAchievementIds;
  final int bestScore;

  const ProgressState({
    required this.coins,
    required this.unlockedSkinIds,
    required this.selectedSkinId,
    required this.unlockedAchievementIds,
    required this.bestScore,
  });
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  final ProgressRepository _repo;

  ProgressNotifier(this._repo) : super(_readState(_repo));

  static ProgressState _readState(ProgressRepository repo) => ProgressState(
    coins: repo.coins,
    unlockedSkinIds: repo.unlockedSkins,
    selectedSkinId: repo.selectedSkin,
    unlockedAchievementIds: repo.unlockedAchievements,
    bestScore: repo.bestScore,
  );

  void _refresh() => state = _readState(_repo);

  Future<void> addCoins(int amount) async {
    await _repo.addCoins(amount);
    _refresh();
  }

  /// Spends coins to unlock [id] and selects it. Returns false (no state
  /// change) if the balance is insufficient.
  Future<bool> purchaseSkin(String id) async {
    if (state.unlockedSkinIds.contains(id)) {
      await selectSkin(id);
      return true;
    }
    final skin = skinById(id);
    final ok = await _repo.spendCoins(skin.price);
    if (!ok) return false;
    await _repo.unlockSkin(id);
    await _repo.selectSkin(id);
    _refresh();
    return true;
  }

  Future<void> selectSkin(String id) async {
    await _repo.selectSkin(id);
    _refresh();
  }

  Future<void> unlockAchievement(String id) async {
    if (state.unlockedAchievementIds.contains(id)) return;
    await _repo.unlockAchievement(id);
    _refresh();
  }

  Future<void> updateBestScore(int score) async {
    await _repo.updateBestScore(score);
    _refresh();
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>(
  (ref) {
    return ProgressNotifier(ref.watch(progressRepositoryProvider));
  },
);

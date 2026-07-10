import 'package:shared_preferences/shared_preferences.dart';

/// Coins, skin unlocks/selection, achievement unlock state, and best score.
/// Every mutation writes through to shared_preferences immediately, which is
/// the app's "auto-save": there is no separate batched save step.
class ProgressRepository {
  static const _kCoins = 'progress_coins';
  static const _kUnlockedSkins = 'progress_unlocked_skins';
  static const _kSelectedSkin = 'progress_selected_skin';
  static const _kAchievements = 'progress_achievements';
  static const _kBestScore = 'progress_best_score';

  final SharedPreferences prefs;

  ProgressRepository(this.prefs);

  int get coins => prefs.getInt(_kCoins) ?? 0;

  Future<void> addCoins(int amount) async {
    await prefs.setInt(_kCoins, coins + amount);
  }

  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;
    await prefs.setInt(_kCoins, coins - amount);
    return true;
  }

  List<String> get unlockedSkins =>
      prefs.getStringList(_kUnlockedSkins) ?? ['classic_green'];

  Future<void> unlockSkin(String id) async {
    final current = unlockedSkins;
    if (!current.contains(id)) {
      await prefs.setStringList(_kUnlockedSkins, [...current, id]);
    }
  }

  String get selectedSkin => prefs.getString(_kSelectedSkin) ?? 'classic_green';

  Future<void> selectSkin(String id) => prefs.setString(_kSelectedSkin, id);

  List<String> get unlockedAchievements =>
      prefs.getStringList(_kAchievements) ?? [];

  Future<void> unlockAchievement(String id) async {
    final current = unlockedAchievements;
    if (!current.contains(id)) {
      await prefs.setStringList(_kAchievements, [...current, id]);
    }
  }

  int get bestScore => prefs.getInt(_kBestScore) ?? 0;

  Future<void> updateBestScore(int score) async {
    if (score > bestScore) {
      await prefs.setInt(_kBestScore, score);
    }
  }
}

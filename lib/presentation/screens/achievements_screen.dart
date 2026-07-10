import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/achievement.dart';
import '../../providers/progress_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Logros')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allAchievements.length,
        itemBuilder: (context, index) {
          final def = allAchievements[index];
          final unlocked = progress.unlockedAchievementIds.contains(def.id);
          return Card(
            child: ListTile(
              leading: Icon(
                unlocked ? Icons.emoji_events : Icons.lock_outline,
                color: unlocked ? Colors.amber : null,
              ),
              title: Text(def.name),
              subtitle: Text(def.description),
              trailing: unlocked
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

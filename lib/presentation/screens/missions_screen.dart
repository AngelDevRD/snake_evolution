import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/missions_providers.dart';

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(missionsProvider).missions;

    return Scaffold(
      appBar: AppBar(title: const Text('Misiones diarias')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final entry = missions[index];
          final progressRatio = entry.def.target == 0
              ? 0.0
              : (entry.progress.progress / entry.def.target).clamp(0.0, 1.0);
          return Card(
            child: ListTile(
              title: Text(entry.def.description),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: progressRatio),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.progress.progress}/${entry.def.target} · ${entry.def.coinReward} monedas',
                    ),
                  ],
                ),
              ),
              trailing: entry.progress.claimed
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : entry.isComplete
                  ? FilledButton(
                      onPressed: () => ref
                          .read(missionsProvider.notifier)
                          .claimReward(index),
                      child: const Text('Reclamar'),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

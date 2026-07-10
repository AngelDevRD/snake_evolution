import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/progress_providers.dart';
import '../../providers/settings_providers.dart';
import '../widgets/tutorial_overlay.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.grain, size: 72),
                      const SizedBox(height: 8),
                      Text(
                        'Snake Evolution',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on, size: 18),
                          const SizedBox(width: 4),
                          Text('${progress.coins}'),
                          const SizedBox(width: 16),
                          const Icon(Icons.emoji_events, size: 18),
                          const SizedBox(width: 4),
                          Text('Mejor: ${progress.bestScore}'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () => context.push('/map-select'),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Jugar'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/missions'),
                        icon: const Icon(Icons.checklist),
                        label: const Text('Misiones diarias'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/shop'),
                        icon: const Icon(Icons.storefront),
                        label: const Text('Tienda'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/achievements'),
                        icon: const Icon(Icons.emoji_events_outlined),
                        label: const Text('Logros'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/stats'),
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Estadísticas'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings),
                        label: const Text('Ajustes'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!settings.tutorialSeen) const TutorialOverlay(),
        ],
      ),
    );
  }
}

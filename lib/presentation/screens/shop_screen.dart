import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/skin.dart';
import '../../providers/progress_providers.dart';
import '../widgets/snake_skin_preview.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, size: 18),
                  const SizedBox(width: 4),
                  Text('${progress.coins}'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allSkins.length,
        itemBuilder: (context, index) {
          final skin = allSkins[index];
          final unlocked = progress.unlockedSkinIds.contains(skin.id);
          final selected = progress.selectedSkinId == skin.id;

          return Card(
            child: ListTile(
              leading: SizedBox(
                width: 48,
                height: 48,
                child: SnakeSkinPreview(skin: skin),
              ),
              title: Text(skin.name),
              subtitle: Text(
                unlocked
                    ? (selected ? 'Seleccionada' : 'Desbloqueada')
                    : '${skin.price} monedas',
              ),
              trailing: unlocked
                  ? (selected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : OutlinedButton(
                            onPressed: () => ref
                                .read(progressProvider.notifier)
                                .selectSkin(skin.id),
                            child: const Text('Usar'),
                          ))
                  : FilledButton(
                      onPressed: () async {
                        final ok = await ref
                            .read(progressProvider.notifier)
                            .purchaseSkin(skin.id);
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Monedas insuficientes'),
                            ),
                          );
                        }
                      },
                      child: const Text('Comprar'),
                    ),
            ),
          );
        },
      ),
    );
  }
}

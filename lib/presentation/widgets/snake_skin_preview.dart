import 'package:flutter/material.dart';

import '../../domain/skin.dart';

/// Renders the segment colors of a [SkinDef] as small swatches so the shop
/// and settings screens can preview a skin without needing the game grid.
class SnakeSkinPreview extends StatelessWidget {
  final SkinDef skin;

  const SnakeSkinPreview({super.key, required this.skin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(skin.colors.length.clamp(1, 4), (i) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: Color(skin.colors[i % skin.colors.length]),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

/// Returns the color for the Nth body segment of a skin (head = index 0).
Color segmentColor(SkinDef skin, int index) {
  switch (skin.pattern) {
    case SkinPattern.solid:
      return Color(skin.colors.first);
    case SkinPattern.gradient:
      final t = skin.colors.length > 1 ? (index % 10) / 10 : 0.0;
      return Color.lerp(Color(skin.colors.first), Color(skin.colors.last), t)!;
    case SkinPattern.rainbow:
      return Color(skin.colors[index % skin.colors.length]);
  }
}

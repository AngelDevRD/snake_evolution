import 'package:flutter/material.dart';

import '../../domain/position.dart';

/// On-screen directional pad; steers the snake alongside swipe gestures.
class DpadControls extends StatelessWidget {
  final ValueChanged<Direction> onDirection;
  final double buttonSize;

  const DpadControls({
    super.key,
    required this.onDirection,
    this.buttonSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(Icons.keyboard_arrow_up, Direction.up),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _button(Icons.keyboard_arrow_left, Direction.left),
            SizedBox(width: buttonSize),
            _button(Icons.keyboard_arrow_right, Direction.right),
          ],
        ),
        _button(Icons.keyboard_arrow_down, Direction.down),
      ],
    );
  }

  Widget _button(IconData icon, Direction direction) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: IconButton.filledTonal(
        onPressed: () => onDirection(direction),
        icon: Icon(icon),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:rogue_descent/core/constants/constants.dart';

class RoomComponent extends PositionComponent {
  late final Vector2 gridSize;

  RoomComponent({required this.gridSize}) : super(size: gridSize);

  @override
  void render(Canvas canvas) {
    RRect roomRect = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(gridSize.x * 0.1),
    );

    // Draw room
    canvas.drawRRect(roomRect, Paint()..color = roomColor);
  }
}

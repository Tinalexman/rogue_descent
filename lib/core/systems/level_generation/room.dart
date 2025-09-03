import 'package:flame/extensions.dart';

class Room {
  final int id;
  final Vector2 position;
  final Vector2 size;
  final RoomType type;

  const Room({
    this.id = -1,
    this.type = RoomType.oneByOne,
    required this.position,
    required this.size,
  });
}

enum RoomType { oneByOne, twoByTwo, threeByThree }

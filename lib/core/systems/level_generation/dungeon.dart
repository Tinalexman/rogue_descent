import 'package:flame/game.dart';
import 'package:rogue_descent/core/systems/level_generation/connection.dart';
import 'package:rogue_descent/core/systems/level_generation/room.dart';

class Dungeon {
  final List<List<Room>> rooms;
  final List<Connection> connections;
  final Vector2 size, roomSize;

  Dungeon({
    this.rooms = const [],
    this.connections = const [],
    required this.size,
    required this.roomSize,
  });
}

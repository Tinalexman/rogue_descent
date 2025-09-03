import 'dart:async';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:rogue_descent/core/systems/level_generation/dungeon.dart';
import 'package:rogue_descent/core/systems/level_generation/room.dart';
import 'package:rogue_descent/game/components/room_component.dart';
import 'package:rogue_descent/game/rogue_descent_game.dart';

/// Main dungeon world that contains all levels and handles visualization
class DungeonWorld extends World {
  final Vector2 gridSize, worldSize;
  final Dungeon dungeon;

  DungeonWorld({
    required this.dungeon,
    required this.gridSize,
    required this.worldSize,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    List<RoomComponent> roomComponents = [];

    double xOffset = (worldSize.x - dungeon.size.x) * 0.5;
    double yOffset = (worldSize.y - dungeon.size.y) * 0.5;

    for (int i = 0; i < dungeon.rooms.length; i++) {
      print("Rooms on level $i: ${dungeon.rooms[i].length}");
      for (int j = 0; j < dungeon.rooms[i].length; j++) {
        Room room = dungeon.rooms[i][j];

        RoomComponent roomComponent = RoomComponent(gridSize: gridSize)
          ..position = Vector2(
            room.position.x + xOffset,
            room.position.y + yOffset,
          )
          ..size = room.size;
        roomComponents.add(roomComponent);
      }
    }
    addAll(roomComponents);
  }
}

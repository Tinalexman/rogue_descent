import 'dart:developer';
import 'dart:math' hide log;

import 'package:flame/extensions.dart';
import 'package:rogue_descent/core/systems/level_generation/connection.dart';
import 'package:rogue_descent/core/systems/level_generation/dungeon.dart';
import 'package:rogue_descent/core/systems/level_generation/room.dart';

class DungeonGenerator {
  static Dungeon generateDungeon(DungeonGeneratorParams params) {
    log("Generating dungeon with params: $params");
    // Generate room distribution across levels
    List<int> roomsPerLevel = _generateRoomDistribution(
      params.seed,
      params.totalRooms,
      params.levels,
    );

    List<List<Room>> rooms = [];
    List<Connection> connections = [];
    int addedRooms = 0;

    Random random = Random(params.seed);

    double maxWidth = 0.0, maxHeight = 0.0;
    double currentLevelY = 0.0; // Track current Y position for level stacking

    for (int row = 0; row < params.levels; ++row) {
      List<Room> levelRooms = [];
      double currentX = 0.0; // Track current X position within the level
      double levelHeight = 0.0;

      for (int column = 0; column < roomsPerLevel[row]; ++column) {
        RoomType roomType = _getRoomType(random);

        double widthMultiplier =
            roomType == RoomType.twoByOne || roomType == RoomType.twoByTwo
            ? 2.0
            : 1.0;
        double heightMultiplier =
            roomType == RoomType.oneByTwo || roomType == RoomType.twoByTwo
            ? 2.0
            : 1.0;

        double width = params.roomWidth * widthMultiplier;
        double height = params.roomHeight * heightMultiplier;

        // Position room at current X and current level Y
        Room room = Room(
          id: addedRooms++,
          type: roomType,
          position: Vector2(currentX, currentLevelY),
          size: Vector2(width, height),
        );
        levelRooms.add(room);

        // Update level dimensions
        levelHeight = max(levelHeight, height);

        // Move to next room position (add spacing)
        currentX += width + params.roomSpacing;
      }

      // Update dungeon dimensions
      maxWidth = max(
        maxWidth,
        currentX - params.roomSpacing,
      ); // Remove last spacing
      maxHeight = currentLevelY + levelHeight;

      // Move to next level position
      currentLevelY = maxHeight + params.roomSpacing;

      rooms.add(levelRooms);
    }

    Vector2 dungeonSize = Vector2(maxWidth, maxHeight);

    return Dungeon(
      rooms: rooms,
      connections: connections,
      size: dungeonSize,
      roomSize: Vector2(params.roomWidth, params.roomHeight),
    );
  }

  /// Generates a list of room counts for levels that adds up to totalRooms.
  /// Each level gets at least 1 room, and the distribution is somewhat random
  static List<int> _generateRoomDistribution(
    int seed,
    int totalRooms,
    int levels,
  ) {
    if (levels <= 0 || totalRooms < levels) {
      throw ArgumentError(
        'Invalid parameters: levels must be > 0 and totalRooms >= levels',
      );
    }

    if (levels == 1) {
      return [totalRooms];
    }

    List<int> distribution = List.filled(
      levels,
      1,
    ); // Start with 1 room per level
    int remainingRooms = totalRooms - levels; // Distribute remaining rooms

    // Randomly distribute remaining rooms across levels
    Random random = Random(seed);
    for (int i = 0; i < remainingRooms; i++) {
      int randomLevel = random.nextInt(levels);
      distribution[randomLevel]++;
    }

    return distribution;
  }

  static RoomType _getRoomType(Random random) {
    double roll = random.nextDouble(); // 0.0 to 1.0

    if (roll < 0.5) {
      // 50% chance for 1x1 room
      return RoomType.oneByOne;
    } else if (roll < 0.8) {
      // 30% chance for 2x2 room (0.5 to 0.8)
      return RoomType.twoByTwo;
    } else {
      // 20% chance for either 1x2 or 2x1 (0.8 to 1.0)
      return random.nextBool() ? RoomType.oneByTwo : RoomType.twoByOne;
    }
  }
}

class DungeonGeneratorParams {
  final int seed;
  final int totalRooms;
  final int levels;
  final double roomWidth, roomHeight;
  final double roomSpacing;

  const DungeonGeneratorParams({
    required this.seed,
    this.totalRooms = 10,
    this.levels = 3,
    this.roomWidth = 50.0,
    this.roomHeight = 50.0,
    this.roomSpacing = 10.0,
  });

  @override
  String toString() {
    return 'DungeonGeneratorParams(seed: $seed, totalRooms: $totalRooms, levels: $levels, roomWidth: $roomWidth, roomHeight: $roomHeight, roomSpacing: $roomSpacing)';
  }
}

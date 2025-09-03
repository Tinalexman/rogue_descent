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

    // Generate room types with controlled distribution
    List<RoomType> roomTypes = _generateRoomTypesWithDistribution(
      params.totalRooms,
      random,
    );

    double maxWidth = 0.0, maxHeight = 0.0;
    double currentLevelY = 0.0; // Track current Y position for level stacking

    for (int row = 0; row < params.levels; ++row) {
      List<Room> levelRooms = [];
      double currentX = 0.0; // Track current X position within the level
      double levelHeight = 0.0;

      for (int column = 0; column < roomsPerLevel[row]; ++column) {
        RoomType roomType =
            roomTypes[addedRooms]; // Use pre-generated room types

        double widthMultiplier = roomType == RoomType.oneByOne
            ? 1.0
            : roomType == RoomType.twoByTwo
            ? 2.0
            : 3.0;
        double heightMultiplier = roomType == RoomType.oneByOne
            ? 1.0
            : roomType == RoomType.twoByTwo
            ? 2.0
            : 3.0;

        double width = params.roomWidth * widthMultiplier;
        double height = params.roomHeight * heightMultiplier;

        // Position room at current X and current level Y
        Room room = Room(
          id: addedRooms,
          type: roomType,
          position: Vector2(currentX, currentLevelY),
          size: Vector2(width, height),
        );
        levelRooms.add(room);

        // Update level dimensions
        levelHeight = max(levelHeight, height);

        // Move to next room position (add spacing)
        currentX += width + params.roomSpacing;
        addedRooms++;
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

  /// Generates room types with controlled distribution to ensure desired proportions
  static List<RoomType> _generateRoomTypesWithDistribution(
    int totalRooms,
    Random random,
  ) {
    // Calculate target counts for each room type
    int oneByOneCount = (totalRooms * 0.6).round(); // 60% = 15 out of 25
    int twoByTwoCount = (totalRooms * 0.32).round(); // 32% = 8 out of 25
    int threeByThreeCount =
        totalRooms - oneByOneCount - twoByTwoCount; // Remaining = 2 out of 25

    log(
      "Target room distribution: 1x1: $oneByOneCount, 2x2: $twoByTwoCount, 3x3: $threeByThreeCount",
    );

    // Create list with exact counts of each room type
    List<RoomType> roomTypes = [];
    roomTypes.addAll(List.filled(oneByOneCount, RoomType.oneByOne));
    roomTypes.addAll(List.filled(twoByTwoCount, RoomType.twoByTwo));
    roomTypes.addAll(List.filled(threeByThreeCount, RoomType.threeByThree));

    // Shuffle the list to randomize positions while maintaining counts
    roomTypes.shuffle(random);

    return roomTypes;
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
      // 20% chance for 3x3 room (0.8 to 1.0)
      return RoomType.threeByThree;
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

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
    int oneByOneCount = (totalRooms * 0.65).round(); // 65%
    int twoByTwoCount = (totalRooms * 0.3).round(); // 30%
    int threeByThreeCount = totalRooms - oneByOneCount - twoByTwoCount; // 5%

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
  /// Each level gets approximately the same number of rooms with minimal deviation
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

    Random random = Random(seed);

    // Calculate base rooms per level and remainder
    int baseRoomsPerLevel = totalRooms ~/ levels;
    int remainder = totalRooms % levels;

    // Start with base distribution
    List<int> distribution = List.filled(levels, baseRoomsPerLevel);

    // Distribute remainder rooms randomly, ensuring no level gets more than +1 from base
    for (int i = 0; i < remainder; i++) {
      int randomLevel = random.nextInt(levels);
      distribution[randomLevel]++;
    }

    // Ensure no level deviates more than ±1 from the average
    int average = totalRooms ~/ levels;
    for (int i = 0; i < levels; i++) {
      if (distribution[i] > average + 1) {
        // Find a level with fewer rooms to balance
        for (int j = 0; j < levels; j++) {
          if (distribution[j] < average) {
            distribution[i]--;
            distribution[j]++;
            break;
          }
        }
      }
    }

    log("Room distribution: $distribution (average: $average)");
    return distribution;
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

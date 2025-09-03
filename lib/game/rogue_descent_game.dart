import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:rogue_descent/core/systems/level_generation/dungeon.dart';
import 'package:rogue_descent/core/systems/level_generation/dungeon_generator.dart';
import 'package:rogue_descent/game/worlds/dungeon_world.dart';

/// Main game class for Rogue Descent
class RogueDescentGame extends FlameGame {
  late Dungeon dungeon;
  late DungeonWorld dungeonWorld;

  static double grid = 0.1;
  static late Vector2 gridSize, worldSize;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await Flame.device.setLandscape();
    await Future.delayed(const Duration(milliseconds: 1000));

    // Calculate grid size
    gridSize = Vector2(size.x * grid, size.y * grid);
    worldSize = Vector2(size.x, size.y);

    // Generate dungeon
    dungeon = DungeonGenerator.generateDungeon(
      DungeonGeneratorParams(
        seed: DateTime.now().millisecondsSinceEpoch,
        totalRooms: 10,
        levels: 3,
        roomWidth: 50.0,
        roomHeight: 50.0,
      ),
    );

    // Create dungeon world
    dungeonWorld = DungeonWorld(
      dungeon: dungeon,
      gridSize: gridSize,
      worldSize: worldSize,
    );

    // Create camera
    camera = CameraComponent(world: dungeonWorld)
      ..viewfinder.anchor = Anchor.topLeft;
  }

  @override
  void onMount() {
    super.onMount();

    dungeonWorld.onLoad();

    addAll([camera, dungeonWorld]);
  }

  /// Get current dungeon
  Dungeon get currentDungeon => dungeon;

  /// Get current dungeon world
  DungeonWorld get currentDungeonWorld => dungeonWorld;
}

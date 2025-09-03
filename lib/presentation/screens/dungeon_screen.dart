import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:rogue_descent/core/constants/constants.dart';
import 'package:rogue_descent/game/rogue_descent_game.dart';

/// Screen that displays the dungeon generation
class DungeonScreen extends StatefulWidget {
  const DungeonScreen({super.key});

  @override
  State<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends State<DungeonScreen> {
  late RogueDescentGame game;

  @override
  void initState() {
    super.initState();
    game = RogueDescentGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: GameWidget(
        game: game,
      ),
    );
  }


}

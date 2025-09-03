import 'package:flutter/material.dart';
import 'presentation/screens/dungeon_screen.dart';

void main() {
  runApp(const RogueDescentApp());
}

class RogueDescentApp extends StatelessWidget {
  const RogueDescentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rogue Descent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const DungeonScreen(),
    );
  }
}

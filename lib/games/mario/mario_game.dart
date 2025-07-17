import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mario_world.dart';
import 'mario_player.dart';
import 'mario_ui.dart';

/// Entry point for the Super Mario game.
/// Designed and engineered with best practices for modularity, performance, and retro arcade polish.
class MarioGame extends StatefulWidget {
  const MarioGame({Key? key}) : super(key: key);

  @override
  State<MarioGame> createState() => _MarioGameState();
}

class _MarioGameState extends State<MarioGame>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _gameLoop;
  late MarioWorld world;
  late MarioPlayer mario;

  @override
  void initState() {
    super.initState();
    world = MarioWorld();
    mario = MarioPlayer(world: world);
    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(days: 365), // effectively infinite
    )
      ..addListener(_onFrame)
      ..forward();
  }

  void _onFrame() {
    setState(() {
      mario.update();
      world.update(mario);
    });
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
              mario.vx = -MarioPlayer.moveSpeed;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
              mario.vx = MarioPlayer.moveSpeed;
            } else if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.keyW || event.logicalKey == LogicalKeyboardKey.arrowUp) {
              // Only jump if on ground
              final int tileBelowY = (mario.y + 1).floor();
              final int tileX = mario.x.floor();
              if (tileBelowY < world.tiles.length && world.tiles[tileBelowY][tileX] == 1 && mario.vy.abs() < 0.01) {
                mario.vy = MarioPlayer.jumpSpeed;
              }
            }
          } else if (event is RawKeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
              if (mario.vx < 0) mario.vx = 0;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
              if (mario.vx > 0) mario.vx = 0;
            }
          }
        },
        child: Stack(
          children: [
            // World and Mario
            Positioned.fill(
              child: CustomPaint(
                painter: world,
                foregroundPainter: mario,
              ),
            ),
            // UI overlay
            MarioUI(mario: mario, world: world),
          ],
        ),
      ),
    );
  }
}

// TODO: Implement MarioWorld (tilemap, scrolling, collision)
// TODO: Implement MarioPlayer (physics, animation, controls)
// TODO: Add enemies, items, powerups
// TODO: Add sound, score, and polish

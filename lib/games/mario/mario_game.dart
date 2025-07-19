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
  bool _isMobile(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  Widget _retroButton(
      {required IconData icon,
      VoidCallback? onTap,
      VoidCallback? onPanDown,
      VoidCallback? onPanEnd}) {
    return GestureDetector(
      onTap: onTap,
      onPanDown: (_) => onPanDown?.call(),
      onPanEnd: (_) => onPanEnd?.call(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: const Color(0xFF00FFF7), width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFF7).withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF00FFF7), size: 36),
      ),
    );
  }

  int score = 0;
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
    print('Game loop frame: Mario x=${mario.x} y=${mario.y} vx=${mario.vx}');
    setState(() {
      mario.update();
      // Coin collection logic
      final int marioX = mario.x.round();
      final int marioY = mario.y.round();
      if (marioY >= 0 &&
          marioY < world.tiles.length &&
          marioX >= 0 &&
          marioX < world.tiles[0].length &&
          world.tiles[marioY][marioX] == 3) {
        world.tiles[marioY][marioX] = 0; // Remove coin
        score++;
      }
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
      appBar: AppBar(
        title: const Text('Super Mario'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: KeyboardListener(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: (event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                      event.logicalKey == LogicalKeyboardKey.keyA) {
                    setState(() {
                      mario.vx = -MarioPlayer.moveSpeed;
                    });
                  } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowRight ||
                      event.logicalKey == LogicalKeyboardKey.keyD) {
                    setState(() {
                      mario.vx = MarioPlayer.moveSpeed;
                    });
                  } else if (event.logicalKey == LogicalKeyboardKey.space ||
                      event.logicalKey == LogicalKeyboardKey.keyW ||
                      event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    // Only jump if on ground
                    final int tileBelowY = (mario.y + 1).floor();
                    final int tileX = mario.x.floor();
                    if (tileBelowY < world.tiles.length &&
                        world.tiles[tileBelowY][tileX] == 1 &&
                        mario.vy.abs() < 0.01) {
                      setState(() {
                        mario.vy = MarioPlayer.jumpSpeed;
                      });
                    }
                  }
                } else if (event is KeyUpEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                      event.logicalKey == LogicalKeyboardKey.keyA) {
                    setState(() {
                      if (mario.vx < 0) mario.vx = 0;
                    });
                  } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowRight ||
                      event.logicalKey == LogicalKeyboardKey.keyD) {
                    setState(() {
                      if (mario.vx > 0) mario.vx = 0;
                    });
                  }
                }
              },
              child: Stack(
                children: [
                  // World and Mario
                  Positioned.fill(
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: world,
                        ),
                        CustomPaint(
                          painter: mario,
                        ),
                      ],
                    ),
                  ),
                  // UI overlay
                  MarioUI(mario: mario, world: world, score: score),
                  // On-screen controls (mobile only)
                  if (_isMobile(context))
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Container(
                        color: Colors
                            .grey, // DEBUG: Add visible background to ensure not covered
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _retroButton(
                              icon: Icons.arrow_left,
                              onPanDown: () {
                                print('LEFT button down');
                                setState(() {
                                  mario.vx = -(_isMobile(context)
                                      ? 1.0
                                      : MarioPlayer.moveSpeed);
                                });
                              },
                              onPanEnd: () {
                                print('LEFT button up');
                                setState(() {
                                  if (mario.vx < 0) mario.vx = 0;
                                });
                              },
                            ),
                            _retroButton(
                              icon: Icons.arrow_drop_up,
                              onTap: () {
                                print('JUMP button tap');
                                final int tileBelowY = (mario.y + 1).floor();
                                final int tileX = mario.x.floor();
                                if (tileBelowY < world.tiles.length &&
                                    world.tiles[tileBelowY][tileX] == 1 &&
                                    mario.vy.abs() < 0.01) {
                                  setState(() {
                                    mario.vy = MarioPlayer.jumpSpeed;
                                  });
                                }
                              },
                            ),
                            _retroButton(
                              icon: Icons.arrow_right,
                              onPanDown: () {
                                print('RIGHT button down');
                                setState(() {
                                  mario.vx = (_isMobile(context)
                                      ? 1.0
                                      : MarioPlayer.moveSpeed);
                                });
                              },
                              onPanEnd: () {
                                print('RIGHT button up');
                                setState(() {
                                  if (mario.vx > 0) mario.vx = 0;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

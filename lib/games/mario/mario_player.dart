import 'package:flutter/material.dart';
import 'mario_world.dart';

/// Represents Mario, the player character.
/// Handles movement, physics, and animation.
class MarioPlayer extends ChangeNotifier implements CustomPainter {
  MarioPlayer({required this.world});
  final MarioWorld world;

  // Mario's position (in tile coordinates)
  double x = 2;
  double y = 4;

  // Mario's velocity
  double vx = 0;
  double vy = 0;

  // Physics constants
  static const double gravity = 0.18;
  static const double moveSpeed = 0.12;
  static const double jumpSpeed = -0.33;

  void update() {
    // Apply velocity
    x += vx;
    vy += gravity;
    y += vy;

    // --- Basic ground collision ---
    // Check tile below Mario's feet
    final int tileBelowY = (y + 1).floor();
    final int tileX = x.floor();
    if (tileBelowY < world.tiles.length && tileX < world.tiles[0].length) {
      if (world.tiles[tileBelowY][tileX] == 1) { // 1 = ground
        y = tileBelowY - 1;
        vy = 0;
      }
    }

    // Clamp to world bounds
    if (x < 0) x = 0;
    if (x > world.tiles[0].length - 1) x = (world.tiles[0].length - 1).toDouble();
    if (y < 0) y = 0;
    if (y > world.tiles.length - 1) y = (world.tiles.length - 1).toDouble();

    // TODO: Add input (left/right/jump), powerups, animation
  }

  @override
  void paint(Canvas canvas, Size size) {
  print('MarioPlayer.paint called, size=[32m$size[0m, x=$x, y=$y');
    // TODO: Draw Mario sprite (placeholder: red square)
    final double tileSize = size.width / world.tiles[0].length;
    final paint = Paint()..color = Colors.red;
    canvas.drawRect(
      Rect.fromLTWH(x * tileSize, y * tileSize, tileSize, tileSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool? hitTest(Offset position) => null;

  @override
  SemanticsBuilderCallback get semanticsBuilder => (Size size) => [];

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}

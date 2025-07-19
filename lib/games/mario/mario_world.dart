import 'package:flutter/material.dart';
import 'package:flutter_games/games/mario/mario_player.dart';

/// Basic MarioWorld stub for Mario game integration.
class MarioWorld extends ChangeNotifier implements CustomPainter {
  // Simple 10x10 tile map: 0 = empty, 1 = ground, 2 = brick, 3 = coin
  // 10x10 Mario-like level: ground, bricks, coins
  final List<List<int>> _tiles = [
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,2,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,3,0,0,0,2,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,2,0,0,0,0,3,0,0,0],
    [0,0,0,0,2,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,2,0,0,0,0,0,3,0],
    [1,1,1,1,1,1,1,1,1,1],
  ];

  List<List<int>> get tiles => _tiles;

  void update(MarioPlayer mario) {
    // TODO: Implement world update logic (e.g., scrolling, collision, etc.)
  }

  @override
  void paint(Canvas canvas, Size size) {
  // DEBUG: Fill background so we know painting is happening
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.width, size.height),
    Paint()..color = Colors.blueGrey,
  );
  print('MarioWorld.paint called, size=[32m$size[0m');
    final int rows = _tiles.length;
    final int cols = _tiles[0].length;
    final double tileW = size.width / cols;
    final double tileH = size.height / rows;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final rect = Rect.fromLTWH(x * tileW, y * tileH, tileW, tileH);
        switch (_tiles[y][x]) {
          case 1: // Ground
            canvas.drawRect(rect, Paint()..color = const Color(0xFF8B5A2B));
            break;
          case 2: // Brick
            canvas.drawRect(rect, Paint()..color = const Color(0xFFFFA500));
            break;
          case 3: // Coin
            canvas.drawCircle(rect.center, tileW * 0.3, Paint()..color = Colors.yellow);
            break;
          default:
            // Empty
            break;
        }
      }
    }
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

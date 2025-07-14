import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/pacman_board.dart';
import '../models/game_objects.dart';

class PacmanScreen extends StatefulWidget {
  const PacmanScreen({super.key});

  @override
  State<PacmanScreen> createState() => _PacmanScreenState();
}

class _PacmanScreenState extends State<PacmanScreen> {
  final _controller = PacmanGameController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onGameStateChanged);
    _controller.startGame();
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragUpdate: _controller.onSwipe,
          onVerticalDragUpdate: _controller.onSwipe,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildGameBoard()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String message;
    if (_controller.isGameOver) {
      message = _controller.isGameWon ? 'YOU WIN!' : 'GAME OVER';
    } else {
      message = 'PAC-MAN';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.yellowAccent),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back to Menu',
            ),
          ),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.yellowAccent,
              shadows: [Shadow(color: Colors.yellow, blurRadius: 10)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / PacmanGameController.colCount;
          final cellHeight = constraints.maxHeight / PacmanGameController.rowCount;

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade800, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Stack(
              children: [
                CustomPaint(size: Size.infinite, painter: _GridPainter()),
                ..._controller.walls.map((p) => _buildWall(p, cellWidth, cellHeight)),
                ..._controller.dots.map((p) => _buildDot(p, cellWidth, cellHeight)),
                ..._controller.ghosts.map((g) => _buildGhost(g, cellWidth, cellHeight)),
                _buildPlayer(_controller.player, cellWidth, cellHeight),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('SCORE: ${_controller.score}',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 18,
              )),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellowAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _controller.startGame,
            child: const Text('PLAY', style: TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildWall(Point p, double cw, double ch) => Positioned(
        left: p.x * cw, top: p.y * ch, width: cw, height: ch,
        child: Container(color: Colors.blue.shade900.withOpacity(0.8)),
      );

  Widget _buildDot(Point p, double cw, double ch) => Positioned(
        left: p.x * cw + cw * 0.4, top: p.y * ch + ch * 0.4,
        child: Container(
          width: cw * 0.2, height: ch * 0.2,
          decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
        ),
      );

  Widget _buildGhost(Ghost g, double cw, double ch) => Positioned(
        left: g.position.x * cw, top: g.position.y * ch, width: cw, height: ch,
        child: Image.asset(g.imageAsset, fit: BoxFit.contain),
      );

  Widget _buildPlayer(Player p, double cw, double ch) => Positioned(
        left: p.position.x * cw, top: p.position.y * ch, width: cw, height: ch,
        child: Transform.rotate(
          angle: _getPacmanAngle(p.direction),
          child: ClipPath(clipper: _PacmanClipper(), child: Container(color: Colors.yellow)),
        ),
      );

  double _getPacmanAngle(Direction dir) {
    switch (dir) {
      case Direction.right: return 0.0;
      case Direction.down: return pi / 2;
      case Direction.left: return pi;
      case Direction.up: return 3 * pi / 2;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    super.dispose();
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue.withOpacity(0.2)..strokeWidth = 1;
    final dx = size.width / PacmanGameController.colCount;
    final dy = size.height / PacmanGameController.rowCount;
    for (double x = 0; x <= size.width; x += dx) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += dy) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PacmanClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final r = min(s.width, s.height) / 2;
    const mouth = pi / 4;
    return Path()
      ..moveTo(r, r)
      ..arcTo(Rect.fromCircle(center: Offset(r, r), radius: r), mouth, 2 * pi - 2 * mouth, false)
      ..close();
  }

  @override
  bool shouldReclip(oldClipper) => false;
}

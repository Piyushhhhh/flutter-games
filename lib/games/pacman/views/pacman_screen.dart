import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/pacman_board.dart';
import '../models/game_objects.dart';

class PacmanScreen extends StatefulWidget {
  const PacmanScreen({super.key});

  @override
  State<PacmanScreen> createState() => _PacmanScreenState();
}

class _PacmanScreenState extends State<PacmanScreen>
    with TickerProviderStateMixin {
  final _controller = PacmanGameController();
  late AnimationController _mouthController;
  late Animation<double> _mouthAnimation;
  late AnimationController _dotPulseController;
  late AnimationController _blinkingGhostController;

  late AnimationController _gameOverController;
  late Animation<double> _gameOverAnimation;
  bool _isGameReady = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onGameStateChanged);

    _mouthController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _mouthAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _mouthController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _mouthController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _mouthController.forward();
        }
      });

    _dotPulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _blinkingGhostController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));


    _gameOverController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _gameOverAnimation =
        CurvedAnimation(parent: _gameOverController, curve: Curves.elasticOut);

    _dotPulseController.repeat(reverse: true);
    _blinkingGhostController.repeat(reverse: true);
    _mouthController.forward();
    _showReadyAndStart();
  }

  void _onGameStateChanged() {
    if (!mounted) return;
    if (_controller.isGameOver) {
      _gameOverController.forward(from: 0.0);
    }
    setState(() {});
  }

  void _showReadyAndStart() async {
    setState(() => _isGameReady = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isGameReady = false);
    _controller.startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
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
            Positioned(
              top: 8,
              left: 8,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '< BACK',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontFamily: 'monospace',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: 'monospace',
    );
    const scoreStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('HIGH SCORE', style: textStyle),
              const SizedBox(height: 4),
              Text(_controller.score.toString(), style: scoreStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth =
              constraints.maxWidth / PacmanGameController.colCount;
          final cellHeight =
              constraints.maxHeight / PacmanGameController.rowCount;

          return Container(
            color: Colors.black,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _MazePainter(
                    walls: _controller.walls,
                    cellWidth: cellWidth,
                    cellHeight: cellHeight,
                  ),
                ),
                ..._controller.dots
                    .map((p) => _buildDot(p, cellWidth, cellHeight)),
                ..._controller.powerPellets
                    .map((p) => _buildPowerPellet(p, cellWidth, cellHeight)),
                _buildGhostDoor(cellWidth, cellHeight),
                ..._controller.ghosts
                    .map((g) => _buildGhost(g, cellWidth, cellHeight)),
                _buildPlayer(_controller.player, cellWidth, cellHeight),
                if (_controller.cherryPosition != null) _buildCherry(_controller.cherryPosition!, cellWidth, cellHeight),
                if (_isGameReady) _buildReadyOverlay(),
                if (_controller.isGameOver) _buildGameOverOverlay(),
                _buildBottomUI(cellWidth, cellHeight),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    // The original game didn't have a play button on this screen,
    // but we need one to restart the game.
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_controller.isGameOver)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                _gameOverController.reset();
                _showReadyAndStart();
              },
              child: const Text('PLAY AGAIN',
                  style: TextStyle(fontFamily: 'monospace')),
            ),
        ],
      ),
    );
  }

  Widget _buildDot(Point p, double cw, double ch) {
    return Positioned(
      left: p.x * cw,
      top: p.y * ch,
      width: cw,
      height: ch,
      child: Center(
        child: Container(
          width: cw * 0.15, // Made smaller
          height: ch * 0.15, // Made smaller
          decoration: BoxDecoration(
            color: const Color(0xFFFBC4A1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFBC4A1).withOpacity(0.4),
                blurRadius: 3.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerPellet(Point p, double cw, double ch) {
    return Positioned(
      left: p.x * cw,
      top: p.y * ch,
      width: cw,
      height: ch,
      child: Center(
        child: AnimatedBuilder(
          animation: _dotPulseController, // Use controller for flicker
          builder: (context, child) {
            // Create a flicker effect by varying opacity
            final flicker = sin(_dotPulseController.value * pi * 4).abs();
            return Opacity(
              opacity: 0.5 + (flicker * 0.5),
              child: Container(
                width: cw * 0.6,
                height: ch * 0.6,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBC4A1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFBC4A1),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGhost(Ghost g, double cw, double ch) {
    Widget ghostImage;
    switch (g.state) {
      case GhostState.normal:
        ghostImage = Image.asset(g.imageAsset, fit: BoxFit.contain);
        break;
      case GhostState.frightened:
        ghostImage = AnimatedBuilder(
          animation: _blinkingGhostController,
          builder: (context, child) {
            final baseImage = Image.asset('assets/frightened_ghost.png', fit: BoxFit.contain);

            if (_controller.isBlinking) {
              // Rapidly change color for a blinking effect
              final isBlinkingOff = _blinkingGhostController.value < 0.5;
              return ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isBlinkingOff ? Colors.white : Colors.blue.shade300,
                  BlendMode.modulate,
                ),
                child: baseImage,
              );
            }
            return baseImage;
          },
        );
        break;
      case GhostState.eaten:
        ghostImage = Image.asset('assets/eaten_ghost.png', fit: BoxFit.contain);
        break;
    }

    return Positioned(
      left: g.position.x * cw,
      top: g.position.y * ch,
      width: cw,
      height: ch,
      child: ghostImage,
    );
  }

  Widget _buildCherry(Point p, double cw, double ch) {
    return Positioned(
      left: p.x * cw,
      top: p.y * ch,
      width: cw,
      height: ch,
      child: Image.asset('assets/cherry.png', fit: BoxFit.contain),
    );
  }

  Widget _buildPlayer(Player p, double cw, double ch) {
    return Positioned(
      left: p.position.x * cw,
      top: p.position.y * ch,
      width: cw,
      height: ch,
      child: Transform.rotate(
        angle: _getPacmanAngle(p.direction),
        child: AnimatedBuilder(
          animation: _mouthAnimation,
          builder: (context, child) {
            return ClipPath(
              clipper: _PacmanClipper(mouthExtent: _mouthAnimation.value),
              child: Container(color: Colors.yellow),
            );
          },
        ),
      ),
    );
  }

  double _getPacmanAngle(Direction dir) {
    switch (dir) {
      case Direction.right:
        return 0.0;
      case Direction.down:
        return pi / 2;
      case Direction.left:
        return pi;
      case Direction.up:
        return 3 * pi / 2;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _mouthController.dispose();
    _dotPulseController.dispose();
    _blinkingGhostController.dispose();
    _gameOverController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildGameOverOverlay() {
    return Center(
      child: ScaleTransition(
        scale: _gameOverAnimation,
        child: FadeTransition(
          opacity: _gameOverAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade700, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.7),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Text(
              _controller.isGameWon ? 'YOU WIN!' : 'GAME OVER',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _controller.isGameWon
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadyOverlay() {
    return const Center(
      child: Text(
        'READY!',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.yellow,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.yellowAccent,
              offset: Offset(0, 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGhostDoor(double cw, double ch) {
    return Positioned(
      top: 13 * ch - 1,
      left: 13 * cw,
      child: Container(
        width: 2 * cw,
        height: 2,
        color: Colors.pinkAccent,
      ),
    );
  }

  Widget _buildBottomUI(double cellWidth, double cellHeight) {
    return Positioned(
      bottom: cellHeight * 1.5, // Adjust position as needed
      left: cellWidth * 2,
      right: cellWidth * 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
                2,
                (i) => Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Transform.rotate(
                        angle: pi, // Facing left
                        child: SizedBox(
                          width: cellWidth * 1.5,
                          height: cellHeight * 1.5,
                          child: ClipPath(
                            clipper: _PacmanClipper(mouthExtent: 0.0),
                            child: Container(color: Colors.yellow),
                          ),
                        ),
                      ),
                    )),
          ),
          // TODO: Implement fruit logic
          SizedBox(
            width: cellWidth * 1.5,
            height: cellHeight * 1.5,
            child: Image.asset('assets/cherry.png', fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _MazePainter extends CustomPainter {
  final Set<Point> walls;
  final double cellWidth;
  final double cellHeight;

  _MazePainter(
      {required this.walls, required this.cellWidth, required this.cellHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2121DE) // Classic Pac-Man Blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (final wall in walls) {
      final double x = wall.x * cellWidth;
      final double y = wall.y * cellHeight;
      final center = Offset(x + cellWidth / 2, y + cellHeight / 2);

      // Check for neighbors
      final hasLeft = walls.contains(Point(wall.x - 1, wall.y));
      final hasRight = walls.contains(Point(wall.x + 1, wall.y));
      final hasUp = walls.contains(Point(wall.x, wall.y - 1));
      final hasDown = walls.contains(Point(wall.x, wall.y + 1));

      // Draw lines to neighbors
      if (hasRight) {
        path.moveTo(center.dx, center.dy);
        path.lineTo(center.dx + cellWidth / 2, center.dy);
      }
      if (hasLeft) {
        path.moveTo(center.dx, center.dy);
        path.lineTo(center.dx - cellWidth / 2, center.dy);
      }
      if (hasDown) {
        path.moveTo(center.dx, center.dy);
        path.lineTo(center.dx, center.dy + cellHeight / 2);
      }
      if (hasUp) {
        path.moveTo(center.dx, center.dy);
        path.lineTo(center.dx, center.dy - cellHeight / 2);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MazePainter oldDelegate) => oldDelegate.walls != walls;
}

class _PacmanClipper extends CustomClipper<Path> {
  final double mouthExtent;
  _PacmanClipper({this.mouthExtent = 0.15});

  @override
  Path getClip(Size s) {
    final startAngle = mouthExtent * pi;
    final sweepAngle = (2 - mouthExtent * 2) * pi;
    return Path()
      ..moveTo(s.width / 2, s.height / 2)
      ..arcTo(
          Rect.fromLTWH(0, 0, s.width, s.height), startAngle, sweepAngle, false)
      ..close();
  }

  @override
  bool shouldReclip(_PacmanClipper oldClipper) =>
      mouthExtent != oldClipper.mouthExtent;
}

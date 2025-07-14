import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_objects.dart';

class PacmanGameController extends ChangeNotifier {
  // Game constants
  static const int rowCount = 21;
  static const int colCount = 19;
  static const Duration tick = Duration(milliseconds: 180);

  // Game state
  late Player player;
  late List<Ghost> ghosts;
  late Set<Point> dots;
  late Set<Point> powerPellets;
  late Set<Point> walls;
  late Set<Point> ghostDoor;
  int score = 0;
  bool isGameOver = false;
  bool isGameWon = false;
  Point? cherryPosition;

  Timer? _timer;

  PacmanGameController() {
    _initialize();
  }

  void _initialize() {
    // Initialize ghostDoor first as it's used in _getClassicWalls
    ghostDoor = {const Point(9, 7)};
    walls = _getClassicWalls();

    // Reset state
    player = Player(position: const Point(9, 15), direction: Direction.left);
    ghosts = [
      Ghost(position: const Point(9, 8), imageAsset: 'assets/ghost.png', isReleased: true), // Blinky
      Ghost(position: const Point(8, 10), imageAsset: 'assets/ghost2.png'), // Pinky
      Ghost(position: const Point(10, 10), imageAsset: 'assets/ghost3.png'), // Inky
      Ghost(position: const Point(9, 9), imageAsset: 'assets/ghost.png'), // Clyde
    ];
    powerPellets = {
      const Point(1, 2),
      const Point(17, 2),
      const Point(1, 18),
      const Point(17, 18),
    };
    dots = {
      for (var x = 1; x < colCount - 1; x++)
        for (var y = 1; y < rowCount - 1; y++)
          if (!walls.contains(Point(x, y)) && !powerPellets.contains(Point(x,y))) Point(x, y)
    };
    score = 0;
    isGameOver = false;
    isGameWon = false;
    cherryPosition = null;
    Timer(const Duration(seconds: 10), () {
      cherryPosition = const Point(9, 12);
      notifyListeners();
    });
    // Staggered ghost release timers
    Timer(const Duration(seconds: 2), () {
      if (ghosts.length > 1) {
        ghosts[1].isReleased = true;
        notifyListeners();
      }
    });
    Timer(const Duration(seconds: 4), () {
      if (ghosts.length > 2) {
        ghosts[2].isReleased = true;
        notifyListeners();
      }
    });
    Timer(const Duration(seconds: 6), () {
      if (ghosts.length > 3) {
        ghosts[3].isReleased = true;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void startGame() {
    _timer?.cancel(); // Cancel any existing timer
    _initialize();
    _timer = Timer.periodic(tick, (_) => _step());
  }

  void _step() {
    if (isGameOver) {
      _timer?.cancel();
      return;
    }

    // Move player
    final nextPlayerPos = _getNextPosition(player.position, player.direction);
    if (!walls.contains(nextPlayerPos)) {
      player.position = nextPlayerPos;
    }

    // Collect dots
    if (dots.remove(player.position)) {
      score++;
    }
    if (powerPellets.remove(player.position)) {
      score += 5;
      // TODO: Add frighten ghosts logic
    }

    // Collect cherry
    if (cherryPosition != null && player.position == cherryPosition) {
      score += 100;
      cherryPosition = null;
    }

    // Move ghosts
    for (final ghost in ghosts) {
      _moveGhost(ghost);
    }

    // Check for collisions
    if (ghosts.any((g) => g.position == player.position)) {
      isGameOver = true;
      _timer?.cancel();
    } else if (dots.isEmpty) {
      isGameOver = true;
      isGameWon = true;
      _timer?.cancel();
    }

    notifyListeners();
  }

  void _moveGhost(Ghost ghost) {
    // === GHOST DEBUG LOGGING START ===
    final ghostName = "Ghost ${ghosts.indexOf(ghost)}";
    print('--- $ghostName | Pos: (${ghost.position.x}, ${ghost.position.y}), Released: ${ghost.isReleased} ---');
    
    if (!ghost.isReleased) return;

    Direction bestDirection;
    // The pen is the area where ghosts start
    final bool isInPen = ghost.position.y >= 8 && ghost.position.y <= 10 && ghost.position.x >= 7 && ghost.position.x <= 11;

    if (isInPen) {
      // Definitive Pen Exit Logic: Move to center row, then align with door, then exit.
      const centerPenY = 9;
      final doorPosition = ghostDoor.first;

      if (ghost.position.y != centerPenY) {
        bestDirection = Direction.up; // Move to the center row first
      } else if (ghost.position.x != doorPosition.x) {
        bestDirection = (ghost.position.x < doorPosition.x) ? Direction.right : Direction.left; // Then align with the door
      } else {
        bestDirection = Direction.up; // Then exit
      }
    } else {
      // When outside the pen, chase Pac-Man
      bestDirection = _getChaseDirection(ghost.position, player.position, ghost.direction);
    }

    print('$ghostName | In Pen: $isInPen, Best Direction: $bestDirection');

    final nextGhostPos = _getNextPosition(ghost.position, bestDirection);
    print('$ghostName | Next Position: (${nextGhostPos.x}, ${nextGhostPos.y})');

    // Ghosts can move through walls only at the ghost door
    if (!walls.contains(nextGhostPos) || ghostDoor.contains(nextGhostPos)) {
      ghost.direction = bestDirection;
      ghost.position = nextGhostPos;
      print('$ghostName | Action: MOVED to (${nextGhostPos.x}, ${nextGhostPos.y})');
    } else {
      print('$ghostName | Action: BLOCKED by wall');
    }
    print('--- End $ghostName ---');
  }

  Direction _getChaseDirection(Point from, Point to, Direction currentDirection) {
    Direction bestDirection = currentDirection;
    double minDistance = double.infinity;
    final random = Random();

    final directions = Direction.values.toList()..shuffle(random);

    for (final direction in directions) {
      // Prevent ghosts from reversing direction immediately
      if (direction.index == (currentDirection.index + 2) % 4) continue;

      final nextPos = _getNextPosition(from, direction);
      if (!walls.contains(nextPos) || ghostDoor.contains(nextPos)) {
        final distance = pow(nextPos.x - to.x, 2) + pow(nextPos.y - to.y, 2);
        if (distance < minDistance) {
          minDistance = distance.toDouble();
          bestDirection = direction;
        }
      }
    }
    return bestDirection;
  }

  Point _getNextPosition(Point p, Direction d) {
    switch (d) {
      case Direction.left: return Point((p.x - 1 + colCount) % colCount, p.y);
      case Direction.right: return Point((p.x + 1) % colCount, p.y);
      case Direction.up: return Point(p.x, (p.y - 1 + rowCount) % rowCount);
      case Direction.down: return Point(p.x, (p.y + 1) % rowCount);
    }
  }

  void onSwipe(DragUpdateDetails d) {
    if (isGameOver) return;
    if (d.delta.dx.abs() > d.delta.dy.abs()) {
      player.direction = d.delta.dx < 0 ? Direction.left : Direction.right;
    } else {
      player.direction = d.delta.dy < 0 ? Direction.up : Direction.down;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Set<Point> _getClassicWalls() {
    return {
      // Outer walls
      for (var i = 0; i < colCount; i++) ...{Point(i, 0), Point(i, rowCount - 1)},
      for (var i = 1; i < rowCount - 1; i++) ...{Point(0, i), Point(colCount - 1, i)},

      // Maze structure
      // Top T
      for (var i = 4; i < 15; i++) Point(i, 4),
      for (var i = 2; i < 5; i++) Point(9, i),

      // Bottom T
      for (var i = 4; i < 15; i++) Point(i, 16),
      for (var i = 16; i < 19; i++) Point(9, i),

      // Left and Right Pillars
      for (var i = 2; i < 5; i++) ...{Point(2, i), Point(16, i)},
      for (var i = 6; i < 15; i++) ...{Point(2, i), Point(16, i)},
      for (var i = 16; i < 19; i++) ...{Point(2, i), Point(16, i)},

      // Center blocks
      for (var i = 4; i < 7; i++) ...{Point(i, 6), Point(i + 9, 6)},
      for (var i = 4; i < 7; i++) ...{Point(i, 14), Point(i + 9, 14)},

      // Ghost house
      for (var i = 7; i < 12; i++) if (i != 9) Point(i, 7), // Top wall with door opening
      for (var i = 8; i < 11; i++) ...{Point(7, i), Point(11, i)}, // Side walls
      for (var i = 8; i < 12; i++) Point(i, 10), // Bottom wall


      // Mid-level blocks
      for (var i = 4; i < 7; i++) ...{Point(i, 2), Point(i + 9, 2)},
      for (var i = 4; i < 7; i++) ...{Point(i, 18), Point(i + 9, 18)},
      for (var i = 12; i < 15; i++) ...{Point(4, i), Point(14, i)},
      for (var i = 4; i < 15; i++) if (i != 9) Point(i, 12),
      for (var i = 6; i < 9; i++) ...{Point(4, i), Point(14, i)},

    };
  }
}

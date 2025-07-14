import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_objects.dart';

class PacmanGameController extends ChangeNotifier {
  // Game constants
  static const int rowCount = 17;
  static const int colCount = 17;
  static const Duration tick = Duration(milliseconds: 180);

  // Game state
  late Player player;
  late List<Ghost> ghosts;
  late Set<Point> dots;
  late Set<Point> walls;
  int score = 0;
  bool isGameOver = false;
  bool isGameWon = false;

  Timer? _timer;

  PacmanGameController() {
    _initialize();
  }

  void _initialize() {
    // Define walls
    walls = {
      // Outer border
      for (var x = 0; x < colCount; x++) ...{Point(x, 0), Point(x, rowCount - 1)},
      for (var y = 0; y < rowCount; y++) ...{Point(0, y), Point(colCount - 1, y)},
      // Plus interior
      for (var y = 4; y < rowCount - 4; y++) Point(colCount ~/ 2, y),
      for (var x = 4; x < colCount - 4; x++) Point(x, rowCount ~/ 2),
    };

    // Reset state
    player = Player(position: const Point(1, 1), direction: Direction.right);
    ghosts = [
      Ghost(position: const Point(colCount - 2, 1), imageAsset: 'assets/ghost.png'),
      Ghost(position: const Point(1, rowCount - 2), imageAsset: 'assets/ghost2.png'),
      Ghost(position: const Point(colCount - 2, rowCount - 2), imageAsset: 'assets/ghost3.png'),
      // Using ghost.png again for the 4th ghost as requested
      Ghost(position: const Point(colCount ~/ 2, 1), imageAsset: 'assets/ghost.png'),
    ];
    dots = {
      for (var x = 1; x < colCount - 1; x++)
        for (var y = 1; y < rowCount - 1; y++)
          if (!walls.contains(Point(x, y))) Point(x, y)
    };
    score = 0;
    isGameOver = false;
    isGameWon = false;
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
    final random = Random();
    // Simple AI: 60% chance to chase Pac-Man, 40% to move randomly
    if (random.nextDouble() < 0.6) {
      ghost.direction = _getChaseDirection(ghost.position, player.position);
    } else {
      ghost.direction = Direction.values[random.nextInt(4)];
    }
    final nextGhostPos = _getNextPosition(ghost.position, ghost.direction);
    if (!walls.contains(nextGhostPos)) {
      ghost.position = nextGhostPos;
    }
  }

  Direction _getChaseDirection(Point from, Point to) {
    if ((to.x - from.x).abs() > (to.y - from.y).abs()) {
      return to.x < from.x ? Direction.left : Direction.right;
    } else {
      return to.y < from.y ? Direction.up : Direction.down;
    }
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
}

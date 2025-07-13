import 'package:flutter/material.dart';
import 'dart:math' as math;

// Position class for grid coordinates
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  Position operator +(Position other) {
    return Position(row + other.row, col + other.col);
  }

  Position operator -(Position other) {
    return Position(row - other.row, col - other.col);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position($row, $col)';
}

// Tetromino types
enum TetrominoType {
  I, // Line
  O, // Square
  T, // T-shape
  S, // S-shape
  Z, // Z-shape
  J, // J-shape
  L, // L-shape
}

// Game states
enum GameState {
  playing,
  paused,
  gameOver,
  lineClearing,
}

// Tetromino piece class
class Tetromino {
  final TetrominoType type;
  final List<List<List<int>>> rotations;
  final Color color;
  final Color glowColor;
  final Gradient gradient;

  const Tetromino({
    required this.type,
    required this.rotations,
    required this.color,
    required this.glowColor,
    required this.gradient,
  });

  // Get the shape for a specific rotation (0-3)
  List<List<int>> getShape(int rotation) {
    return rotations[rotation % rotations.length];
  }

  // Get all occupied positions for this piece at given position and rotation
  List<Position> getOccupiedPositions(Position center, int rotation) {
    final shape = getShape(rotation);
    final positions = <Position>[];

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          positions.add(Position(
            center.row + row,
            center.col + col,
          ));
        }
      }
    }

    return positions;
  }

  // Static tetromino definitions
  static const Map<TetrominoType, Tetromino> pieces = {
    TetrominoType.I: Tetromino(
      type: TetrominoType.I,
      rotations: [
        [
          [0, 0, 0, 0],
          [1, 1, 1, 1],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        [
          [0, 0, 1, 0],
          [0, 0, 1, 0],
          [0, 0, 1, 0],
          [0, 0, 1, 0],
        ],
        [
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [1, 1, 1, 1],
          [0, 0, 0, 0],
        ],
        [
          [0, 1, 0, 0],
          [0, 1, 0, 0],
          [0, 1, 0, 0],
          [0, 1, 0, 0],
        ],
      ],
      color: Color(0xFF00FFFF),
      glowColor: Color(0xFF00FFFF),
      gradient: LinearGradient(
        colors: [Color(0xFF00FFFF), Color(0xFF0099FF)],
      ),
    ),
    TetrominoType.O: Tetromino(
      type: TetrominoType.O,
      rotations: [
        [
          [1, 1],
          [1, 1],
        ],
        [
          [1, 1],
          [1, 1],
        ],
        [
          [1, 1],
          [1, 1],
        ],
        [
          [1, 1],
          [1, 1],
        ],
      ],
      color: Color(0xFFFFFF00),
      glowColor: Color(0xFFFFFF00),
      gradient: LinearGradient(
        colors: [Color(0xFFFFFF00), Color(0xFFFFCC00)],
      ),
    ),
    TetrominoType.T: Tetromino(
      type: TetrominoType.T,
      rotations: [
        [
          [0, 1, 0],
          [1, 1, 1],
          [0, 0, 0],
        ],
        [
          [0, 1, 0],
          [0, 1, 1],
          [0, 1, 0],
        ],
        [
          [0, 0, 0],
          [1, 1, 1],
          [0, 1, 0],
        ],
        [
          [0, 1, 0],
          [1, 1, 0],
          [0, 1, 0],
        ],
      ],
      color: Color(0xFF8B00FF),
      glowColor: Color(0xFF8B00FF),
      gradient: LinearGradient(
        colors: [Color(0xFF8B00FF), Color(0xFF6600CC)],
      ),
    ),
    TetrominoType.S: Tetromino(
      type: TetrominoType.S,
      rotations: [
        [
          [0, 1, 1],
          [1, 1, 0],
          [0, 0, 0],
        ],
        [
          [0, 1, 0],
          [0, 1, 1],
          [0, 0, 1],
        ],
        [
          [0, 0, 0],
          [0, 1, 1],
          [1, 1, 0],
        ],
        [
          [1, 0, 0],
          [1, 1, 0],
          [0, 1, 0],
        ],
      ],
      color: Color(0xFF00FF00),
      glowColor: Color(0xFF00FF00),
      gradient: LinearGradient(
        colors: [Color(0xFF00FF00), Color(0xFF00CC00)],
      ),
    ),
    TetrominoType.Z: Tetromino(
      type: TetrominoType.Z,
      rotations: [
        [
          [1, 1, 0],
          [0, 1, 1],
          [0, 0, 0],
        ],
        [
          [0, 0, 1],
          [0, 1, 1],
          [0, 1, 0],
        ],
        [
          [0, 0, 0],
          [1, 1, 0],
          [0, 1, 1],
        ],
        [
          [0, 1, 0],
          [1, 1, 0],
          [1, 0, 0],
        ],
      ],
      color: Color(0xFFFF0000),
      glowColor: Color(0xFFFF0000),
      gradient: LinearGradient(
        colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
      ),
    ),
    TetrominoType.J: Tetromino(
      type: TetrominoType.J,
      rotations: [
        [
          [1, 0, 0],
          [1, 1, 1],
          [0, 0, 0],
        ],
        [
          [0, 1, 1],
          [0, 1, 0],
          [0, 1, 0],
        ],
        [
          [0, 0, 0],
          [1, 1, 1],
          [0, 0, 1],
        ],
        [
          [0, 1, 0],
          [0, 1, 0],
          [1, 1, 0],
        ],
      ],
      color: Color(0xFF0000FF),
      glowColor: Color(0xFF0000FF),
      gradient: LinearGradient(
        colors: [Color(0xFF0000FF), Color(0xFF0000CC)],
      ),
    ),
    TetrominoType.L: Tetromino(
      type: TetrominoType.L,
      rotations: [
        [
          [0, 0, 1],
          [1, 1, 1],
          [0, 0, 0],
        ],
        [
          [0, 1, 0],
          [0, 1, 0],
          [0, 1, 1],
        ],
        [
          [0, 0, 0],
          [1, 1, 1],
          [1, 0, 0],
        ],
        [
          [1, 1, 0],
          [0, 1, 0],
          [0, 1, 0],
        ],
      ],
      color: Color(0xFFFF8000),
      glowColor: Color(0xFFFF8000),
      gradient: LinearGradient(
        colors: [Color(0xFFFF8000), Color(0xFFCC6600)],
      ),
    ),
  };

  // Get a random tetromino
  static Tetromino getRandomPiece() {
    final types = TetrominoType.values;
    final randomType = types[math.Random().nextInt(types.length)];
    return pieces[randomType]!;
  }
}

// Active piece in the game
class ActivePiece {
  final Tetromino tetromino;
  Position position;
  int rotation;
  bool isGhost;

  ActivePiece({
    required this.tetromino,
    required this.position,
    this.rotation = 0,
    this.isGhost = false,
  });

  // Create a copy of this piece
  ActivePiece copy() {
    return ActivePiece(
      tetromino: tetromino,
      position: position,
      rotation: rotation,
      isGhost: isGhost,
    );
  }

  // Get all occupied positions for this piece
  List<Position> getOccupiedPositions() {
    return tetromino.getOccupiedPositions(position, rotation);
  }

  // Move the piece
  void move(int deltaRow, int deltaCol) {
    position = Position(position.row + deltaRow, position.col + deltaCol);
  }

  // Rotate the piece clockwise
  void rotate() {
    rotation = (rotation + 1) % 4;
  }

  // Rotate the piece counter-clockwise
  void rotateCounterClockwise() {
    rotation = (rotation - 1) % 4;
    if (rotation < 0) rotation = 3;
  }
}

// Game board cell
class BoardCell {
  final bool isOccupied;
  final Color? color;
  final Gradient? gradient;
  final Color? glowColor;
  final bool isClearing;

  const BoardCell({
    this.isOccupied = false,
    this.color,
    this.gradient,
    this.glowColor,
    this.isClearing = false,
  });

  BoardCell copyWith({
    bool? isOccupied,
    Color? color,
    Gradient? gradient,
    Color? glowColor,
    bool? isClearing,
  }) {
    return BoardCell(
      isOccupied: isOccupied ?? this.isOccupied,
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      glowColor: glowColor ?? this.glowColor,
      isClearing: isClearing ?? this.isClearing,
    );
  }
}

// Game statistics
class GameStats {
  final int score;
  final int level;
  final int lines;
  final int pieces;
  final Duration gameTime;

  const GameStats({
    this.score = 0,
    this.level = 1,
    this.lines = 0,
    this.pieces = 0,
    this.gameTime = Duration.zero,
  });

  GameStats copyWith({
    int? score,
    int? level,
    int? lines,
    int? pieces,
    Duration? gameTime,
  }) {
    return GameStats(
      score: score ?? this.score,
      level: level ?? this.level,
      lines: lines ?? this.lines,
      pieces: pieces ?? this.pieces,
      gameTime: gameTime ?? this.gameTime,
    );
  }

  // Calculate score for line clears
  int getLineScore(int linesCleared) {
    switch (linesCleared) {
      case 1:
        return 40 * level;
      case 2:
        return 100 * level;
      case 3:
        return 300 * level;
      case 4: // Tetris!
        return 1200 * level;
      default:
        return 0;
    }
  }

  // Calculate drop speed based on level
  Duration getDropSpeed() {
    // Speed increases with level
    final baseSpeed = 1000; // milliseconds
    final speedReduction = (level - 1) * 50;
    final speed = math.max(50, baseSpeed - speedReduction);
    return Duration(milliseconds: speed);
  }
}

// Tetris game constants
class TetrisConstants {
  static const int boardWidth = 10;
  static const int boardHeight = 20;
  static const int visibleHeight = 20;
  static const int bufferHeight = 4; // Extra rows above visible area

  // Spawn position for new pieces
  static const Position spawnPosition = Position(0, 4);

  // Scoring
  static const int softDropPoints = 1;
  static const int hardDropMultiplier = 2;

  // Level progression
  static const int linesPerLevel = 10;

  // Preview pieces count
  static const int previewCount = 3;
}

// Line clear animation data
class LineClearAnimation {
  final List<int> clearingRows;
  final double progress;
  final Duration duration;

  const LineClearAnimation({
    required this.clearingRows,
    required this.progress,
    required this.duration,
  });

  bool get isComplete => progress >= 1.0;
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

// Position class for tracking coordinates
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
enum TetrominoType { I, O, T, S, Z, J, L }

// Game states
enum GameState { playing, paused, gameOver, lineClearing }

// Tetromino class with shapes and properties
class Tetromino {
  final TetrominoType type;
  final List<List<List<int>>> rotations;
  final Color color;
  final Gradient gradient;
  final Color glowColor;

  const Tetromino({
    required this.type,
    required this.rotations,
    required this.color,
    required this.gradient,
    required this.glowColor,
  });

  List<List<int>> getShape(int rotation) {
    return rotations[rotation % rotations.length];
  }

  int get rotationCount => rotations.length;

  // Static factory methods for each tetromino
  static const Tetromino I = Tetromino(
    type: TetrominoType.I,
    color: Color(0xFF00FFFF),
    gradient: LinearGradient(
      colors: [Color(0xFF00FFFF), Color(0xFF0099CC)],
    ),
    glowColor: Color(0xFF00FFFF),
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
  );

  static const Tetromino O = Tetromino(
    type: TetrominoType.O,
    color: Color(0xFFFFFF00),
    gradient: LinearGradient(
      colors: [Color(0xFFFFFF00), Color(0xFFCCCC00)],
    ),
    glowColor: Color(0xFFFFFF00),
    rotations: [
      [
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
    ],
  );

  static const Tetromino T = Tetromino(
    type: TetrominoType.T,
    color: Color(0xFF8B5CF6),
    gradient: LinearGradient(
      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    ),
    glowColor: Color(0xFF8B5CF6),
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
  );

  static const Tetromino S = Tetromino(
    type: TetrominoType.S,
    color: Color(0xFF00FF00),
    gradient: LinearGradient(
      colors: [Color(0xFF00FF00), Color(0xFF00CC00)],
    ),
    glowColor: Color(0xFF00FF00),
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
  );

  static const Tetromino Z = Tetromino(
    type: TetrominoType.Z,
    color: Color(0xFFFF0000),
    gradient: LinearGradient(
      colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
    ),
    glowColor: Color(0xFFFF0000),
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
  );

  static const Tetromino J = Tetromino(
    type: TetrominoType.J,
    color: Color(0xFF0000FF),
    gradient: LinearGradient(
      colors: [Color(0xFF0000FF), Color(0xFF0000CC)],
    ),
    glowColor: Color(0xFF0000FF),
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
  );

  static const Tetromino L = Tetromino(
    type: TetrominoType.L,
    color: Color(0xFFFF8000),
    gradient: LinearGradient(
      colors: [Color(0xFFFF8000), Color(0xFFCC6600)],
    ),
    glowColor: Color(0xFFFF8000),
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
  );

  // Get all tetrominoes
  static const List<Tetromino> all = [I, O, T, S, Z, J, L];

  // Get random tetromino
  static Tetromino getRandom() {
    final random = math.Random();
    return all[random.nextInt(all.length)];
  }
}

// Active piece on the board
class ActivePiece {
  final Tetromino tetromino;
  Position position;
  int rotation;

  ActivePiece({
    required this.tetromino,
    required this.position,
    this.rotation = 0,
  });

  // Move the piece
  void move(int deltaRow, int deltaCol) {
    position = Position(position.row + deltaRow, position.col + deltaCol);
  }

  // Rotate the piece
  void rotate() {
    rotation = (rotation + 1) % tetromino.rotationCount;
  }

  // Get all positions occupied by this piece
  List<Position> getOccupiedPositions() {
    final positions = <Position>[];
    final shape = tetromino.getShape(rotation);

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          positions.add(Position(
            position.row + row,
            position.col + col,
          ));
        }
      }
    }

    return positions;
  }

  // Create a copy with different properties
  ActivePiece copyWith({
    Tetromino? tetromino,
    Position? position,
    int? rotation,
  }) {
    return ActivePiece(
      tetromino: tetromino ?? this.tetromino,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
    );
  }
}

// Board cell data
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

// Game statistics model
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

// Game configuration constants
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

// Line clear animation data model
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

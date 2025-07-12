import 'package:flutter/foundation.dart';

/// Enum for game state
enum NeonRunnerGameState {
  waiting,
  playing,
  gameOver,
}

/// Represents an obstacle in the game
@immutable
class Obstacle {
  final double x;
  final double y;
  final double width;
  final double height;
  final ObstacleType type;

  const Obstacle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
  });

  /// Create a copy with modified values
  Obstacle copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    ObstacleType? type,
  }) {
    return Obstacle(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      type: type ?? this.type,
    );
  }

  /// Check if this obstacle collides with a rectangle
  bool collidesWith(
      double rectX, double rectY, double rectWidth, double rectHeight) {
    return x < rectX + rectWidth &&
        x + width > rectX &&
        y < rectY + rectHeight &&
        y + height > rectY;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Obstacle &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height &&
        other.type == type;
  }

  @override
  int get hashCode =>
      x.hashCode ^
      y.hashCode ^
      width.hashCode ^
      height.hashCode ^
      type.hashCode;
}

/// Types of obstacles
enum ObstacleType {
  cactus,
  rock,
  spike,
}

/// Represents a cloud in the background
@immutable
class Cloud {
  final double x;
  final double y;
  final double size;
  final double speed;

  const Cloud({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });

  Cloud copyWith({
    double? x,
    double? y,
    double? size,
    double? speed,
  }) {
    return Cloud(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      speed: speed ?? this.speed,
    );
  }
}

/// Represents the player character
@immutable
class Player {
  final double x;
  final double y;
  final double width;
  final double height;
  final double velocityY;
  final bool isJumping;
  final bool isDucking;

  const Player({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.velocityY,
    required this.isJumping,
    required this.isDucking,
  });

  Player copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? velocityY,
    bool? isJumping,
    bool? isDucking,
  }) {
    return Player(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      velocityY: velocityY ?? this.velocityY,
      isJumping: isJumping ?? this.isJumping,
      isDucking: isDucking ?? this.isDucking,
    );
  }
}

/// Main game state for the endless runner
@immutable
class NeonRunnerState {
  final Player player;
  final List<Obstacle> obstacles;
  final List<Cloud> clouds;
  final NeonRunnerGameState gameState;
  final int score;
  final int highScore;
  final double gameSpeed;
  final double groundY;
  final double gameWidth;
  final double gameHeight;
  final bool faceExpression; // Add this property to toggle face expressions

  const NeonRunnerState({
    required this.player,
    required this.obstacles,
    required this.clouds,
    required this.gameState,
    required this.score,
    required this.highScore,
    required this.gameSpeed,
    required this.groundY,
    required this.gameWidth,
    required this.gameHeight,
    this.faceExpression = false, // Initialize with default value
  });

  /// Create initial game state
  factory NeonRunnerState.initial({
    required double gameWidth,
    required double gameHeight,
    int highScore = 0,
  }) {
    final groundY = gameHeight * 0.8;
    const playerWidth = 40.0;
    const playerHeight = 60.0;

    return NeonRunnerState(
      player: Player(
        x: gameWidth * 0.1,
        y: groundY - playerHeight,
        width: playerWidth,
        height: playerHeight,
        velocityY: 0,
        isJumping: false,
        isDucking: false,
      ),
      obstacles: const [],
      clouds: const [],
      gameState: NeonRunnerGameState.waiting,
      score: 0,
      highScore: highScore,
      gameSpeed: 200.0,
      groundY: groundY,
      gameWidth: gameWidth,
      gameHeight: gameHeight,
      faceExpression: false, // Initialize with default value
    );
  }

  /// Create a copy with modified values
  NeonRunnerState copyWith({
    Player? player,
    List<Obstacle>? obstacles,
    List<Cloud>? clouds,
    NeonRunnerGameState? gameState,
    int? score,
    int? highScore,
    double? gameSpeed,
    double? groundY,
    double? gameWidth,
    double? gameHeight,
    bool? faceExpression, // Add this parameter to copyWith
  }) {
    return NeonRunnerState(
      player: player ?? this.player,
      obstacles: obstacles ?? this.obstacles,
      clouds: clouds ?? this.clouds,
      gameState: gameState ?? this.gameState,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      gameSpeed: gameSpeed ?? this.gameSpeed,
      groundY: groundY ?? this.groundY,
      gameWidth: gameWidth ?? this.gameWidth,
      gameHeight: gameHeight ?? this.gameHeight,
      faceExpression:
          faceExpression ?? this.faceExpression, // Copy the faceExpression
    );
  }

  /// Check if player is on ground
  bool get isPlayerOnGround => player.y >= groundY - player.height;

  /// Check if game is over
  bool get isGameOver => gameState == NeonRunnerGameState.gameOver;

  /// Check if game is playing
  bool get isPlaying => gameState == NeonRunnerGameState.playing;

  /// Check if game is waiting to start
  bool get isWaiting => gameState == NeonRunnerGameState.waiting;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NeonRunnerState &&
        other.player == player &&
        listEquals(other.obstacles, obstacles) &&
        listEquals(other.clouds, clouds) &&
        other.gameState == gameState &&
        other.score == score &&
        other.highScore == highScore &&
        other.gameSpeed == gameSpeed &&
        other.groundY == groundY &&
        other.gameWidth == gameWidth &&
        other.gameHeight == gameHeight &&
        other.faceExpression ==
            faceExpression; // Add faceExpression to equality check
  }

  @override
  int get hashCode =>
      player.hashCode ^
      obstacles.hashCode ^
      clouds.hashCode ^
      gameState.hashCode ^
      score.hashCode ^
      highScore.hashCode ^
      gameSpeed.hashCode ^
      groundY.hashCode ^
      gameWidth.hashCode ^
      gameHeight.hashCode ^
      faceExpression.hashCode; // Add faceExpression to hashCode
}

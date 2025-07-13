import 'package:flutter/foundation.dart';

/// Neon Runner Models - Data Structures
///
/// This file contains all the data models for the Neon Runner game.
/// These models represent the game state and entities without any business logic.
///
/// **MVC Architecture:**
/// - Models: Game state and entity data structures (this file)
/// - Views: User interface and presentation logic (views/)
/// - Controllers: Game logic and state management (controllers/)

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cloud &&
        other.x == x &&
        other.y == y &&
        other.size == size &&
        other.speed == speed;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ size.hashCode ^ speed.hashCode;
}

/// Represents a star in the background
@immutable
class Star {
  final double x;
  final double y;
  final double size;
  final double brightness;

  const Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
  });

  Star copyWith({
    double? x,
    double? y,
    double? size,
    double? brightness,
  }) {
    return Star(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Star &&
        other.x == x &&
        other.y == y &&
        other.size == size &&
        other.brightness == brightness;
  }

  @override
  int get hashCode =>
      x.hashCode ^ y.hashCode ^ size.hashCode ^ brightness.hashCode;
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
  final bool isRunning;

  const Player({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.velocityY,
    required this.isJumping,
    required this.isDucking,
    required this.isRunning,
  });

  Player copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? velocityY,
    bool? isJumping,
    bool? isDucking,
    bool? isRunning,
  }) {
    return Player(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      velocityY: velocityY ?? this.velocityY,
      isJumping: isJumping ?? this.isJumping,
      isDucking: isDucking ?? this.isDucking,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height &&
        other.velocityY == velocityY &&
        other.isJumping == isJumping &&
        other.isDucking == isDucking &&
        other.isRunning == isRunning;
  }

  @override
  int get hashCode => Object.hash(
        x,
        y,
        width,
        height,
        velocityY,
        isJumping,
        isDucking,
        isRunning,
      );
}

/// Represents the complete state of the Neon Runner game
@immutable
class NeonRunnerState {
  final NeonRunnerGameState gameState;
  final Player player;
  final List<Obstacle> obstacles;
  final List<Cloud> clouds;
  final List<Star> stars;
  final double gameSpeed;
  final double gameWidth;
  final double gameHeight;
  final double groundY;
  final int score;
  final int highScore;
  final double distance;
  final bool isPlaying;
  final bool isGameOver;
  final bool isWaiting;

  const NeonRunnerState({
    required this.gameState,
    required this.player,
    required this.obstacles,
    required this.clouds,
    required this.stars,
    required this.gameSpeed,
    required this.gameWidth,
    required this.gameHeight,
    required this.groundY,
    required this.score,
    required this.highScore,
    required this.distance,
    required this.isPlaying,
    required this.isGameOver,
    required this.isWaiting,
  });

  /// Create initial game state
  factory NeonRunnerState.initial({
    required double gameWidth,
    required double gameHeight,
  }) {
    final groundY = gameHeight * 0.8;
    const playerHeight = 40.0;
    const playerWidth = 30.0;
    final playerX = gameWidth * 0.15;
    final playerY = groundY - playerHeight;

    return NeonRunnerState(
      gameState: NeonRunnerGameState.waiting,
      player: Player(
        x: playerX,
        y: playerY,
        width: playerWidth,
        height: playerHeight,
        velocityY: 0.0,
        isJumping: false,
        isDucking: false,
        isRunning: false,
      ),
      obstacles: const [],
      clouds: const [],
      stars: const [],
      gameSpeed: 200.0,
      gameWidth: gameWidth,
      gameHeight: gameHeight,
      groundY: groundY,
      score: 0,
      highScore: 0,
      distance: 0.0,
      isPlaying: false,
      isGameOver: false,
      isWaiting: true,
    );
  }

  /// Create a copy with modified values
  NeonRunnerState copyWith({
    NeonRunnerGameState? gameState,
    Player? player,
    List<Obstacle>? obstacles,
    List<Cloud>? clouds,
    List<Star>? stars,
    double? gameSpeed,
    double? gameWidth,
    double? gameHeight,
    double? groundY,
    int? score,
    int? highScore,
    double? distance,
    bool? isPlaying,
    bool? isGameOver,
    bool? isWaiting,
  }) {
    return NeonRunnerState(
      gameState: gameState ?? this.gameState,
      player: player ?? this.player,
      obstacles: obstacles ?? this.obstacles,
      clouds: clouds ?? this.clouds,
      stars: stars ?? this.stars,
      gameSpeed: gameSpeed ?? this.gameSpeed,
      gameWidth: gameWidth ?? this.gameWidth,
      gameHeight: gameHeight ?? this.gameHeight,
      groundY: groundY ?? this.groundY,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      distance: distance ?? this.distance,
      isPlaying: isPlaying ?? this.isPlaying,
      isGameOver: isGameOver ?? this.isGameOver,
      isWaiting: isWaiting ?? this.isWaiting,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NeonRunnerState &&
        other.gameState == gameState &&
        other.player == player &&
        listEquals(other.obstacles, obstacles) &&
        listEquals(other.clouds, clouds) &&
        listEquals(other.stars, stars) &&
        other.gameSpeed == gameSpeed &&
        other.gameWidth == gameWidth &&
        other.gameHeight == gameHeight &&
        other.groundY == groundY &&
        other.score == score &&
        other.highScore == highScore &&
        other.distance == distance &&
        other.isPlaying == isPlaying &&
        other.isGameOver == isGameOver &&
        other.isWaiting == isWaiting;
  }

  @override
  int get hashCode => Object.hash(
        gameState,
        player,
        obstacles,
        clouds,
        stars,
        gameSpeed,
        gameWidth,
        gameHeight,
        groundY,
        score,
        highScore,
        distance,
        isPlaying,
        isGameOver,
        isWaiting,
      );

  @override
  String toString() => 'NeonRunnerState(score: $score, gameState: $gameState)';
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'neon_runner_models.dart';

class NeonRunnerPainter extends CustomPainter {
  final NeonRunnerState gameState;

  // Cache paints for better performance
  late final Paint _backgroundPaint;
  late final Paint _starPaint;
  late final Paint _cloudPaint;
  late final Paint _groundPaint;
  late final Paint _groundGlowPaint;
  late final Paint _gridPaint;
  late final Paint _obstaclePaint;
  late final Paint _obstacleGlowPaint;
  late final Paint _playerPaint;
  late final Paint _playerGlowPaint;
  late final Paint _facePaint;
  late final Paint _trailPaint;

  NeonRunnerPainter({required this.gameState}) {
    _initializePaints();
  }

  void _initializePaints() {
    _backgroundPaint = Paint();
    _starPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.8)
      ..strokeWidth = 2;

    _cloudPaint = Paint()
      ..color = const Color(0xFF2a2a2a).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    _groundPaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    _groundGlowPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    _gridPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.2)
      ..strokeWidth = 1;

    _obstaclePaint = Paint()
      ..color = const Color(0xFFFF0080)
      ..style = PaintingStyle.fill;

    _obstacleGlowPaint = Paint()
      ..color = const Color(0xFFFF0080).withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    _playerPaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.fill;

    _playerGlowPaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    _facePaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    _trailPaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.3)
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient background
    _drawBackground(canvas, size);

    // Draw stars (cached)
    _drawStars(canvas, size);

    // Draw clouds
    _drawClouds(canvas, size);

    // Draw ground
    _drawGround(canvas, size);

    // Draw obstacles
    _drawObstacles(canvas, size);

    // Draw player
    _drawPlayer(canvas, size);

    // Draw UI elements
    _drawUI(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Use cached gradient
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0a0a0a), // Dark night
        Color(0xFF1a1a2e), // Deep purple
        Color(0xFF16213e), // Dark blue
        Color(0xFF0f3460), // Darker blue
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    );

    _backgroundPaint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _backgroundPaint,
    );
  }

  void _drawStars(Canvas canvas, Size size) {
    // Use fixed seed for consistent stars, but only draw visible ones
    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      // Reduced star count
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.5;
      final brightness = random.nextDouble();

      _starPaint.color = Color(0xFFFFFFFF).withOpacity(brightness * 0.8);
      canvas.drawCircle(Offset(x, y), 1, _starPaint);
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    for (Cloud cloud in gameState.clouds) {
      _drawCloud(canvas, cloud);
    }
  }

  void _drawCloud(Canvas canvas, Cloud cloud) {
    // Simplified cloud drawing for performance
    final rect = Rect.fromLTWH(
      cloud.x - cloud.size * 0.5,
      cloud.y - cloud.size * 0.3,
      cloud.size,
      cloud.size * 0.6,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cloud.size * 0.3)),
      _cloudPaint,
    );
  }

  void _drawGround(Canvas canvas, Size size) {
    // Draw glow first
    canvas.drawLine(
      Offset(0, gameState.groundY),
      Offset(size.width, gameState.groundY),
      _groundGlowPaint,
    );

    // Draw main line
    canvas.drawLine(
      Offset(0, gameState.groundY),
      Offset(size.width, gameState.groundY),
      _groundPaint,
    );

    // Draw simplified grid pattern
    _drawGroundGrid(canvas, size);
  }

  void _drawGroundGrid(Canvas canvas, Size size) {
    // Reduced grid density for performance
    // Vertical lines (every 100px instead of 50px)
    for (double x = 0; x <= size.width; x += 100) {
      canvas.drawLine(
        Offset(x, gameState.groundY),
        Offset(x, size.height),
        _gridPaint,
      );
    }

    // Horizontal lines (every 60px instead of 30px)
    for (double y = gameState.groundY; y <= size.height; y += 60) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        _gridPaint,
      );
    }
  }

  void _drawObstacles(Canvas canvas, Size size) {
    for (Obstacle obstacle in gameState.obstacles) {
      _drawObstacle(canvas, obstacle);
    }
  }

  void _drawObstacle(Canvas canvas, Obstacle obstacle) {
    final rect = Rect.fromLTWH(
      obstacle.x,
      obstacle.y,
      obstacle.width,
      obstacle.height,
    );

    // Draw glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      _obstacleGlowPaint,
    );

    // Draw obstacle based on type (simplified)
    switch (obstacle.type) {
      case ObstacleType.cactus:
        _drawSimpleCactus(canvas, obstacle);
        break;
      case ObstacleType.rock:
        _drawSimpleRock(canvas, obstacle);
        break;
      case ObstacleType.spike:
        _drawSimpleSpike(canvas, obstacle);
        break;
    }
  }

  void _drawSimpleCactus(Canvas canvas, Obstacle obstacle) {
    // Simplified cactus - just rectangles
    final mainRect = Rect.fromLTWH(
      obstacle.x + obstacle.width * 0.35,
      obstacle.y,
      obstacle.width * 0.3,
      obstacle.height,
    );
    canvas.drawRect(mainRect, _obstaclePaint);

    // Small arms
    final leftArm = Rect.fromLTWH(
      obstacle.x,
      obstacle.y + obstacle.height * 0.4,
      obstacle.width * 0.35,
      obstacle.height * 0.2,
    );
    canvas.drawRect(leftArm, _obstaclePaint);
  }

  void _drawSimpleRock(Canvas canvas, Obstacle obstacle) {
    final rect = Rect.fromLTWH(
      obstacle.x,
      obstacle.y,
      obstacle.width,
      obstacle.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(obstacle.width * 0.3)),
      _obstaclePaint,
    );
  }

  void _drawSimpleSpike(Canvas canvas, Obstacle obstacle) {
    final path = Path();
    path.moveTo(obstacle.x + obstacle.width / 2, obstacle.y);
    path.lineTo(obstacle.x, obstacle.y + obstacle.height);
    path.lineTo(obstacle.x + obstacle.width, obstacle.y + obstacle.height);
    path.close();
    canvas.drawPath(path, _obstaclePaint);
  }

  void _drawPlayer(Canvas canvas, Size size) {
    final player = gameState.player;

    final bodyRect = Rect.fromLTWH(
      player.x,
      player.y,
      player.width,
      player.height,
    );

    // Draw glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      _playerGlowPaint,
    );

    // Draw body
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      _playerPaint,
    );

    // Draw simple face
    if (player.height > 40) {
      // Only draw face if not ducking too much
      // Eyes
      canvas.drawCircle(
        Offset(player.x + player.width * 0.3, player.y + player.height * 0.3),
        2,
        _facePaint,
      );
      canvas.drawCircle(
        Offset(player.x + player.width * 0.7, player.y + player.height * 0.3),
        2,
        _facePaint,
      );
    }

    // Running animation effect (simplified)
    if (gameState.isPlaying) {
      _drawRunningTrail(canvas, player);
    }
  }

  void _drawRunningTrail(Canvas canvas, Player player) {
    // Simplified trail - just 2 rectangles
    for (int i = 1; i <= 2; i++) {
      final trailRect = Rect.fromLTWH(
        player.x - i * 8,
        player.y,
        player.width * (1 - i * 0.3),
        player.height,
      );

      _trailPaint.color = Color(0xFF00FF00).withOpacity(0.3 / (i + 1));
      canvas.drawRRect(
        RRect.fromRectAndRadius(trailRect, const Radius.circular(8)),
        _trailPaint,
      );
    }
  }

  void _drawUI(Canvas canvas, Size size) {
    // Score
    final scoreText = TextSpan(
      text: 'SCORE: ${gameState.score}',
      style: const TextStyle(
        color: Color(0xFF00FFFF),
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    final scoreTextPainter = TextPainter(
      text: scoreText,
      textDirection: TextDirection.ltr,
    );
    scoreTextPainter.layout();
    scoreTextPainter.paint(canvas, const Offset(20, 20));

    // High score
    final highScoreText = TextSpan(
      text: 'HIGH: ${gameState.highScore}',
      style: const TextStyle(
        color: Color(0xFFFF0080),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    final highScoreTextPainter = TextPainter(
      text: highScoreText,
      textDirection: TextDirection.ltr,
    );
    highScoreTextPainter.layout();
    highScoreTextPainter.paint(canvas, const Offset(20, 45));

    // Game state messages
    if (gameState.isGameOver) {
      _drawGameOverMessage(canvas, size);
    } else if (gameState.isWaiting) {
      _drawStartMessage(canvas, size);
    }
  }

  void _drawGameOverMessage(Canvas canvas, Size size) {
    final gameOverText = TextSpan(
      text: 'GAME OVER',
      style: const TextStyle(
        color: Color(0xFFFF0080),
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    final gameOverTextPainter = TextPainter(
      text: gameOverText,
      textDirection: TextDirection.ltr,
    );
    gameOverTextPainter.layout();

    final offset = Offset(
      (size.width - gameOverTextPainter.width) / 2,
      size.height / 2 - 40,
    );

    gameOverTextPainter.paint(canvas, offset);

    // Restart message
    final restartText = TextSpan(
      text: 'TAP TO RESTART',
      style: const TextStyle(
        color: Color(0xFF00FFFF),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    final restartTextPainter = TextPainter(
      text: restartText,
      textDirection: TextDirection.ltr,
    );
    restartTextPainter.layout();

    final restartOffset = Offset(
      (size.width - restartTextPainter.width) / 2,
      size.height / 2 + 10,
    );

    restartTextPainter.paint(canvas, restartOffset);
  }

  void _drawStartMessage(Canvas canvas, Size size) {
    final startText = TextSpan(
      text: 'NEON RUNNER',
      style: const TextStyle(
        color: Color(0xFF00FFFF),
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    final startTextPainter = TextPainter(
      text: startText,
      textDirection: TextDirection.ltr,
    );
    startTextPainter.layout();

    final offset = Offset(
      (size.width - startTextPainter.width) / 2,
      size.height / 2 - 40,
    );

    startTextPainter.paint(canvas, offset);

    // Instructions
    final instructionsText = TextSpan(
      text: 'TAP TO JUMP • HOLD TO DUCK',
      style: const TextStyle(
        color: Color(0xFFFF0080),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    final instructionsTextPainter = TextPainter(
      text: instructionsText,
      textDirection: TextDirection.ltr,
    );
    instructionsTextPainter.layout();

    final instructionsOffset = Offset(
      (size.width - instructionsTextPainter.width) / 2,
      size.height / 2 + 10,
    );

    instructionsTextPainter.paint(canvas, instructionsOffset);

    // Start message
    final tapText = TextSpan(
      text: 'TAP TO START',
      style: const TextStyle(
        color: Color(0xFF00FF00),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );

    final tapTextPainter = TextPainter(
      text: tapText,
      textDirection: TextDirection.ltr,
    );
    tapTextPainter.layout();

    final tapOffset = Offset(
      (size.width - tapTextPainter.width) / 2,
      size.height / 2 + 40,
    );

    tapTextPainter.paint(canvas, tapOffset);
  }

  @override
  bool shouldRepaint(covariant NeonRunnerPainter oldDelegate) {
    return gameState != oldDelegate.gameState;
  }
}

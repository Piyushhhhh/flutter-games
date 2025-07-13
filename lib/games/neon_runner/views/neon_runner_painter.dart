import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/neon_runner_models.dart';

class NeonRunnerPainter extends CustomPainter {
  final NeonRunnerState gameState;

  // Enhanced paint objects for professional look
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
  late final Paint _uiBackgroundPaint;
  late final Paint _uiAccentPaint;
  late final Paint _particlePaint;

  NeonRunnerPainter({required this.gameState}) {
    _initializePaints();
  }

  void _initializePaints() {
    _backgroundPaint = Paint();
    _starPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.9)
      ..strokeWidth = 2;

    _cloudPaint = Paint()
      ..color = const Color(0xFF2D1B69).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    _groundPaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    _groundGlowPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.4)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    _gridPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.15)
      ..strokeWidth = 1.5;

    _obstaclePaint = Paint()
      ..color = const Color(0xFFFF0080)
      ..style = PaintingStyle.fill;

    _obstacleGlowPaint = Paint()
      ..color = const Color(0xFFFF0080).withOpacity(0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    _playerPaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.fill;

    _playerGlowPaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    _facePaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    _trailPaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    _uiBackgroundPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    _uiAccentPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _particlePaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.6)
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw enhanced background
    _drawEnhancedBackground(canvas, size);

    // Draw enhanced stars
    _drawEnhancedStars(canvas, size);

    // Draw enhanced clouds
    _drawEnhancedClouds(canvas, size);

    // Draw enhanced ground
    _drawEnhancedGround(canvas, size);

    // Draw enhanced obstacles
    _drawEnhancedObstacles(canvas, size);

    // Draw enhanced player
    _drawEnhancedPlayer(canvas, size);

    // Draw professional UI
    _drawProfessionalUI(canvas, size);
  }

  void _drawEnhancedBackground(Canvas canvas, Size size) {
    // Multi-layered gradient background
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0D001A), // Deep space purple
        Color(0xFF1A0033), // Rich purple
        Color(0xFF2D1B69), // Electric purple
        Color(0xFF0F0F23), // Dark blue
        Color(0xFF000000), // Pure black
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    _backgroundPaint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _backgroundPaint,
    );

    // Add subtle radial gradient overlay
    final radialGradient = RadialGradient(
      center: const Alignment(0.0, -0.3),
      radius: 1.5,
      colors: [
        const Color(0xFF2D1B69).withOpacity(0.2),
        Colors.transparent,
      ],
    );

    final radialPaint = Paint()
      ..shader = radialGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radialPaint,
    );
  }

  void _drawEnhancedStars(Canvas canvas, Size size) {
    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6;
      final brightness = random.nextDouble();
      final starSize = random.nextDouble() * 2 + 1;

      _starPaint.color = Color.lerp(
        const Color(0xFF00FFFF),
        const Color(0xFFFFFFFF),
        brightness,
      )!
          .withOpacity(brightness * 0.9);

      // Draw star with glow effect
      canvas.drawCircle(
        Offset(x, y),
        starSize * 2,
        Paint()
          ..color = _starPaint.color.withOpacity(0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      canvas.drawCircle(Offset(x, y), starSize, _starPaint);
    }
  }

  void _drawEnhancedClouds(Canvas canvas, Size size) {
    for (Cloud cloud in gameState.clouds) {
      _drawEnhancedCloud(canvas, cloud);
    }
  }

  void _drawEnhancedCloud(Canvas canvas, Cloud cloud) {
    // Multi-layered cloud with depth
    final cloudPaint = Paint()
      ..color = const Color(0xFF2D1B69).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final cloudGlowPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.05)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        cloud.x - cloud.size * 0.5,
        cloud.y - cloud.size * 0.3,
        cloud.size,
        cloud.size * 0.6,
      ),
      Radius.circular(cloud.size * 0.3),
    );

    canvas.drawRRect(rect, cloudGlowPaint);
    canvas.drawRRect(rect, cloudPaint);
  }

  void _drawEnhancedGround(Canvas canvas, Size size) {
    // Multi-layered ground with depth
    final groundGlow2 = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // Draw multiple glow layers
    canvas.drawLine(
      Offset(0, gameState.groundY),
      Offset(size.width, gameState.groundY),
      groundGlow2,
    );

    canvas.drawLine(
      Offset(0, gameState.groundY),
      Offset(size.width, gameState.groundY),
      _groundGlowPaint,
    );

    canvas.drawLine(
      Offset(0, gameState.groundY),
      Offset(size.width, gameState.groundY),
      _groundPaint,
    );

    // Enhanced grid pattern
    _drawEnhancedGrid(canvas, size);
  }

  void _drawEnhancedGrid(Canvas canvas, Size size) {
    // Perspective grid lines
    const double gridSize = 80;
    final gridPaint1 = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.08)
      ..strokeWidth = 1;

    final gridPaint2 = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.15)
      ..strokeWidth = 2;

    // Major grid lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, gameState.groundY),
        Offset(x, size.height),
        x % (gridSize * 2) == 0 ? gridPaint2 : gridPaint1,
      );
    }

    for (double y = gameState.groundY; y <= size.height; y += gridSize * 0.8) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint1,
      );
    }
  }

  void _drawEnhancedObstacles(Canvas canvas, Size size) {
    for (Obstacle obstacle in gameState.obstacles) {
      _drawEnhancedObstacle(canvas, obstacle);
    }
  }

  void _drawEnhancedObstacle(Canvas canvas, Obstacle obstacle) {
    // Enhanced obstacle with multiple layers
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        obstacle.x,
        obstacle.y,
        obstacle.width,
        obstacle.height,
      ),
      const Radius.circular(6),
    );

    // Draw glow layers
    canvas.drawRRect(rect, _obstacleGlowPaint);

    // Draw main obstacle
    canvas.drawRRect(rect, _obstaclePaint);

    // Add accent line
    final accentPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rect, accentPaint);

    // Add type-specific details
    switch (obstacle.type) {
      case ObstacleType.cactus:
        _drawCactusDetails(canvas, obstacle);
        break;
      case ObstacleType.rock:
        _drawRockDetails(canvas, obstacle);
        break;
      case ObstacleType.spike:
        _drawSpikeDetails(canvas, obstacle);
        break;
    }
  }

  void _drawCactusDetails(Canvas canvas, Obstacle obstacle) {
    final detailPaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw cactus spikes
    for (int i = 0; i < 3; i++) {
      final spikeRect = Rect.fromLTWH(
        obstacle.x + i * (obstacle.width / 3),
        obstacle.y + obstacle.height * 0.2,
        obstacle.width / 6,
        obstacle.height * 0.1,
      );
      canvas.drawRect(spikeRect, detailPaint);
    }
  }

  void _drawRockDetails(Canvas canvas, Obstacle obstacle) {
    final detailPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Draw rock texture
    final centerX = obstacle.x + obstacle.width / 2;
    final centerY = obstacle.y + obstacle.height / 2;

    canvas.drawCircle(
      Offset(centerX - 5, centerY - 5),
      3,
      detailPaint,
    );
    canvas.drawCircle(
      Offset(centerX + 3, centerY + 2),
      2,
      detailPaint,
    );
  }

  void _drawSpikeDetails(Canvas canvas, Obstacle obstacle) {
    final detailPaint = Paint()
      ..color = const Color(0xFFFFFF00).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Draw danger glow
    canvas.drawRect(
      Rect.fromLTWH(
        obstacle.x,
        obstacle.y,
        obstacle.width,
        obstacle.height,
      ),
      Paint()
        ..color = const Color(0xFFFFFF00).withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _drawEnhancedPlayer(Canvas canvas, Size size) {
    final player = gameState.player;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        player.x,
        player.y,
        player.width,
        player.height,
      ),
      const Radius.circular(12),
    );

    // Draw multiple glow layers
    canvas.drawRRect(bodyRect, _playerGlowPaint);

    // Draw main body
    canvas.drawRRect(bodyRect, _playerPaint);

    // Add highlight
    final highlightPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          player.x + 2,
          player.y + 2,
          player.width - 4,
          player.height * 0.3,
        ),
        const Radius.circular(8),
      ),
      highlightPaint,
    );

    // Draw face on the player
    _drawFace(
        canvas,
        Offset(player.x + player.width / 2, player.y + player.height / 2),
        player.width);

    // Enhanced running trail
    if (gameState.isPlaying) {
      _drawEnhancedTrail(canvas, player);
    }
  }

  void _drawEnhancedFace(Canvas canvas, Player player) {
    // Animated eyes
    final eyeSize = player.isDucking ? 1.5 : 2.5;
    final eyeY = player.y + player.height * 0.25;

    // Eye glow
    canvas.drawCircle(
      Offset(player.x + player.width * 0.3, eyeY),
      eyeSize + 1,
      Paint()
        ..color = const Color(0xFF00FFFF).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      Offset(player.x + player.width * 0.7, eyeY),
      eyeSize + 1,
      Paint()
        ..color = const Color(0xFF00FFFF).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Eyes
    canvas.drawCircle(
      Offset(player.x + player.width * 0.3, eyeY),
      eyeSize,
      Paint()..color = const Color(0xFF00FFFF),
    );
    canvas.drawCircle(
      Offset(player.x + player.width * 0.7, eyeY),
      eyeSize,
      Paint()..color = const Color(0xFF00FFFF),
    );
  }

  void _drawEnhancedTrail(Canvas canvas, Player player) {
    // Multi-layered trail effect
    for (int i = 1; i <= 4; i++) {
      final trailRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          player.x - i * 12,
          player.y + i * 2,
          player.width * (1 - i * 0.15),
          player.height * (1 - i * 0.1),
        ),
        const Radius.circular(8),
      );

      final trailPaint = Paint()
        ..color = const Color(0xFF00FF00).withOpacity(0.4 / (i + 1))
        ..style = PaintingStyle.fill;

      canvas.drawRRect(trailRect, trailPaint);
    }
  }

  void _drawProfessionalUI(Canvas canvas, Size size) {
    // Draw enhanced score UI
    _drawEnhancedScore(canvas, size);

    // Draw game state messages
    if (gameState.isGameOver) {
      _drawProfessionalGameOver(canvas, size);
    } else if (gameState.isWaiting) {
      _drawProfessionalStart(canvas, size);
    }
  }

  void _drawEnhancedScore(Canvas canvas, Size size) {
    // Professional dual-panel score display
    final panelWidth = size.width - 120; // Reduced width to avoid back button
    const panelHeight = 90.0;
    const safeAreaTop = 60.0; // Account for notch/status bar
    const panelLeft = 100.0; // Start after back button (56px + margin)

    // Main score panel
    final scorePanel = RRect.fromRectAndRadius(
      Rect.fromLTWH(panelLeft, safeAreaTop, panelWidth, panelHeight),
      const Radius.circular(20),
    );

    // Premium gradient background
    final panelGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0D001A).withOpacity(0.95),
        const Color(0xFF1A0033).withOpacity(0.85),
        const Color(0xFF2D1B69).withOpacity(0.75),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    canvas.drawRRect(
      scorePanel,
      Paint()
        ..shader = panelGradient.createShader(scorePanel.outerRect)
        ..style = PaintingStyle.fill,
    );

    // Multi-layer glow effect
    for (int i = 3; i >= 1; i--) {
      canvas.drawRRect(
        scorePanel,
        Paint()
          ..color = const Color(0xFF00FFFF).withOpacity(0.1 * i)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, i * 4.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Premium border with gradient
    canvas.drawRRect(
      scorePanel,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00FFFF).withOpacity(0.8),
            const Color(0xFFFF0080).withOpacity(0.6),
            const Color(0xFF00FFFF).withOpacity(0.8),
          ],
        ).createShader(scorePanel.outerRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Left section - Current Score (properly centered)
    final leftSection = Rect.fromLTWH(
        panelLeft + 20,
        safeAreaTop + 15,
        (panelWidth * 0.45) - 15, // Slightly less width to account for padding
        60);

    _drawStyledText(
      canvas,
      'SCORE',
      Offset(leftSection.center.dx, leftSection.top + 12),
      const TextStyle(
        color: Color(0xFF00FFFF),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );

    _drawGlowText(
      canvas,
      '${gameState.score}',
      Offset(leftSection.center.dx, leftSection.top + 38),
      const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 24,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
      glowColor: const Color(0xFF00FFFF),
    );

    // Vertical divider (centered)
    final dividerX = panelLeft + (panelWidth * 0.5);
    canvas.drawLine(
      Offset(dividerX, safeAreaTop + 20),
      Offset(dividerX, safeAreaTop + panelHeight - 20),
      Paint()
        ..color = const Color(0xFF00FFFF).withOpacity(0.3)
        ..strokeWidth = 1.5,
    );

    // Right section - Best Score (properly centered)
    final rightSection = Rect.fromLTWH(
        dividerX + 15,
        safeAreaTop + 15,
        (panelWidth * 0.45) - 15, // Balanced width with left section
        60);

    _drawStyledText(
      canvas,
      'BEST',
      Offset(rightSection.center.dx, rightSection.top + 12),
      const TextStyle(
        color: Color(0xFFFF0080),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );

    _drawGlowText(
      canvas,
      '${gameState.highScore}',
      Offset(rightSection.center.dx, rightSection.top + 38),
      const TextStyle(
        color: Color(0xFFFF0080),
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
      glowColor: const Color(0xFFFF0080),
    );

    // Add subtle corner accents
    _drawCornerAccents(canvas, scorePanel);
  }

  void _drawProfessionalGameOver(Canvas canvas, Size size) {
    // Enhanced full screen overlay with blur effect
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            const Color(0xFF000000).withOpacity(0.4),
            const Color(0xFF000000).withOpacity(0.8),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Retro arcade particle explosion effect
    _drawArcadeExplosion(canvas, size);

    // Modern compact dialog with better padding
    final dialogWidth =
        size.width * 0.8; // Reduced from 0.85 for better margins
    const dialogHeight = 320.0; // Increased height for better spacing
    final dialogRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (size.width - dialogWidth) / 2,
        (size.height - dialogHeight) / 2,
        dialogWidth,
        dialogHeight,
      ),
      const Radius.circular(20),
    );

    // Dialog shadow layers
    for (int i = 3; i >= 1; i--) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (size.width - dialogWidth) / 2 + i * 2,
            (size.height - dialogHeight) / 2 + i * 2,
            dialogWidth,
            dialogHeight,
          ),
          const Radius.circular(20),
        ),
        Paint()
          ..color = const Color(0xFF000000).withOpacity(0.3 / i)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, i * 8.0),
      );
    }

    // Dialog background with sophisticated gradient
    final dialogGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0D001A).withOpacity(0.98),
        const Color(0xFF1A0033).withOpacity(0.95),
        const Color(0xFF2D1B69).withOpacity(0.92),
        const Color(0xFF0F0F23).withOpacity(0.95),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    canvas.drawRRect(
      dialogRect,
      Paint()
        ..shader = dialogGradient.createShader(dialogRect.outerRect)
        ..style = PaintingStyle.fill,
    );

    // Multiple glow layers for premium feel
    for (int i = 3; i >= 1; i--) {
      canvas.drawRRect(
        dialogRect,
        Paint()
          ..color = const Color(0xFF00FFFF).withOpacity(0.1 * i)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, i * 6.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Dialog border with gradient
    canvas.drawRRect(
      dialogRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00FFFF).withOpacity(0.8),
            const Color(0xFFFF0080).withOpacity(0.6),
            const Color(0xFF00FFFF).withOpacity(0.8),
          ],
        ).createShader(dialogRect.outerRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Animated bouncing skull icon with more space
    _drawAnimatedGameOverIcon(canvas, Offset(centerX, centerY - 100), 32);

    // Animated glitch title effect with better spacing
    _drawAnimatedGameOverTitle(canvas, Offset(centerX, centerY - 50));

    // Score section with improved vertical spacing
    _drawStyledText(
      canvas,
      'FINAL SCORE',
      Offset(centerX, centerY - 5),
      const TextStyle(
        color: Color(0xFF00FFFF),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );

    // Animated score counter effect with proper spacing
    _drawAnimatedScore(
      canvas,
      '${gameState.score}',
      Offset(centerX, centerY + 25),
    );

    // High score achievement with better spacing
    if (gameState.score == gameState.highScore && gameState.score > 0) {
      _drawGlowText(
        canvas,
        '★ NEW HIGH SCORE ★',
        Offset(centerX, centerY + 65),
        const TextStyle(
          color: Color(0xFFFFFF00),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
        glowColor: const Color(0xFFFFFF00),
      );
    } else {
      _drawStyledText(
        canvas,
        'BEST: ${gameState.highScore}',
        Offset(centerX, centerY + 65),
        const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      );
    }

    // Animated action button with more bottom padding
    _drawAnimatedActionButton(
      canvas,
      Offset(centerX, centerY + 110),
      'TAP TO RESTART',
      const Color(0xFF00FF00),
    );
  }

  void _drawProfessionalStart(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Title with enhanced glow
    _drawGlowText(
      canvas,
      'NEON RUNNER',
      Offset(centerX, centerY - 80),
      const TextStyle(
        color: Color(0xFF00FFFF),
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
      ),
      glowColor: const Color(0xFF00FFFF),
    );

    // Subtitle
    _drawStyledText(
      canvas,
      'CYBERPUNK ENDLESS RUNNER',
      Offset(centerX, centerY - 40),
      const TextStyle(
        color: Color(0xFFFF0080),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );

    // Instructions
    _drawStyledText(
      canvas,
      'TAP TO JUMP • HOLD TO DUCK',
      Offset(centerX, centerY + 10),
      const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
      ),
    );

    // Start instruction
    _drawGlowText(
      canvas,
      'TAP TO START',
      Offset(centerX, centerY + 50),
      const TextStyle(
        color: Color(0xFF00FF00),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
      glowColor: const Color(0xFF00FF00),
    );
  }

  void _drawStyledText(
      Canvas canvas, String text, Offset offset, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    final centeredOffset = Offset(
      offset.dx - textPainter.width / 2,
      offset.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, centeredOffset);
  }

  void _drawGlowText(Canvas canvas, String text, Offset offset, TextStyle style,
      {required Color glowColor}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    final centeredOffset = Offset(
      offset.dx - textPainter.width / 2,
      offset.dy - textPainter.height / 2,
    );

    // Draw glow layers
    for (int i = 3; i > 0; i--) {
      final glowPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: style.copyWith(
            foreground: Paint()
              ..color = glowColor.withOpacity(0.3)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, i * 4.0),
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      glowPainter.layout();
      glowPainter.paint(canvas, centeredOffset);
    }

    // Draw main text
    textPainter.paint(canvas, centeredOffset);
  }

  void _drawGameOverIcon(Canvas canvas, Offset center, double size) {
    // Draw skull icon for game over
    final iconPaint = Paint()
      ..color = const Color(0xFFFF0080)
      ..style = PaintingStyle.fill;

    final iconGlowPaint = Paint()
      ..color = const Color(0xFFFF0080).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.fill;

    // Draw glow
    canvas.drawCircle(center, size * 0.8, iconGlowPaint);

    // Draw main skull shape
    canvas.drawCircle(center, size * 0.6, iconPaint);

    // Draw X eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Left eye X
    canvas.drawLine(
      Offset(center.dx - size * 0.2, center.dy - size * 0.1),
      Offset(center.dx - size * 0.05, center.dy + size * 0.05),
      eyePaint,
    );
    canvas.drawLine(
      Offset(center.dx - size * 0.05, center.dy - size * 0.1),
      Offset(center.dx - size * 0.2, center.dy + size * 0.05),
      eyePaint,
    );

    // Right eye X
    canvas.drawLine(
      Offset(center.dx + size * 0.05, center.dy - size * 0.1),
      Offset(center.dx + size * 0.2, center.dy + size * 0.05),
      eyePaint,
    );
    canvas.drawLine(
      Offset(center.dx + size * 0.2, center.dy - size * 0.1),
      Offset(center.dx + size * 0.05, center.dy + size * 0.05),
      eyePaint,
    );
  }

  void _drawActionButton(
      Canvas canvas, Offset center, String text, Color color) {
    // Button background
    const buttonWidth = 200.0;
    const buttonHeight = 50.0;
    final buttonRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx - buttonWidth / 2,
        center.dy - buttonHeight / 2,
        buttonWidth,
        buttonHeight,
      ),
      const Radius.circular(25),
    );

    // Button gradient
    final buttonGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.2),
        color.withOpacity(0.1),
      ],
    );

    canvas.drawRRect(
      buttonRect,
      Paint()
        ..shader = buttonGradient.createShader(buttonRect.outerRect)
        ..style = PaintingStyle.fill,
    );

    // Button glow
    canvas.drawRRect(
      buttonRect,
      Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Button border
    canvas.drawRRect(
      buttonRect,
      Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Button text
    _drawStyledText(
      canvas,
      text,
      center,
      TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }

  void _drawArcadeExplosion(Canvas canvas, Size size) {
    // Simulate time-based animation using score as pseudo-time
    final animationTime = (gameState.score % 100) / 100.0;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw particle burst effect
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2 / 12) + animationTime * math.pi * 2;
      final distance = 50 + (animationTime * 100);
      final particleX = centerX + math.cos(angle) * distance;
      final particleY = centerY + math.sin(angle) * distance;

      final particleSize = (3 - animationTime * 2).clamp(0.5, 3.0);
      final opacity = (1 - animationTime).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(particleX, particleY),
        particleSize,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFFF0080),
            const Color(0xFFFFFF00),
            i / 12.0,
          )!
              .withOpacity(opacity * 0.6),
      );
    }

    // Lightning bolt effects
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final distance = 80 + animationTime * 50;
      final startX = centerX + math.cos(angle) * 30;
      final startY = centerY + math.sin(angle) * 30;
      final endX = centerX + math.cos(angle) * distance;
      final endY = centerY + math.sin(angle) * distance;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        Paint()
          ..color =
              const Color(0xFF00FFFF).withOpacity((1 - animationTime) * 0.8)
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  void _drawAnimatedGameOverIcon(Canvas canvas, Offset center, double size) {
    // Bouncing animation using game state
    final bounce = math.sin((gameState.score % 60) / 60.0 * math.pi * 4) * 5;
    final animatedCenter = Offset(center.dx, center.dy + bounce);

    // Rotating animation
    final rotation = (gameState.score % 120) / 120.0 * math.pi * 2;

    canvas.save();
    canvas.translate(animatedCenter.dx, animatedCenter.dy);
    canvas.rotate(rotation * 0.1); // Slow rotation
    canvas.translate(-animatedCenter.dx, -animatedCenter.dy);

    // Draw skull with enhanced glow for animation
    final iconPaint = Paint()
      ..color = const Color(0xFFFF0080)
      ..style = PaintingStyle.fill;

    final iconGlowPaint = Paint()
      ..color = const Color(0xFFFF0080).withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.fill;

    // Draw glow
    canvas.drawCircle(animatedCenter, size * 1.2, iconGlowPaint);

    // Draw main skull shape
    canvas.drawCircle(animatedCenter, size * 0.6, iconPaint);

    // Draw X eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Animated X eyes
    final eyeOffset = math.sin(rotation * 2) * 2;

    // Left eye X
    canvas.drawLine(
      Offset(animatedCenter.dx - size * 0.2 + eyeOffset,
          animatedCenter.dy - size * 0.1),
      Offset(animatedCenter.dx - size * 0.05 + eyeOffset,
          animatedCenter.dy + size * 0.05),
      eyePaint,
    );
    canvas.drawLine(
      Offset(animatedCenter.dx - size * 0.05 + eyeOffset,
          animatedCenter.dy - size * 0.1),
      Offset(animatedCenter.dx - size * 0.2 + eyeOffset,
          animatedCenter.dy + size * 0.05),
      eyePaint,
    );

    // Right eye X
    canvas.drawLine(
      Offset(animatedCenter.dx + size * 0.05 - eyeOffset,
          animatedCenter.dy - size * 0.1),
      Offset(animatedCenter.dx + size * 0.2 - eyeOffset,
          animatedCenter.dy + size * 0.05),
      eyePaint,
    );
    canvas.drawLine(
      Offset(animatedCenter.dx + size * 0.2 - eyeOffset,
          animatedCenter.dy - size * 0.1),
      Offset(animatedCenter.dx + size * 0.05 - eyeOffset,
          animatedCenter.dy + size * 0.05),
      eyePaint,
    );

    canvas.restore();
  }

  void _drawAnimatedGameOverTitle(Canvas canvas, Offset offset) {
    // Glitch effect animation
    final glitchTime = (gameState.score % 30) / 30.0;
    final glitchOffset = math.sin(glitchTime * math.pi * 8) * 3;

    // Draw multiple offset versions for glitch effect
    for (int i = 0; i < 3; i++) {
      final glitchColor = [
        const Color(0xFFFF0080),
        const Color(0xFF00FFFF),
        const Color(0xFFFFFF00),
      ][i];

      _drawGlowText(
        canvas,
        'GAME OVER',
        Offset(offset.dx + (i - 1) * glitchOffset, offset.dy + (i - 1) * 2),
        TextStyle(
          color: glitchColor.withOpacity(0.8 - i * 0.2),
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
        ),
        glowColor: glitchColor,
      );
    }

    // Main text on top
    _drawGlowText(
      canvas,
      'GAME OVER',
      offset,
      const TextStyle(
        color: Color(0xFFFF0080),
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
      glowColor: const Color(0xFFFF0080),
    );
  }

  void _drawAnimatedScore(Canvas canvas, String score, Offset offset) {
    // Pulsing scale animation
    final pulse =
        1.0 + math.sin((gameState.score % 40) / 40.0 * math.pi * 2) * 0.1;

    // Color cycling animation
    final colorTime = (gameState.score % 180) / 180.0;
    final animatedColor = Color.lerp(
      const Color(0xFFFFFFFF),
      const Color(0xFF00FFFF),
      (math.sin(colorTime * math.pi * 2) + 1) / 2,
    )!;

    _drawGlowText(
      canvas,
      score,
      offset,
      TextStyle(
        color: animatedColor,
        fontSize: 36 * pulse,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
      glowColor: const Color(0xFF00FFFF),
    );
  }

  void _drawAnimatedActionButton(
      Canvas canvas, Offset center, String text, Color color) {
    // Pulsing glow animation
    final pulseTime = (gameState.score % 50) / 50.0;
    final glowIntensity = (math.sin(pulseTime * math.pi * 2) + 1) / 2;

    // Button background
    const buttonWidth = 200.0;
    const buttonHeight = 50.0;
    final buttonRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx - buttonWidth / 2,
        center.dy - buttonHeight / 2,
        buttonWidth,
        buttonHeight,
      ),
      const Radius.circular(25),
    );

    // Animated button gradient
    final buttonGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.2 + glowIntensity * 0.2),
        color.withOpacity(0.1 + glowIntensity * 0.1),
      ],
    );

    canvas.drawRRect(
      buttonRect,
      Paint()
        ..shader = buttonGradient.createShader(buttonRect.outerRect)
        ..style = PaintingStyle.fill,
    );

    // Animated button glow
    canvas.drawRRect(
      buttonRect,
      Paint()
        ..color = color.withOpacity(0.3 + glowIntensity * 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + glowIntensity * 8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Button border
    canvas.drawRRect(
      buttonRect,
      Paint()
        ..color = color.withOpacity(0.6 + glowIntensity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Animated button text
    _drawStyledText(
      canvas,
      text,
      center,
      TextStyle(
        color: color.withOpacity(0.8 + glowIntensity * 0.2),
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }

  void _drawCornerAccents(Canvas canvas, RRect panel) {
    // Add professional corner accent details
    final accentPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.2)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    const cornerLength = 15.0;
    final rect = panel.outerRect;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left + panel.tlRadiusX, rect.top),
      Offset(rect.left + panel.tlRadiusX + cornerLength, rect.top),
      glowPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top + panel.tlRadiusY),
      Offset(rect.left, rect.top + panel.tlRadiusY + cornerLength),
      glowPaint,
    );
    canvas.drawLine(
      Offset(rect.left + panel.tlRadiusX, rect.top),
      Offset(rect.left + panel.tlRadiusX + cornerLength, rect.top),
      accentPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top + panel.tlRadiusY),
      Offset(rect.left, rect.top + panel.tlRadiusY + cornerLength),
      accentPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - panel.trRadiusX - cornerLength, rect.top),
      Offset(rect.right - panel.trRadiusX, rect.top),
      glowPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top + panel.trRadiusY),
      Offset(rect.right, rect.top + panel.trRadiusY + cornerLength),
      glowPaint,
    );
    canvas.drawLine(
      Offset(rect.right - panel.trRadiusX - cornerLength, rect.top),
      Offset(rect.right - panel.trRadiusX, rect.top),
      accentPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top + panel.trRadiusY),
      Offset(rect.right, rect.top + panel.trRadiusY + cornerLength),
      accentPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left + panel.blRadiusX, rect.bottom),
      Offset(rect.left + panel.blRadiusX + cornerLength, rect.bottom),
      glowPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom - panel.blRadiusY - cornerLength),
      Offset(rect.left, rect.bottom - panel.blRadiusY),
      glowPaint,
    );
    canvas.drawLine(
      Offset(rect.left + panel.blRadiusX, rect.bottom),
      Offset(rect.left + panel.blRadiusX + cornerLength, rect.bottom),
      accentPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom - panel.blRadiusY - cornerLength),
      Offset(rect.left, rect.bottom - panel.blRadiusY),
      accentPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - panel.brRadiusX - cornerLength, rect.bottom),
      Offset(rect.right - panel.brRadiusX, rect.bottom),
      glowPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - panel.brRadiusY - cornerLength),
      Offset(rect.right, rect.bottom - panel.brRadiusY),
      glowPaint,
    );
    canvas.drawLine(
      Offset(rect.right - panel.brRadiusX - cornerLength, rect.bottom),
      Offset(rect.right - panel.brRadiusX, rect.bottom),
      accentPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - panel.brRadiusY - cornerLength),
      Offset(rect.right, rect.bottom - panel.brRadiusY),
      accentPaint,
    );
  }

  void _drawFace(Canvas canvas, Offset position, double size) {
    final eyePaint = Paint()..color = Colors.black;
    final eyeSize = size * 0.1;

    // Change eye size based on faceExpression
    final adjustedEyeSize = gameState.faceExpression ? eyeSize * 1.5 : eyeSize;

    // Draw eyes
    canvas.drawCircle(
      Offset(position.dx - size * 0.2, position.dy - size * 0.2),
      adjustedEyeSize,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(position.dx + size * 0.2, position.dy - size * 0.2),
      adjustedEyeSize,
      eyePaint,
    );

    // Draw mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final mouthWidth = size * 0.4;
    final mouthPath = Path()
      ..moveTo(position.dx - mouthWidth / 2, position.dy + size * 0.1)
      ..quadraticBezierTo(
        position.dx,
        position.dy +
            (gameState.faceExpression
                ? size * 0.3
                : size * 0.2), // Change mouth curve based on faceExpression
        position.dx + mouthWidth / 2,
        position.dy + size * 0.1,
      );
    canvas.drawPath(mouthPath, mouthPaint);
  }

  // Modify the existing drawing function to include the face
  void _drawGreenBoxWithFace(Canvas canvas, Offset position, double size) {
    final paint = Paint()..color = Colors.green;
    canvas.drawRect(
      Rect.fromCenter(center: position, width: size, height: size),
      paint,
    );
    _drawFace(canvas, position, size);
  }

  @override
  bool shouldRepaint(covariant NeonRunnerPainter oldDelegate) {
    return gameState != oldDelegate.gameState;
  }
}

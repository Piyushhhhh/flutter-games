/// Neon Runner Game - Complete endless runner implementation
///
/// Features:
/// - Endless runner gameplay similar to Chrome dinosaur game
/// - Neon visual effects and retro aesthetic
/// - Jump and duck mechanics
/// - Obstacle avoidance with collision detection
/// - Progressive difficulty with increasing speed
/// - Score and high score tracking
/// - Touch controls for mobile
/// - Keyboard controls for desktop
///
/// Usage:
/// ```dart
/// import 'package:flutter_games/games/neon_runner/neon_runner.dart';
///
/// // Navigate to the game
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const NeonRunnerScreen()),
/// );
/// ```
library neon_runner;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import '../models/neon_runner_models.dart';
import '../controllers/neon_runner_controller.dart';
import 'neon_runner_painter.dart';

class NeonRunnerScreen extends StatefulWidget {
  const NeonRunnerScreen({super.key});

  @override
  State<NeonRunnerScreen> createState() => _NeonRunnerScreenState();
}

class _NeonRunnerScreenState extends State<NeonRunnerScreen>
    with TickerProviderStateMixin {
  late NeonRunnerController _controller;
  late NeonRunnerState _gameState;
  late Ticker _ticker;
  DateTime _lastFrameTime = DateTime.now();

  // Retro animation controllers
  late AnimationController _neonGlowController;
  late AnimationController _scanlineController;
  late Animation<double> _neonGlowAnimation;
  late Animation<double> _scanlineAnimation;

  // Input handling
  bool _isPressed = false;
  bool _isDuckPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = NeonRunnerController();
    _initializeRetroAnimations();
    _initializeGame();
    _setupGameLoop();

    // Set system UI overlay style for full screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeRetroAnimations() {
    // Neon glow pulse animation
    _neonGlowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _neonGlowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _neonGlowController,
      curve: Curves.easeInOut,
    ));

    // Scanline animation
    _scanlineController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _scanlineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanlineController,
      curve: Curves.linear,
    ));

    // Start animations
    _neonGlowController.repeat(reverse: true);
    _scanlineController.repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _neonGlowController.dispose();
    _scanlineController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    // Initialize game state with screen size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _gameState = NeonRunnerState.initial(
          gameWidth: size.width,
          gameHeight: size.height,
        );
      });
    });

    // Initialize with default size
    _gameState = NeonRunnerState.initial(
      gameWidth: 400,
      gameHeight: 600,
    );
  }

  void _setupGameLoop() {
    _ticker = createTicker(_onTick);
    _lastFrameTime = DateTime.now();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final now = DateTime.now();
    final deltaTime = now.difference(_lastFrameTime).inMilliseconds / 1000.0;
    _lastFrameTime = now;

    // Limit delta time to prevent large jumps (max 33ms = ~30fps minimum)
    final clampedDeltaTime = deltaTime.clamp(0.0, 1.0 / 30.0);

    setState(() {
      _gameState = _controller.updateGame(_gameState, clampedDeltaTime);
    });

    // Continue ticker only if game is playing
    if (!_gameState.isPlaying && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _startGameLoop() {
    if (!_ticker.isActive) {
      _lastFrameTime = DateTime.now();
      _ticker.start();
    }
  }

  void _startGame() {
    setState(() {
      if (_gameState.isGameOver) {
        _gameState = _controller.resetGame(_gameState);
      }
      _gameState = _controller.startGame(_gameState);
    });
    _startGameLoop();
  }

  void _jump() {
    HapticFeedback.lightImpact();
    if (_gameState.isWaiting) {
      _startGame();
    } else if (_gameState.isPlaying) {
      setState(() {
        _gameState = _controller.jump(_gameState);
      });
    } else if (_gameState.isGameOver) {
      _startGame();
    }
  }

  void _startDuck() {
    if (_gameState.isPlaying && !_isDuckPressed) {
      _isDuckPressed = true;
      HapticFeedback.selectionClick();
      setState(() {
        _gameState = _controller.duck(_gameState, true);
      });
    }
  }

  void _stopDuck() {
    if (_isDuckPressed) {
      _isDuckPressed = false;
      setState(() {
        _gameState = _controller.duck(_gameState, false);
      });
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _isPressed = true;

    // Immediate jump response
    _jump();

    // Start duck after short delay if still pressed
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_isPressed && !_isDuckPressed) {
        _startDuck();
      }
    });
  }

  void _handleTapUp() {
    _isPressed = false;
    _stopDuck();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _jump();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _startDuck();
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _stopDuck();
      }
    }
  }

  Widget _buildScanlineOverlay(BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: _scanlineAnimation,
      builder: (context, child) {
        return IgnorePointer(
          child: SizedBox.expand(
            child: CustomPaint(
              painter: _RetroScanlinePainter(
                progress: _scanlineAnimation.value,
                glowIntensity: _neonGlowAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: AnimatedBuilder(
        animation: _neonGlowAnimation,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0D001A).withOpacity(0.95),
                    const Color(0xFF2D1B69).withOpacity(0.85),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00FFFF)
                      .withOpacity(_neonGlowAnimation.value * 0.8),
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFFF)
                        .withOpacity(_neonGlowAnimation.value * 0.4),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: const Color(0xFF00FFFF)
                        .withOpacity(_neonGlowAnimation.value * 0.2),
                    blurRadius: 35,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner glow effect
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FFFF)
                          .withOpacity(_neonGlowAnimation.value * 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  // Icon with enhanced styling
                  Icon(
                    Icons.arrow_back_ios,
                    color: const Color(0xFF00FFFF)
                        .withOpacity(_neonGlowAnimation.value),
                    size: 22,
                  ),
                  // Subtle highlight
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF)
                            .withOpacity(_neonGlowAnimation.value * 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      extendBodyBehindAppBar: true,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Update game state with actual screen dimensions
            if (_gameState.gameWidth != constraints.maxWidth ||
                _gameState.gameHeight != constraints.maxHeight) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _gameState = _gameState.copyWith(
                    gameWidth: constraints.maxWidth,
                    gameHeight: constraints.maxHeight,
                  );
                });
              });
            }

            return Stack(
              children: [
                // Main game area
                GestureDetector(
                  onTapDown: _handleTapDown,
                  onTapUp: (_) => _handleTapUp(),
                  onTapCancel: _handleTapUp,
                  // Add pan gestures for better touch response
                  onPanDown: (details) => _handleTapDown(
                      TapDownDetails(globalPosition: details.globalPosition)),
                  onPanEnd: (details) => _handleTapUp(),
                  onPanCancel: _handleTapUp,
                  // Add a GestureDetector to detect taps on the face area
                  onTap: () {
                    // Trigger an animation or change in the face's appearance
                    setState(() {
                      // Example: Toggle a boolean to change face expression
                      _gameState = _gameState.copyWith(
                          faceExpression: !_gameState.faceExpression);
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0D001A), // Deep purple night
                          Color(0xFF1A0033), // Purple-black
                          Color(0xFF2D1B69), // Electric purple
                          Color(0xFF0F0F23), // Dark blue
                        ],
                        stops: [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: NeonRunnerPainter(gameState: _gameState),
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      ),
                    ),
                  ),
                ),
                // Retro scanline overlay
                _buildScanlineOverlay(constraints),
                // Floating back button
                _buildFloatingBackButton(),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Retro scanline effect painter
class _RetroScanlinePainter extends CustomPainter {
  final double progress;
  final double glowIntensity;

  _RetroScanlinePainter({
    required this.progress,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw horizontal scanlines across the screen
    final scanlinePaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1 * glowIntensity)
      ..style = PaintingStyle.fill;

    // Static scanlines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 2),
        scanlinePaint,
      );
    }

    // Moving scanline
    final movingScanlinePaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.3 * glowIntensity)
      ..style = PaintingStyle.fill;

    final scanlineY = size.height * progress;
    canvas.drawRect(
      Rect.fromLTWH(0, scanlineY - 1, size.width, 3),
      movingScanlinePaint,
    );

    // Add subtle vignette effect for retro CRT feel
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.3 * glowIntensity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      vignettePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RetroScanlinePainter oldDelegate) {
    return progress != oldDelegate.progress ||
        glowIntensity != oldDelegate.glowIntensity;
  }
}

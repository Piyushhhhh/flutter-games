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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import '../../widgets/common_widgets.dart';
import 'neon_runner_models.dart';
import 'neon_runner_controller.dart';
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

  // Input handling
  bool _isPressed = false;
  bool _isDuckPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = NeonRunnerController();
    _initializeGame();
    _setupGameLoop();
  }

  @override
  void dispose() {
    _ticker.dispose();
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

  void _stopGameLoop() {
    if (_ticker.isActive) {
      _ticker.stop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: GameAppBar(
        title: 'Neon Runner',
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: const Color(0xFF00FFFF),
      ),
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

            return GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: (_) => _handleTapUp(),
              onTapCancel: _handleTapUp,
              // Add pan gestures for better touch response
              onPanDown: (details) => _handleTapDown(
                  TapDownDetails(globalPosition: details.globalPosition)),
              onPanEnd: (details) => _handleTapUp(),
              onPanCancel: _handleTapUp,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0a0a0a),
                      Color(0xFF1a1a2e),
                    ],
                  ),
                ),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: NeonRunnerPainter(gameState: _gameState),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

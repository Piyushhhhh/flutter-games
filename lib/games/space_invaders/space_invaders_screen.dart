import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/game_models.dart';

class SpaceInvadersScreen extends StatefulWidget {
  const SpaceInvadersScreen({super.key});

  @override
  State<SpaceInvadersScreen> createState() => _SpaceInvadersScreenState();
}

class _SpaceInvadersScreenState extends State<SpaceInvadersScreen>
    with TickerProviderStateMixin {
  late AnimationController _gameController;
  late SpaceInvadersGameState _gameState;
  Timer? _gameTimer;
  Timer? _enemySpawnTimer;
  Timer? _levelTimer;
  Timer? _autoShootTimer;

  final GlobalKey _gameAreaKey = GlobalKey();
  Size _gameSize = const Size(400, 600);

  bool _isGameActive = false;
  bool _isPanning = false;
  double _panVelocity = 0.0;
  DateTime _lastShot = DateTime.now();

  // Game constants
  static const double _bulletSpeed = 300.0;
  static const double _enemySpeed = 80.0;
  static const double _shootCooldown = 0.3; // seconds for auto-shooting
  static const Duration _gameTick = Duration(milliseconds: 16); // ~60 FPS
  static const Duration _autoShootInterval =
      Duration(milliseconds: 300); // Auto-shoot every 300ms

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      duration: const Duration(hours: 1),
      vsync: this,
    );
    _gameState = SpaceInvadersGameState.initial();
    _setupGame();
  }

  @override
  void dispose() {
    _gameController.dispose();
    _gameTimer?.cancel();
    _enemySpawnTimer?.cancel();
    _levelTimer?.cancel();
    _autoShootTimer?.cancel();
    super.dispose();
  }

  void _setupGame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          _gameAreaKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _gameSize = renderBox.size;
          _gameState = _gameState.copyWith(
            playerPosition: Offset(_gameSize.width / 2, _gameSize.height - 80),
          );
        });
      }
    });
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _gameState = SpaceInvadersGameState.initial().copyWith(
        playerPosition: Offset(_gameSize.width / 2, _gameSize.height - 80),
        gameState: GameState.playing,
      );
    });

    _gameController.repeat();

    // Main game loop
    _gameTimer = Timer.periodic(_gameTick, (timer) {
      if (_isGameActive) {
        _updateGame();
      }
    });

    // Enemy spawning
    _enemySpawnTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isGameActive) {
        _spawnEnemy();
      }
    });

    // Level progression
    _levelTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isGameActive) {
        _nextLevel();
      }
    });

    // Auto-shooting timer
    _autoShootTimer = Timer.periodic(_autoShootInterval, (timer) {
      if (_isGameActive) {
        _autoShoot();
      }
    });
  }

  void _updateGame() {
    if (!_isGameActive) return;

    final double deltaTime = _gameTick.inMilliseconds / 1000.0;

    // Update player movement
    _updatePlayerMovement(deltaTime);

    // Update bullets
    _updateBullets(deltaTime);

    // Update enemies
    _updateEnemies(deltaTime);

    // Check collisions
    _checkCollisions();

    // Remove off-screen objects
    _cleanupObjects();

    setState(() {});
  }

  void _updatePlayerMovement(double deltaTime) {
    // Player movement is now handled entirely by gestures
    // This method is kept for consistency but no longer performs button-based movement
  }

  void _updateBullets(double deltaTime) {
    if (_gameState.bullets.isEmpty) return;

    final updatedBullets = _gameState.bullets.map((bullet) {
      return bullet.copyWith(
        position: Offset(
          bullet.position.dx,
          bullet.position.dy - _bulletSpeed * deltaTime,
        ),
      );
    }).toList();

    _gameState = _gameState.copyWith(bullets: updatedBullets);
  }

  void _updateEnemies(double deltaTime) {
    if (_gameState.enemies.isEmpty) return;

    final updatedEnemies = _gameState.enemies.map((enemy) {
      return enemy.copyWith(
        position: Offset(
          enemy.position.dx + enemy.velocity.dx * deltaTime,
          enemy.position.dy + (_enemySpeed + _gameState.level * 10) * deltaTime,
        ),
      );
    }).toList();

    _gameState = _gameState.copyWith(enemies: updatedEnemies);
  }

  void _spawnEnemy() {
    if (!_isGameActive) return;

    final random = math.Random();
    final x = random.nextDouble() * (_gameSize.width - 40) + 20;
    final enemyType = EnemyType.values[random.nextInt(EnemyType.values.length)];

    final enemy = Enemy(
      position: Offset(x, -20),
      velocity: Offset(
        (random.nextDouble() - 0.5) * 50, // Random horizontal movement
        0,
      ),
      type: enemyType,
      health: enemyType.health,
    );

    setState(() {
      _gameState = _gameState.copyWith(
        enemies: [..._gameState.enemies, enemy],
      );
    });
  }

  void _autoShoot() {
    if (!_canShoot()) return;

    _lastShot = DateTime.now();
    final bullet = Bullet(
      position: Offset(
        _gameState.playerPosition.dx,
        _gameState.playerPosition.dy - 10,
      ),
      velocity: const Offset(0, -1),
    );

    setState(() {
      _gameState = _gameState.copyWith(
        bullets: [..._gameState.bullets, bullet],
      );
    });

    // Play sound effect (haptic feedback)
    HapticFeedback.lightImpact();
  }

  bool _canShoot() {
    final now = DateTime.now();
    return now.difference(_lastShot).inMilliseconds > (_shootCooldown * 1000);
  }

  void _handlePanStart(DragStartDetails details) {
    _isPanning = true;
    _panVelocity = 0.0;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isGameActive || !_isPanning) return;

    final double deltaX = details.delta.dx;
    const double sensitivity = 4.0;

    // Update velocity for smoother movement
    _panVelocity = deltaX * sensitivity;

    Offset newPosition = _gameState.playerPosition;
    newPosition = Offset(
      math.max(
          20, math.min(_gameSize.width - 20, newPosition.dx + _panVelocity)),
      newPosition.dy,
    );

    if (newPosition != _gameState.playerPosition) {
      setState(() {
        _gameState = _gameState.copyWith(playerPosition: newPosition);
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _isPanning = false;
    _panVelocity = 0.0;
  }

  void _handleTap(TapDownDetails details) {
    if (!_isGameActive) return;

    final RenderBox? renderBox =
        _gameAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(details.globalPosition);
      final screenWidth = renderBox.size.width;
      final tapX = localPosition.dx;

      // Move player immediately towards tap position
      Offset newPosition = _gameState.playerPosition;
      const double tapMoveDistance = 50.0;

      if (tapX < screenWidth / 2) {
        // Tap on left side - move left
        newPosition = Offset(
          math.max(20, newPosition.dx - tapMoveDistance),
          newPosition.dy,
        );
      } else {
        // Tap on right side - move right
        newPosition = Offset(
          math.min(_gameSize.width - 20, newPosition.dx + tapMoveDistance),
          newPosition.dy,
        );
      }

      if (newPosition != _gameState.playerPosition) {
        setState(() {
          _gameState = _gameState.copyWith(playerPosition: newPosition);
        });
      }
    }
  }

  void _checkCollisions() {
    // Check bullet-enemy collisions
    final remainingBullets = <Bullet>[];
    final remainingEnemies = List<Enemy>.from(_gameState.enemies);
    int points = 0;

    for (final bullet in _gameState.bullets) {
      bool bulletHit = false;

      for (int i = 0; i < remainingEnemies.length; i++) {
        final enemy = remainingEnemies[i];
        if (_isColliding(bullet.position, enemy.position, 20)) {
          bulletHit = true;
          final updatedEnemy = enemy.copyWith(health: enemy.health - 1);

          if (updatedEnemy.health <= 0) {
            points += enemy.type.points;
            remainingEnemies.removeAt(i);
            // Enemy destroyed, add explosion effect
            HapticFeedback.mediumImpact();
          } else {
            remainingEnemies[i] = updatedEnemy;
          }
          break; // Exit the loop once a collision is found
        }
      }

      if (!bulletHit) {
        remainingBullets.add(bullet);
      }
    }

    // Check player-enemy collisions
    for (final enemy in remainingEnemies) {
      if (_isColliding(_gameState.playerPosition, enemy.position, 25)) {
        _gameOver();
        return;
      }
    }

    // Check if enemies reached bottom
    final List<Enemy> finalEnemies = [];
    for (final enemy in remainingEnemies) {
      if (enemy.position.dy > _gameSize.height) {
        setState(() {
          _gameState = _gameState.copyWith(lives: _gameState.lives - 1);
        });
        if (_gameState.lives <= 0) {
          _gameOver();
          return;
        }
      } else {
        finalEnemies.add(enemy);
      }
    }

    setState(() {
      _gameState = _gameState.copyWith(
        bullets: remainingBullets,
        enemies: finalEnemies,
        score: _gameState.score + points,
      );
    });
  }

  bool _isColliding(Offset pos1, Offset pos2, double radius) {
    final distance = (pos1 - pos2).distance;
    return distance < radius;
  }

  void _cleanupObjects() {
    // Remove bullets that are off-screen
    final visibleBullets =
        _gameState.bullets.where((bullet) => bullet.position.dy > -10).toList();

    if (visibleBullets.length != _gameState.bullets.length) {
      _gameState = _gameState.copyWith(bullets: visibleBullets);
    }
  }

  void _nextLevel() {
    setState(() {
      _gameState = _gameState.copyWith(level: _gameState.level + 1);
    });
    HapticFeedback.heavyImpact();
  }

  void _gameOver() {
    setState(() {
      _isGameActive = false;
      _gameState = _gameState.copyWith(gameState: GameState.gameOver);
    });

    _gameController.stop();
    _gameTimer?.cancel();
    _enemySpawnTimer?.cancel();
    _levelTimer?.cancel();
    _autoShootTimer?.cancel();

    HapticFeedback.heavyImpact();
  }

  void _resetGame() {
    setState(() {
      _isGameActive = false;
      _gameState = SpaceInvadersGameState.initial().copyWith(
        playerPosition: Offset(_gameSize.width / 2, _gameSize.height - 80),
      );
    });

    _gameController.stop();
    _gameTimer?.cancel();
    _enemySpawnTimer?.cancel();
    _levelTimer?.cancel();
    _autoShootTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Space Shooter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full screen game area
          Positioned.fill(
            child: _buildGameArea(),
          ),

          // Game stats overlay
          Positioned(
            top: AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top +
                10,
            left: 0,
            right: 0,
            child: _buildGameStats(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Scanlines overlay
          CustomPaint(
            size: const Size(double.infinity, 80),
            painter: ScanlinesPainter(),
          ),
          // Stats content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRetroStatItem('Score', _gameState.score.toString(),
                  const Color(0xFF00FF00)),
              _buildRetroStatItem('Level', _gameState.level.toString(),
                  const Color(0xFF00FFFF)),
              _buildRetroStatItem('Lives', _gameState.lives.toString(),
                  const Color(0xFFFF0080)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetroStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Stack(
          children: [
            // Glow effect for label
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                foreground: Paint()
                  ..color = color.withOpacity(0.6)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
              ),
            ),
            // Main label
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Glow effect for value
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                foreground: Paint()
                  ..color = Colors.white.withOpacity(0.8)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
              ),
            ),
            // Main value
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameArea() {
    return Container(
      key: _gameAreaKey,
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A), // Deep black
            Color(0xFF1A0033), // Dark purple
            Color(0xFF2D1B69), // Electric purple
            Color(0xFF0D001A), // Deep space purple
            Color(0xFF000000), // Pure black
          ],
          stops: [0.0, 0.3, 0.5, 0.8, 1.0],
        ),
      ),
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTapDown: _handleTap,
        child: Stack(
          children: [
            // Background stars
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _gameController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: GalaxyBackgroundPainter(_gameController.value),
                  );
                },
              ),
            ),

            // Game canvas
            Positioned.fill(
              child: CustomPaint(
                painter: SpaceInvadersPainter(_gameState),
              ),
            ),

            // Game over overlay
            if (_gameState.gameState == GameState.gameOver)
              _buildGameOverOverlay(),

            // Start game overlay
            if (_gameState.gameState == GameState.initial)
              _buildStartGameOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.95),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Scanlines effect
          Positioned.fill(
            child: CustomPaint(
              painter: ScanlinesPainter(),
            ),
          ),

          // Main content
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFFF0080).withOpacity(0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF0080).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flashing GAME OVER text
                  AnimatedBuilder(
                    animation: _gameController,
                    builder: (context, child) {
                      final flash =
                          (math.sin(_gameController.value * 8 * math.pi) + 1) /
                              2;
                      return _buildGlowText(
                        'GAME OVER',
                        Color.lerp(const Color(0xFFFF0080),
                            const Color(0xFFFF00FF), flash)!,
                        48,
                        FontWeight.w900,
                        letterSpacing: 6,
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Score display
                  _buildGlowText(
                    'FINAL SCORE',
                    const Color(0xFF00FFFF),
                    16,
                    FontWeight.w600,
                    letterSpacing: 2,
                  ),

                  const SizedBox(height: 16),

                  // Animated score value
                  AnimatedBuilder(
                    animation: _gameController,
                    builder: (context, child) {
                      final pulse = 1.0 +
                          math.sin(_gameController.value * 6 * math.pi) * 0.1;
                      return Transform.scale(
                        scale: pulse,
                        child: _buildGlowText(
                          '${_gameState.score}',
                          const Color(0xFFFFFF00),
                          36,
                          FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Retro play again button
                  _buildRetroPlayAgainButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroPlayAgainButton() {
    return AnimatedBuilder(
      animation: _gameController,
      builder: (context, child) {
        final pulse =
            1.0 + math.sin(_gameController.value * 4 * math.pi) * 0.08;
        return Transform.scale(
          scale: pulse,
          child: GestureDetector(
            onTap: () {
              _resetGame();
              _startGame();
            },
            child: Container(
              width: 220,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF00FF00).withOpacity(0.8),
                    const Color(0xFF00CC00).withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF00).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF00FFFF).withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Button scanlines
                  CustomPaint(
                    size: const Size(220, 55),
                    painter: ButtonScanlinesPainter(),
                  ),
                  // Button content
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.replay,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PLAY AGAIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: Colors.black,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00FF00).withOpacity(0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartGameOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.95),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Retro scanlines effect
          Positioned.fill(
            child: CustomPaint(
              painter: ScanlinesPainter(),
            ),
          ),

          // Main content
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Retro animated spaceship
                  AnimatedBuilder(
                    animation: _gameController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0,
                            math.sin(_gameController.value * 2 * math.pi) * 8),
                        child: _buildRetroSpaceship(),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Glowing title with retro effect
                  _buildRetroTitle(),

                  const SizedBox(height: 24),

                  // Retro subtitle with typewriter effect
                  _buildRetroSubtitle(),

                  const SizedBox(height: 48),

                  // Retro arcade button
                  _buildRetroStartButton(),

                  const SizedBox(height: 32),

                  // Retro instructions
                  _buildRetroInstructions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroSpaceship() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF00FFFF).withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Main spaceship
          CustomPaint(
            size: const Size(60, 60),
            painter: RetroSpaceshipPainter(),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroTitle() {
    return AnimatedBuilder(
      animation: _gameController,
      builder: (context, child) {
        final pulse = 1.0 + math.sin(_gameController.value * 4 * math.pi) * 0.1;
        return Transform.scale(
          scale: pulse,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Text(
                'SPACE INVADERS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  foreground: Paint()
                    ..color = const Color(0xFF00FF00).withOpacity(0.8)
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
                ),
              ),
              // Main text
              const Text(
                'SPACE INVADERS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Color(0xFF00FF00),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRetroSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildGlowText(
            'DEFEND EARTH FROM ALIEN INVASION!',
            const Color(0xFF00FFFF),
            16,
            FontWeight.w600,
            letterSpacing: 2,
          ),
          const SizedBox(height: 12),
          _buildGlowText(
            'CLASSIC ARCADE ACTION',
            const Color(0xFFFF0080),
            14,
            FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildRetroStartButton() {
    return AnimatedBuilder(
      animation: _gameController,
      builder: (context, child) {
        final pulse =
            1.0 + math.sin(_gameController.value * 3 * math.pi) * 0.05;
        return Transform.scale(
          scale: pulse,
          child: GestureDetector(
            onTap: _startGame,
            child: Container(
              width: 250,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.8),
                    const Color(0xFF3B82F6).withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF00FFFF).withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Scanlines on button
                  CustomPaint(
                    size: const Size(250, 60),
                    painter: ButtonScanlinesPainter(),
                  ),
                  // Button text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'START GAME',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00FFFF).withOpacity(0.8),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRetroInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildGlowText(
            'CONTROLS',
            const Color(0xFFFFFF00),
            14,
            FontWeight.w700,
            letterSpacing: 2,
          ),
          const SizedBox(height: 12),
          _buildGlowText(
            'TAP TO MOVE • AUTO-FIRE ENABLED',
            const Color(0xFF00FFFF),
            12,
            FontWeight.w500,
            letterSpacing: 1,
          ),
          const SizedBox(height: 4),
          _buildGlowText(
            'SURVIVE THE ALIEN INVASION!',
            const Color(0xFFFF0080),
            12,
            FontWeight.w500,
            letterSpacing: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildGlowText(
      String text, Color color, double fontSize, FontWeight fontWeight,
      {double letterSpacing = 0}) {
    return Stack(
      children: [
        // Glow effect
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..color = color.withOpacity(0.8)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          ),
          textAlign: TextAlign.center,
        ),
        // Main text
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Game state management
class SpaceInvadersGameState {
  final GameState gameState;
  final Offset playerPosition;
  final List<Bullet> bullets;
  final List<Enemy> enemies;
  final int score;
  final int level;
  final int lives;

  const SpaceInvadersGameState({
    required this.gameState,
    required this.playerPosition,
    required this.bullets,
    required this.enemies,
    required this.score,
    required this.level,
    required this.lives,
  });

  factory SpaceInvadersGameState.initial() {
    return const SpaceInvadersGameState(
      gameState: GameState.initial,
      playerPosition: Offset(200, 500),
      bullets: [],
      enemies: [],
      score: 0,
      level: 1,
      lives: 3,
    );
  }

  SpaceInvadersGameState copyWith({
    GameState? gameState,
    Offset? playerPosition,
    List<Bullet>? bullets,
    List<Enemy>? enemies,
    int? score,
    int? level,
    int? lives,
  }) {
    return SpaceInvadersGameState(
      gameState: gameState ?? this.gameState,
      playerPosition: playerPosition ?? this.playerPosition,
      bullets: bullets ?? this.bullets,
      enemies: enemies ?? this.enemies,
      score: score ?? this.score,
      level: level ?? this.level,
      lives: lives ?? this.lives,
    );
  }
}

// Game entities
class Bullet {
  final Offset position;
  final Offset velocity;

  const Bullet({
    required this.position,
    required this.velocity,
  });

  Bullet copyWith({
    Offset? position,
    Offset? velocity,
  }) {
    return Bullet(
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
    );
  }
}

enum EnemyType {
  scout(health: 1, points: 10),
  fighter(health: 2, points: 25),
  bomber(health: 3, points: 50);

  const EnemyType({required this.health, required this.points});
  final int health;
  final int points;
}

class Enemy {
  final Offset position;
  final Offset velocity;
  final EnemyType type;
  final int health;

  const Enemy({
    required this.position,
    required this.velocity,
    required this.type,
    required this.health,
  });

  Enemy copyWith({
    Offset? position,
    Offset? velocity,
    EnemyType? type,
    int? health,
  }) {
    return Enemy(
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      type: type ?? this.type,
      health: health ?? this.health,
    );
  }
}

// Custom painters for game rendering
class SpaceInvadersPainter extends CustomPainter {
  final SpaceInvadersGameState gameState;

  SpaceInvadersPainter(this.gameState);

  @override
  void paint(Canvas canvas, Size size) {
    // Don't paint if size is invalid
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    // Draw player
    _drawPlayer(canvas, gameState.playerPosition);

    // Draw bullets
    for (final bullet in gameState.bullets) {
      _drawBullet(canvas, bullet.position);
    }

    // Draw enemies
    for (final enemy in gameState.enemies) {
      _drawEnemy(canvas, enemy.position, enemy.type);
    }
  }

  void _drawPlayer(Canvas canvas, Offset position) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(position.dx, position.dy - 15);
    path.lineTo(position.dx - 15, position.dy + 15);
    path.lineTo(position.dx + 15, position.dy + 15);
    path.close();

    canvas.drawPath(path, paint);

    // Draw engine glow
    final glowPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(position.dx, position.dy + 10),
      5,
      glowPaint,
    );
  }

  void _drawBullet(Canvas canvas, Offset position) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 3, paint);
  }

  void _drawEnemy(Canvas canvas, Offset position, EnemyType type) {
    final paint = Paint()
      ..color = _getEnemyColor(type)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(position.dx, position.dy + 15);
    path.lineTo(position.dx - 12, position.dy - 15);
    path.lineTo(position.dx + 12, position.dy - 15);
    path.close();

    canvas.drawPath(path, paint);
  }

  Color _getEnemyColor(EnemyType type) {
    switch (type) {
      case EnemyType.scout:
        return AppTheme.successColor;
      case EnemyType.fighter:
        return AppTheme.warningColor;
      case EnemyType.bomber:
        return AppTheme.errorColor;
    }
  }

  @override
  bool shouldRepaint(SpaceInvadersPainter oldDelegate) {
    return oldDelegate.gameState != gameState;
  }
}

// Enhanced galaxy background painter with planets, asteroids, and cosmic effects
class GalaxyBackgroundPainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars;
  final List<Planet> planets;
  final List<Asteroid> asteroids;
  final List<NebulaCloud> nebulaClouds;
  final List<CosmicDust> cosmicDust;

  GalaxyBackgroundPainter(this.animationValue)
      : stars = _generateStars(),
        planets = _generatePlanets(),
        asteroids = _generateAsteroids(),
        nebulaClouds = _generateNebulaClouds(),
        cosmicDust = _generateCosmicDust();

  static List<Star> _generateStars() {
    final random = math.Random(42); // Fixed seed for consistent stars
    return List.generate(150, (index) {
      return Star(
        position: Offset(random.nextDouble(), random.nextDouble()),
        size: random.nextDouble() * 3 + 0.5,
        brightness: random.nextDouble() * 0.8 + 0.2,
        color: _getStarColor(random.nextInt(5)),
        twinkleSpeed: random.nextDouble() * 2 + 0.5,
        twinkleOffset: random.nextDouble() * math.pi * 2,
      );
    });
  }

  static List<Planet> _generatePlanets() {
    final random = math.Random(123); // Fixed seed for consistent planets
    return List.generate(3, (index) {
      return Planet(
        position: Offset(random.nextDouble(), random.nextDouble()),
        size: random.nextDouble() * 60 + 20,
        color: _getPlanetColor(index),
        atmosphereColor: _getPlanetAtmosphereColor(index),
        rotationSpeed: random.nextDouble() * 0.5 + 0.1,
        hasRings: random.nextBool(),
        ringColor: _getPlanetRingColor(index),
      );
    });
  }

  static List<Asteroid> _generateAsteroids() {
    final random = math.Random(456); // Fixed seed for consistent asteroids
    return List.generate(12, (index) {
      return Asteroid(
        position: Offset(random.nextDouble(), random.nextDouble()),
        size: random.nextDouble() * 8 + 2,
        speed: random.nextDouble() * 0.3 + 0.1,
        rotationSpeed: random.nextDouble() * 4 + 1,
        color: _getAsteroidColor(random.nextInt(3)),
        shape: random.nextInt(4), // Different asteroid shapes
      );
    });
  }

  static List<NebulaCloud> _generateNebulaClouds() {
    final random = math.Random(789); // Fixed seed for consistent nebulae
    return List.generate(4, (index) {
      return NebulaCloud(
        position: Offset(random.nextDouble(), random.nextDouble()),
        size: random.nextDouble() * 200 + 100,
        color: _getNebulaColor(index),
        density: random.nextDouble() * 0.3 + 0.1,
        pulseSpeed: random.nextDouble() * 0.5 + 0.2,
      );
    });
  }

  static List<CosmicDust> _generateCosmicDust() {
    final random = math.Random(321); // Fixed seed for consistent cosmic dust
    return List.generate(50, (index) {
      return CosmicDust(
        position: Offset(random.nextDouble(), random.nextDouble()),
        size: random.nextDouble() * 2 + 0.5,
        speed: random.nextDouble() * 0.8 + 0.2,
        color: _getCosmicDustColor(random.nextInt(4)),
        opacity: random.nextDouble() * 0.6 + 0.2,
      );
    });
  }

  static Color _getStarColor(int type) {
    switch (type) {
      case 0:
        return const Color(0xFFFFFFFF); // White dwarf
      case 1:
        return const Color(0xFFFFF3E0); // Yellow star
      case 2:
        return const Color(0xFFFFE0B2); // Orange star
      case 3:
        return const Color(0xFFFF8A65); // Red star
      case 4:
        return const Color(0xFFE3F2FD); // Blue giant
      default:
        return const Color(0xFFFFFFFF);
    }
  }

  static Color _getPlanetColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF4FC3F7); // Ice planet
      case 1:
        return const Color(0xFFFF7043); // Mars-like planet
      case 2:
        return const Color(0xFF66BB6A); // Earth-like planet
      default:
        return const Color(0xFF9C27B0); // Gas giant
    }
  }

  static Color _getPlanetAtmosphereColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF81D4FA); // Ice planet atmosphere
      case 1:
        return const Color(0xFFFFAB91); // Mars-like atmosphere
      case 2:
        return const Color(0xFF81C784); // Earth-like atmosphere
      default:
        return const Color(0xFFAB47BC); // Gas giant atmosphere
    }
  }

  static Color _getPlanetRingColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFE1F5FE); // Ice rings
      case 1:
        return const Color(0xFFFFCCBC); // Rocky rings
      case 2:
        return const Color(0xFFC8E6C9); // Organic rings
      default:
        return const Color(0xFFE1BEE7); // Gas rings
    }
  }

  static Color _getAsteroidColor(int type) {
    switch (type) {
      case 0:
        return const Color(0xFF795548); // Rocky asteroid
      case 1:
        return const Color(0xFF607D8B); // Metallic asteroid
      case 2:
        return const Color(0xFF8D6E63); // Carbonaceous asteroid
      default:
        return const Color(0xFF5D4037); // Dark asteroid
    }
  }

  static Color _getNebulaColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFF4081); // Pink nebula
      case 1:
        return const Color(0xFF00BCD4); // Cyan nebula
      case 2:
        return const Color(0xFF9C27B0); // Purple nebula
      case 3:
        return const Color(0xFF4CAF50); // Green nebula
      default:
        return const Color(0xFFFF9800); // Orange nebula
    }
  }

  static Color _getCosmicDustColor(int type) {
    switch (type) {
      case 0:
        return const Color(0xFFFFEB3B); // Golden dust
      case 1:
        return const Color(0xFFE91E63); // Cosmic dust
      case 2:
        return const Color(0xFF3F51B5); // Stellar dust
      case 3:
        return const Color(0xFF009688); // Nebular dust
      default:
        return const Color(0xFFFFFFFF); // White dust
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Don't paint if size is invalid
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    // Draw background gradient
    _drawSpaceBackground(canvas, size);

    // Draw nebula clouds (furthest background)
    _drawNebulaClouds(canvas, size);

    // Draw cosmic dust
    _drawCosmicDust(canvas, size);

    // Draw distant galaxies
    _drawDistantGalaxies(canvas, size);

    // Draw planets (middle background)
    _drawPlanets(canvas, size);

    // Draw asteroids (moving objects)
    _drawAsteroids(canvas, size);

    // Draw enhanced star field (foreground)
    _drawEnhancedStars(canvas, size);
  }

  void _drawSpaceBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.5,
      colors: [
        const Color(0xFF1A0033).withOpacity(0.8),
        const Color(0xFF0A0A0A).withOpacity(0.9),
        const Color(0xFF000000),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawNebulaClouds(Canvas canvas, Size size) {
    for (final cloud in nebulaClouds) {
      final x = cloud.position.dx * size.width;
      final y = cloud.position.dy * size.height;
      final pulse =
          math.sin(animationValue * cloud.pulseSpeed * math.pi) * 0.3 + 0.7;

      final paint = Paint()
        ..color = cloud.color.withOpacity(cloud.density * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(
        Offset(x, y),
        cloud.size * pulse,
        paint,
      );

      // Add inner glow
      final innerPaint = Paint()
        ..color = cloud.color.withOpacity(cloud.density * pulse * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawCircle(
        Offset(x, y),
        cloud.size * 0.6 * pulse,
        innerPaint,
      );
    }
  }

  void _drawCosmicDust(Canvas canvas, Size size) {
    for (final dust in cosmicDust) {
      final x = dust.position.dx * size.width;
      final y =
          (dust.position.dy * size.height + animationValue * dust.speed * 30) %
              size.height;

      final paint = Paint()
        ..color = dust.color.withOpacity(dust.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(x, y),
        dust.size,
        paint,
      );
    }
  }

  void _drawDistantGalaxies(Canvas canvas, Size size) {
    final galaxies = [
      {'x': 0.1, 'y': 0.2, 'size': 15.0, 'color': const Color(0xFF9C27B0)},
      {'x': 0.8, 'y': 0.15, 'size': 12.0, 'color': const Color(0xFF3F51B5)},
      {'x': 0.3, 'y': 0.8, 'size': 10.0, 'color': const Color(0xFF00BCD4)},
    ];

    for (final galaxy in galaxies) {
      final x = (galaxy['x'] as double) * size.width;
      final y = (galaxy['y'] as double) * size.height;
      final galaxySize = galaxy['size'] as double;
      final color = galaxy['color'] as Color;

      final paint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Draw spiral galaxy shape
      canvas.drawCircle(Offset(x, y), galaxySize, paint);

      // Add spiral arms
      final armPaint = Paint()
        ..color = color.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(
          Offset(x - galaxySize * 0.3, y), galaxySize * 0.7, armPaint);
      canvas.drawCircle(
          Offset(x + galaxySize * 0.3, y), galaxySize * 0.7, armPaint);
    }
  }

  void _drawPlanets(Canvas canvas, Size size) {
    for (final planet in planets) {
      final x = planet.position.dx * size.width;
      final y = planet.position.dy * size.height;
      final rotation = animationValue * planet.rotationSpeed;

      // Draw planet atmosphere
      final atmospherePaint = Paint()
        ..color = planet.atmosphereColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(
        Offset(x, y),
        planet.size * 1.2,
        atmospherePaint,
      );

      // Draw planet surface
      final surfacePaint = Paint()
        ..color = planet.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        planet.size,
        surfacePaint,
      );

      // Draw planet surface details
      final detailPaint = Paint()
        ..color = planet.color.withOpacity(0.7)
        ..style = PaintingStyle.fill;

      // Add rotating surface features
      final feature1X = x + math.cos(rotation) * planet.size * 0.3;
      final feature1Y = y + math.sin(rotation) * planet.size * 0.3;
      canvas.drawCircle(
          Offset(feature1X, feature1Y), planet.size * 0.2, detailPaint);

      final feature2X = x + math.cos(rotation + math.pi) * planet.size * 0.5;
      final feature2Y = y + math.sin(rotation + math.pi) * planet.size * 0.5;
      canvas.drawCircle(
          Offset(feature2X, feature2Y), planet.size * 0.15, detailPaint);

      // Draw planet rings if present
      if (planet.hasRings) {
        final ringPaint = Paint()
          ..color = planet.ringColor.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(
          Offset(x, y),
          planet.size * 1.5,
          ringPaint,
        );

        canvas.drawCircle(
          Offset(x, y),
          planet.size * 1.7,
          ringPaint,
        );
      }

      // Draw planet highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final highlightX = x - planet.size * 0.3;
      final highlightY = y - planet.size * 0.3;
      canvas.drawCircle(
          Offset(highlightX, highlightY), planet.size * 0.2, highlightPaint);
    }
  }

  void _drawAsteroids(Canvas canvas, Size size) {
    for (final asteroid in asteroids) {
      final x = asteroid.position.dx * size.width;
      final y = (asteroid.position.dy * size.height +
              animationValue * asteroid.speed * 40) %
          size.height;
      final rotation = animationValue * asteroid.rotationSpeed;

      final paint = Paint()
        ..color = asteroid.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Draw different asteroid shapes
      switch (asteroid.shape) {
        case 0:
          _drawRockyAsteroid(canvas, asteroid.size, paint);
          break;
        case 1:
          _drawMetallicAsteroid(canvas, asteroid.size, paint);
          break;
        case 2:
          _drawIrregularAsteroid(canvas, asteroid.size, paint);
          break;
        case 3:
          _drawCarbonAsteroid(canvas, asteroid.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawRockyAsteroid(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(-size, 0);
    path.lineTo(-size * 0.5, -size * 0.8);
    path.lineTo(size * 0.3, -size * 0.6);
    path.lineTo(size, 0);
    path.lineTo(size * 0.7, size * 0.8);
    path.lineTo(-size * 0.3, size * 0.9);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawMetallicAsteroid(Canvas canvas, double size, Paint paint) {
    canvas.drawCircle(Offset.zero, size, paint);

    // Add metallic highlights
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(-size * 0.3, -size * 0.3), size * 0.2, highlightPaint);
  }

  void _drawIrregularAsteroid(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(-size * 0.8, 0);
    path.lineTo(-size * 0.4, -size);
    path.lineTo(size * 0.2, -size * 0.7);
    path.lineTo(size * 0.9, -size * 0.2);
    path.lineTo(size * 0.6, size * 0.3);
    path.lineTo(size * 0.1, size);
    path.lineTo(-size * 0.5, size * 0.8);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCarbonAsteroid(Canvas canvas, double size, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset.zero, width: size * 1.6, height: size * 1.2),
        Radius.circular(size * 0.2),
      ),
      paint,
    );
  }

  void _drawEnhancedStars(Canvas canvas, Size size) {
    for (final star in stars) {
      final x = star.position.dx * size.width;
      final y =
          (star.position.dy * size.height + animationValue * 20) % size.height;

      // Calculate twinkling effect
      final twinkle = math.sin(
                  animationValue * star.twinkleSpeed * math.pi * 2 +
                      star.twinkleOffset) *
              0.5 +
          0.5;
      final currentBrightness = star.brightness * twinkle;

      final paint = Paint()
        ..color = star.color.withOpacity(currentBrightness)
        ..style = PaintingStyle.fill;

      // Draw star with glow effect
      if (star.size > 2) {
        final glowPaint = Paint()
          ..color = star.color.withOpacity(currentBrightness * 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 2);

        canvas.drawCircle(Offset(x, y), star.size * 2, glowPaint);
      }

      canvas.drawCircle(Offset(x, y), star.size, paint);

      // Draw star spikes for bright stars
      if (star.size > 2.5) {
        final spikePaint = Paint()
          ..color = star.color.withOpacity(currentBrightness * 0.8)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(x - star.size * 3, y),
          Offset(x + star.size * 3, y),
          spikePaint,
        );
        canvas.drawLine(
          Offset(x, y - star.size * 3),
          Offset(x, y + star.size * 3),
          spikePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(GalaxyBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Enhanced background object classes
class Star {
  final Offset position;
  final double size;
  final double brightness;
  final Color color;
  final double twinkleSpeed;
  final double twinkleOffset;

  Star({
    required this.position,
    required this.size,
    required this.brightness,
    required this.color,
    required this.twinkleSpeed,
    required this.twinkleOffset,
  });
}

class Planet {
  final Offset position;
  final double size;
  final Color color;
  final Color atmosphereColor;
  final double rotationSpeed;
  final bool hasRings;
  final Color ringColor;

  Planet({
    required this.position,
    required this.size,
    required this.color,
    required this.atmosphereColor,
    required this.rotationSpeed,
    required this.hasRings,
    required this.ringColor,
  });
}

class Asteroid {
  final Offset position;
  final double size;
  final double speed;
  final double rotationSpeed;
  final Color color;
  final int shape;

  Asteroid({
    required this.position,
    required this.size,
    required this.speed,
    required this.rotationSpeed,
    required this.color,
    required this.shape,
  });
}

class NebulaCloud {
  final Offset position;
  final double size;
  final Color color;
  final double density;
  final double pulseSpeed;

  NebulaCloud({
    required this.position,
    required this.size,
    required this.color,
    required this.density,
    required this.pulseSpeed,
  });
}

class CosmicDust {
  final Offset position;
  final double size;
  final double speed;
  final Color color;
  final double opacity;

  CosmicDust({
    required this.position,
    required this.size,
    required this.speed,
    required this.color,
    required this.opacity,
  });
}

class StarfieldPainter extends CustomPainter {
  final double animationValue;
  final List<Offset> stars;

  StarfieldPainter(this.animationValue) : stars = _generateStars();

  static List<Offset> _generateStars() {
    final random = math.Random(42); // Fixed seed for consistent stars
    return List.generate(100, (index) {
      return Offset(
        random.nextDouble(),
        random.nextDouble(),
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Don't paint if size is invalid
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (final star in stars) {
      final x = star.dx * size.width;
      final y = (star.dy * size.height + animationValue * 50) % size.height;
      canvas.drawCircle(
        Offset(x, y),
        math.Random((star.dx * 1000).toInt()).nextDouble() * 2 + 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Retro UI painters
class ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Add vertical lines for CRT effect
    final verticalPaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.05)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 3) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        verticalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RetroSpaceshipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Main body paint
    final bodyPaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // Draw spaceship body
    final bodyPath = Path();
    bodyPath.moveTo(centerX, centerY - 20);
    bodyPath.lineTo(centerX - 12, centerY + 15);
    bodyPath.lineTo(centerX - 6, centerY + 10);
    bodyPath.lineTo(centerX + 6, centerY + 10);
    bodyPath.lineTo(centerX + 12, centerY + 15);
    bodyPath.close();

    // Draw glow first
    canvas.drawPath(bodyPath, glowPaint);
    canvas.drawPath(bodyPath, bodyPaint);

    // Draw engine flames
    final flamePaint = Paint()
      ..color = const Color(0xFFFF0080)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY + 18), 3, flamePaint);
    canvas.drawCircle(Offset(centerX - 8, centerY + 16), 2, flamePaint);
    canvas.drawCircle(Offset(centerX + 8, centerY + 16), 2, flamePaint);

    // Draw cockpit
    final cockpitPaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY - 5), 4, cockpitPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ButtonScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw horizontal scanlines on button
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

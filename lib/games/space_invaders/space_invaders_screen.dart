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
    final double sensitivity = 4.0;

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
      padding: const EdgeInsets.all(AppConstants.spacingM),
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Score', _gameState.score.toString()),
          _buildStatItem('Level', _gameState.level.toString()),
          _buildStatItem('Lives', _gameState.lives.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.fontS,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppConstants.fontXL,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            Color(0xFF0D1B2A),
            Color(0xFF1B263B),
            Color(0xFF2D3748),
          ],
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
                    painter: StarfieldPainter(_gameController.value),
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
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: AppConstants.fontDisplay,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'Final Score: ${_gameState.score}',
              style: const TextStyle(
                fontSize: AppConstants.fontXL,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),
            AnimatedGameButton(
              text: 'Play Again',
              icon: Icons.replay,
              backgroundColor: AppTheme.primaryColor,
              onPressed: () {
                _resetGame();
                _startGame();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartGameOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rocket_launch,
              size: AppConstants.iconXXXL,
              color: Colors.white,
            ),
            const SizedBox(height: AppConstants.spacingL),
            const Text(
              'SPACE SHOOTER',
              style: TextStyle(
                fontSize: AppConstants.fontDisplay,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            const Text(
              'Defend Earth from alien invasion!',
              style: TextStyle(
                fontSize: AppConstants.fontL,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            AnimatedGameButton(
              text: 'Start Game',
              icon: Icons.play_arrow,
              backgroundColor: AppTheme.primaryColor,
              onPressed: _startGame,
            ),
          ],
        ),
      ),
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

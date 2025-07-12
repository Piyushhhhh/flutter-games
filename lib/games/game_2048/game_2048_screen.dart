import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../models/game_models.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'game_2048_controller.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen>
    with TickerProviderStateMixin {
  late Game2048Controller _controller;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _scoreController;
  late AnimationController _bestScoreController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _bestScoreAnimation;

  bool _isAnimating = false;
  Offset? _panStartOffset;

  @override
  void initState() {
    super.initState();
    _controller = Game2048Controller();
    _controller.initialize();
    _controller.addListener(_onGameStateChanged);

    // Animation controllers
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: GameConstants.game2048MoveDuration,
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bestScoreController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutBack,
    ));

    _bestScoreAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bestScoreController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _scoreController.dispose();
    _bestScoreController.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});

      // Trigger animations for new tiles
      if (_controller.tiles.any((tile) => tile.isNew)) {
        _scaleController.forward().then((_) {
          _scaleController.reset();
        });
      }

      // Trigger score animation when score changes
      _scoreController.forward().then((_) {
        _scoreController.reset();
      });

      // Trigger best score animation when best score changes
      // Add a slight delay to stagger the animations
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _bestScoreController.forward().then((_) {
            _bestScoreController.reset();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF1A0A1A),
              Color(0xFF2D1B2D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildScoreSection(),
                      const SizedBox(height: 24),
                      _buildGameControls(),
                      const SizedBox(height: 32),
                      Expanded(
                        child: Center(
                          child: _buildGameBoard(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInstructions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Deep slate
            Color(0xFF1E293B), // Darker slate
            Color(0xFF334155), // Medium slate
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF06B6D4).withOpacity(0.3),
                  const Color(0xFF06B6D4).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF06B6D4).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF06B6D4)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF06B6D4).withOpacity(0.2),
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF06B6D4).withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Text(
              '2048',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF06B6D4),
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Color(0xFF06B6D4),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF06B6D4).withOpacity(0.3),
                  const Color(0xFF06B6D4).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF06B6D4).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.help_outline, color: Color(0xFF06B6D4)),
              onPressed: _showHowToPlay,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    return Row(
      children: [
        Expanded(
          child: _buildScoreCard(
            title: 'SCORE',
            value: _controller.score,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF06B6D4),
                Color(0xFF0891B2),
              ],
            ),
            icon: Icons.star,
            glowColor: const Color(0xFF06B6D4),
            animation: _scoreAnimation,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildScoreCard(
            title: 'BEST',
            value: _controller.bestScore,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFEF4444),
                Color(0xFFDC2626),
              ],
            ),
            icon: Icons.emoji_events,
            glowColor: const Color(0xFFEF4444),
            animation: _bestScoreAnimation,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard({
    required String title,
    required int value,
    required Gradient gradient,
    required IconData icon,
    required Color glowColor,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (animation.value * 0.05),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: glowColor.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: glowColor.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                      shadows: [
                        Shadow(
                          color: glowColor,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: glowColor,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: glowColor,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameControls() {
    return Row(
      children: [
        Expanded(
          child: _buildControlButton(
            icon: Icons.refresh,
            label: 'New Game',
            onPressed: _newGame,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF10B981),
                Color(0xFF059669),
              ],
            ),
            glowColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildControlButton(
            icon: Icons.undo,
            label: 'Undo',
            onPressed: _controller.canUndo ? _undo : null,
            gradient: LinearGradient(
              colors: _controller.canUndo
                  ? [
                      const Color(0xFFF59E0B),
                      const Color(0xFFD97706),
                    ]
                  : [
                      const Color(0xFF374151),
                      const Color(0xFF1F2937),
                    ],
            ),
            glowColor: _controller.canUndo
                ? const Color(0xFFF59E0B)
                : const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Gradient gradient,
    required Color glowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glowColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: glowColor.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: onPressed != null
                      ? Colors.white
                      : const Color(0xFF666666),
                  size: 20,
                  shadows: onPressed != null
                      ? [
                          Shadow(
                            color: glowColor,
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: onPressed != null
                        ? Colors.white
                        : const Color(0xFF666666),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    shadows: onPressed != null
                        ? [
                            Shadow(
                              color: glowColor,
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final boardSize = size * 0.9;
        // Grid layout constants - ensure perfect alignment
        const gridPadding = 20.0;
        const spacing = 12.0;
        final tileSize = (boardSize - (2 * gridPadding) - (3 * spacing)) / 4;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: const Color(0xFF06B6D4).withOpacity(0.2),
                blurRadius: 50,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildGridBackground(boardSize, tileSize),
              _buildTiles(boardSize, tileSize),
              _buildGameOverlay(boardSize),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridBackground(double boardSize, double tileSize) {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A0A1A),
              Color(0xFF2D1B2D),
              Color(0xFF0F0F0F),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF333333).withOpacity(0.3),
                      const Color(0xFF222222).withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTiles(double boardSize, double tileSize) {
    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: _controller.tiles.map((tile) {
          return _buildTileWidget(tile, boardSize, tileSize);
        }).toList(),
      ),
    );
  }

  Widget _buildTileWidget(Tile tile, double boardSize, double tileSize) {
    final position = _getTilePosition(tile.position, boardSize, tileSize);

    return AnimatedPositioned(
      duration: GameConstants.game2048MoveDuration,
      curve: Curves.easeOutCubic,
      left: position.dx,
      top: position.dy,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = tile.isNew ? _scaleAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                gradient: _getTileGradient(tile.value),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getTileGlowColor(tile.value).withOpacity(0.7),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getTileGlowColor(tile.value).withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: _getTileGlowColor(tile.value).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  tile.value.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getTileFontSize(tile.value, tileSize),
                    fontWeight: FontWeight.bold,
                    letterSpacing: tile.value >= 1000 ? -0.5 : 0,
                    shadows: [
                      Shadow(
                        color: _getTileGlowColor(tile.value),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Gradient _getTileGradient(int value) {
    switch (value) {
      case 2:
        return const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF5B21B6)],
        );
      case 4:
        return const LinearGradient(
          colors: [Color(0xFF6B46C1), Color(0xFF7C3AED)],
        );
      case 8:
        return const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFFA855F7)],
        );
      case 16:
        return const LinearGradient(
          colors: [Color(0xFF00FFFF), Color(0xFF0099FF)],
        );
      case 32:
        return const LinearGradient(
          colors: [Color(0xFF00FF88), Color(0xFF00CC66)],
        );
      case 64:
        return const LinearGradient(
          colors: [Color(0xFFFFFF00), Color(0xFFFFCC00)],
        );
      case 128:
        return const LinearGradient(
          colors: [Color(0xFFFF6600), Color(0xFFFF4400)],
        );
      case 256:
        return const LinearGradient(
          colors: [Color(0xFFFF00FF), Color(0xFFFF0099)],
        );
      case 512:
        return const LinearGradient(
          colors: [Color(0xFFFF0066), Color(0xFFFF0033)],
        );
      case 1024:
        return const LinearGradient(
          colors: [Color(0xFFFF3366), Color(0xFFFF1144)],
        );
      case 2048:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFB000)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF9333EA)],
        );
    }
  }

  Color _getTileGlowColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFF6B46C1);
      case 4:
        return const Color(0xFF7C3AED);
      case 8:
        return const Color(0xFF9333EA);
      case 16:
        return const Color(0xFF00FFFF);
      case 32:
        return const Color(0xFF00FF88);
      case 64:
        return const Color(0xFFFFFF00);
      case 128:
        return const Color(0xFFFF6600);
      case 256:
        return const Color(0xFFFF00FF);
      case 512:
        return const Color(0xFFFF0066);
      case 1024:
        return const Color(0xFFFF3366);
      case 2048:
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  double _getTileFontSize(int value, double tileSize) {
    final baseFontSize = tileSize * 0.35;
    if (value < 100) return baseFontSize;
    if (value < 1000) return baseFontSize * 0.85;
    if (value < 10000) return baseFontSize * 0.7;
    return baseFontSize * 0.6;
  }

  Widget _buildGameOverlay(double boardSize) {
    if (!_controller.isGameOver && !_controller.isWon) {
      return const SizedBox.shrink();
    }

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.9),
            const Color(0xFF1A0A1A).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (_controller.isWon
                  ? const Color(0xFFFFD700)
                  : const Color(0xFFFF0066))
              .withOpacity(0.7),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _controller.isWon
                    ? [const Color(0xFFFFD700), const Color(0xFFFFB000)]
                    : [const Color(0xFFFF0066), const Color(0xFFFF0033)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_controller.isWon
                          ? const Color(0xFFFFD700)
                          : const Color(0xFFFF0066))
                      .withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              _controller.isWon
                  ? Icons.emoji_events
                  : Icons.sentiment_dissatisfied,
              size: 60,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: _controller.isWon
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFFF0066),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _controller.isWon ? 'You Win!' : 'Game Over',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              shadows: [
                Shadow(
                  color: _controller.isWon
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFFF0066),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Score: ${_controller.score}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: _controller.isWon
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFFF0066),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOverlayButton(
                'Try Again',
                Icons.refresh,
                () => _newGame(),
                const Color(0xFF00FF88),
              ),
              if (_controller.isWon)
                _buildOverlayButton(
                  'Continue',
                  Icons.play_arrow,
                  () => _controller.continueGame(),
                  const Color(0xFF00FFFF),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayButton(
      String label, IconData icon, VoidCallback onPressed, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                  shadows: [
                    Shadow(
                      color: color,
                      blurRadius: 10,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: color,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A0A1A).withOpacity(0.8),
            const Color(0xFF2D1B2D).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe,
                color: const Color(0xFF06B6D4),
                size: 24,
                shadows: [
                  Shadow(
                    color: const Color(0xFF06B6D4),
                    blurRadius: 10,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Text(
                'Swipe to move tiles',
                style: TextStyle(
                  color: const Color(0xFF06B6D4),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF06B6D4),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Join numbers to reach 2048!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.5),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Offset _getTilePosition(
      Position position, double boardSize, double tileSize) {
    // Use same constants as grid layout for perfect alignment
    const gridPadding = 20.0;
    const spacing = 12.0;
    final x = gridPadding + position.col * (tileSize + spacing);
    final y = gridPadding + position.row * (tileSize + spacing);
    return Offset(x, y);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _panStartOffset ??= details.globalPosition;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isAnimating || _panStartOffset == null) return;

    final delta = details.globalPosition - _panStartOffset!;
    final dx = delta.dx;
    final dy = delta.dy;

    // Reset pan start offset
    _panStartOffset = null;

    // Check if the swipe distance is significant enough
    if (dx.abs() < 20 && dy.abs() < 20) {
      return;
    }

    // Determine direction based on the larger displacement
    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        _move(Direction.right);
      } else {
        _move(Direction.left);
      }
    } else {
      if (dy > 0) {
        _move(Direction.down);
      } else {
        _move(Direction.up);
      }
    }
  }

  Future<void> _move(Direction direction) async {
    if (_isAnimating) return;

    _isAnimating = true;
    HapticFeedback.lightImpact();

    await _controller.move(direction);

    await Future.delayed(GameConstants.game2048MoveDuration);
    _isAnimating = false;
  }

  void _newGame() {
    HapticFeedback.mediumImpact();
    _controller.newGame();
  }

  void _undo() {
    HapticFeedback.lightImpact();
    _controller.undo();
  }

  void _continueGame() {
    HapticFeedback.lightImpact();
    _controller.continueGame();
  }

  void _showHowToPlay() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF06B6D4).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6D4).withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                blurRadius: 60,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF06B6D4).withOpacity(0.2),
                      const Color(0xFF8B5CF6).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF06B6D4).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF06B6D4),
                            Color(0xFF0891B2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 28,
                        shadows: [
                          Shadow(
                            color: Color(0xFF06B6D4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Master 2048',
                            style: TextStyle(
                              color: const Color(0xFF06B6D4),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF06B6D4),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Learn the rules & strategies',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTutorialSection(
                        'Basic Rules',
                        const Color(0xFF06B6D4),
                        [
                          _buildAdvancedInstructionItem(
                            Icons.swipe,
                            'Swipe Controls',
                            'Swipe in any direction (↑↓←→) to move all tiles',
                            'All tiles slide until they hit the edge or another tile',
                            const Color(0xFF06B6D4),
                          ),
                          _buildAdvancedInstructionItem(
                            Icons.merge,
                            'Merge Tiles',
                            'When two identical tiles collide, they merge into one',
                            'Example: 2 + 2 = 4, 4 + 4 = 8, 8 + 8 = 16',
                            const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTutorialSection(
                        'Winning & Scoring',
                        const Color(0xFF10B981),
                        [
                          _buildAdvancedInstructionItem(
                            Icons.emoji_events,
                            'Victory Goal',
                            'Create a tile with the number 2048 to win',
                            'But don\'t stop there - keep playing for higher scores!',
                            const Color(0xFFF59E0B),
                          ),
                          _buildAdvancedInstructionItem(
                            Icons.trending_up,
                            'Score System',
                            'Earn points for every merge you make',
                            'Larger merges give exponentially more points',
                            const Color(0xFFEF4444),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTutorialSection(
                        'Pro Tips',
                        const Color(0xFF8B5CF6),
                        [
                          _buildAdvancedInstructionItem(
                            Icons.lightbulb,
                            'Corner Strategy',
                            'Keep your highest tile in a corner',
                            'This prevents it from being surrounded and trapped',
                            const Color(0xFF06B6D4),
                          ),
                          _buildAdvancedInstructionItem(
                            Icons.psychology,
                            'Think Ahead',
                            'Plan your moves 2-3 steps in advance',
                            'Avoid moves that scatter your high-value tiles',
                            const Color(0xFF10B981),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.1),
                      const Color(0xFF10B981).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF10B981),
                              Color(0xFF059669),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                    shadows: [
                                      Shadow(
                                        color: Color(0xFF10B981),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Start Playing!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFF10B981),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialSection(
      String title, Color accentColor, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor.withOpacity(0.2),
                accentColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: accentColor.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildAdvancedInstructionItem(
    IconData icon,
    String title,
    String description,
    String tip,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B).withOpacity(0.8),
            const Color(0xFF0F172A).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.8),
                      accentColor.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                  shadows: [
                    Shadow(
                      color: accentColor,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: accentColor.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.1),
                  accentColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accentColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: accentColor.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

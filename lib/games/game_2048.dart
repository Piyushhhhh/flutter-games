import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/game_models.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'game_2048_controller.dart';

class Game2048 extends StatefulWidget {
  const Game2048({super.key});

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> with TickerProviderStateMixin {
  late Game2048Controller _controller;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _scoreController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;

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
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _scoreController.dispose();
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
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
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
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade600,
            Colors.deepPurple.shade500,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Spacer(),
          const Text(
            '2048',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
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
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
            icon: Icons.star,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildScoreCard(
            title: 'BEST',
            value: _controller.bestScore,
            gradient: LinearGradient(
              colors: [Colors.amber.shade400, Colors.orange.shade600],
            ),
            icon: Icons.emoji_events,
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
  }) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_scoreAnimation.value * 0.1),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
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
                  ? [Colors.purple.shade400, Colors.purple.shade600]
                  : [Colors.grey.shade300, Colors.grey.shade400],
            ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
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
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFBBADA0),
              const Color(0xFFA69B8F),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
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
                  color: const Color(0xFFCDC1B4).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  tile.value.toString(),
                  style: TextStyle(
                    color: tile.textColor,
                    fontSize: _getTileFontSize(tile.value, tileSize),
                    fontWeight: FontWeight.bold,
                    letterSpacing: tile.value >= 1000 ? -0.5 : 0,
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
        return LinearGradient(
          colors: [const Color(0xFFEEE4DA), const Color(0xFFE0D5C7)],
        );
      case 4:
        return LinearGradient(
          colors: [const Color(0xFFEDE0C8), const Color(0xFFE0D3B7)],
        );
      case 8:
        return LinearGradient(
          colors: [const Color(0xFFF2B179), const Color(0xFFEDA564)],
        );
      case 16:
        return LinearGradient(
          colors: [const Color(0xFFF59563), const Color(0xFFF08A5D)],
        );
      case 32:
        return LinearGradient(
          colors: [const Color(0xFFF67C5F), const Color(0xFFF36F5B)],
        );
      case 64:
        return LinearGradient(
          colors: [const Color(0xFFF65E3B), const Color(0xFFF44336)],
        );
      case 128:
        return LinearGradient(
          colors: [const Color(0xFFEDCF72), const Color(0xFFE6C066)],
        );
      case 256:
        return LinearGradient(
          colors: [const Color(0xFFEDCC61), const Color(0xFFE6BD55)],
        );
      case 512:
        return LinearGradient(
          colors: [const Color(0xFFEDC850), const Color(0xFFE6B944)],
        );
      case 1024:
        return LinearGradient(
          colors: [const Color(0xFFEDC53F), const Color(0xFFE6B633)],
        );
      case 2048:
        return LinearGradient(
          colors: [const Color(0xFFFFD700), const Color(0xFFFFC107)],
        );
      default:
        return LinearGradient(
          colors: [const Color(0xFF3C3A32), const Color(0xFF2C2A24)],
        );
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
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _controller.isWon ? Colors.amber : Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_controller.isWon ? Colors.amber : Colors.red)
                      .withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _controller.isWon
                  ? Icons.emoji_events
                  : Icons.sentiment_dissatisfied,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _controller.isWon ? 'You Win!' : 'Game Over!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Score: ${_controller.score}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOverlayButton(
                'Try Again',
                Icons.refresh,
                Colors.green,
                _newGame,
              ),
              if (_controller.isWon) ...[
                const SizedBox(width: 16),
                _buildOverlayButton(
                  'Continue',
                  Icons.play_arrow,
                  Colors.blue,
                  _continueGame,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            Color.fromRGBO(
              (color.red * 0.8).round().clamp(0, 255),
              (color.green * 0.8).round().clamp(0, 255),
              (color.blue * 0.8).round().clamp(0, 255),
              1.0,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Swipe to move tiles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Join numbers to reach 2048!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
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

  void _move(Direction direction) async {
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.help, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('How to Play'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionItem('🎯', 'Swipe to move tiles in any direction'),
            _buildInstructionItem(
                '✨', 'When two tiles with the same number touch, they merge'),
            _buildInstructionItem(
                '🏆', 'Try to create a tile with 2048 to win'),
            _buildInstructionItem(
                '🚀', 'Keep playing after winning for higher scores'),
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it!',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

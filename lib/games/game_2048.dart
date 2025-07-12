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
  late Animation<double> _scaleAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = Game2048Controller();
    _controller.initialize();
    _controller.addListener(_onGameStateChanged);

    // Animation controllers
    _scaleController = AnimationController(
      duration: GameConstants.game2048ScaleDuration,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: GameConstants.game2048MoveDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: GameConstants.game2048TileScaleAnimation,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});

      // Trigger animations for new tiles
      if (_controller.tiles.any((tile) => tile.isNew)) {
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(GameConstants.game2048BackgroundColorValue),
      appBar: AppBar(
        title: const Text('2048'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHowToPlay,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildScoreSection(),
              const SizedBox(height: 20),
              _buildGameControls(),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: _buildGameBoard(),
                ),
              ),
              const SizedBox(height: 20),
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreCard(
          title: AppStrings.score,
          value: _controller.score,
          color: AppTheme.primaryColor,
        ),
        _buildScoreCard(
          title: AppStrings.bestScore,
          value: _controller.bestScore,
          color: AppTheme.secondaryColor,
        ),
      ],
    );
  }

  Widget _buildScoreCard({
    required String title,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppConstants.fontM,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppConstants.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.refresh,
          label: AppStrings.newGame,
          onPressed: _newGame,
          color: AppTheme.primaryColor,
        ),
        _buildControlButton(
          icon: Icons.undo,
          label: AppStrings.undo,
          onPressed: _controller.canUndo ? _undo : null,
          color: AppTheme.secondaryColor,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final boardSize = size * 0.9;
        final tileSize = (boardSize - 40) / 4 - 8;

        return Stack(
          children: [
            _buildGridBackground(boardSize, tileSize),
            _buildTiles(boardSize, tileSize),
            _buildGameOverlay(boardSize),
          ],
        );
      },
    );
  }

  Widget _buildGridBackground(double boardSize, double tileSize) {
    return GestureDetector(
      onPanEnd: _handlePanEnd,
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          color: const Color(GameConstants.game2048GridColorValue),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(GameConstants.game2048EmptyTileColorValue),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
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
      curve: Curves.easeInOut,
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
                color: tile.color,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  tile.value.toString(),
                  style: TextStyle(
                    color: tile.textColor,
                    fontSize: tile.fontSize * (tileSize / 80),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameOverlay(double boardSize) {
    if (!_controller.isGameOver && !_controller.isWon) {
      return const SizedBox.shrink();
    }

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _controller.isWon ? Icons.emoji_events : Icons.dangerous,
            size: 80,
            color: _controller.isWon ? Colors.amber : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _controller.isWon ? AppStrings.youWin : AppStrings.gameOver,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppConstants.fontXXXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: ${_controller.score}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: AppConstants.fontXL,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _newGame,
                child: const Text(AppStrings.tryAgain),
              ),
              if (_controller.isWon) ...[
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _continueGame,
                  child: const Text(AppStrings.keepGoing),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppStrings.swipeToMove,
            style: TextStyle(
              fontSize: AppConstants.fontL,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.joinNumbers,
            style: TextStyle(
              fontSize: AppConstants.fontM,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Offset _getTilePosition(
      Position position, double boardSize, double tileSize) {
    final padding = 8.0;
    final spacing = 8.0;
    final x = padding + position.col * (tileSize + spacing);
    final y = padding + position.row * (tileSize + spacing);
    return Offset(x, y);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isAnimating) return;

    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx;
    final dy = velocity.dy;

    if (dx.abs() > dy.abs()) {
      if (dx > GameConstants.game2048SwipeVelocityThreshold) {
        _move(Direction.right);
      } else if (dx < -GameConstants.game2048SwipeVelocityThreshold) {
        _move(Direction.left);
      }
    } else {
      if (dy > GameConstants.game2048SwipeVelocityThreshold) {
        _move(Direction.down);
      } else if (dy < -GameConstants.game2048SwipeVelocityThreshold) {
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
        title: const Text(AppStrings.howToPlay),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.game2048Instructions),
            const SizedBox(height: 16),
            const Text('• Swipe up, down, left, or right to move tiles'),
            const SizedBox(height: 8),
            const Text(
                '• When two tiles with the same number touch, they merge into one'),
            const SizedBox(height: 8),
            const Text('• Try to create a tile with the number 2048 to win!'),
            const SizedBox(height: 8),
            const Text(
                '• Keep playing after winning to get even higher scores'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

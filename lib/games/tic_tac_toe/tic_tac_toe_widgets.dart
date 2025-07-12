import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'tic_tac_toe_models.dart';
import 'tic_tac_toe_constants.dart';

/// Custom game grid cell widget for Tic Tac Toe
class TicTacToeCell extends StatefulWidget {
  final Player player;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isWinningCell;

  const TicTacToeCell({
    super.key,
    required this.player,
    this.onTap,
    this.isEnabled = true,
    this.isWinningCell = false,
  });

  @override
  State<TicTacToeCell> createState() => _TicTacToeCellState();
}

class _TicTacToeCellState extends State<TicTacToeCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: TicTacToeConstants.cellTapDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isEnabled && widget.onTap != null) {
      HapticFeedback.lightImpact();
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isWinningCell
                      ? Theme.of(context).primaryColor.withOpacity(0.3)
                      : Theme.of(context).cardColor,
                  border: Border.all(
                    color: widget.isWinningCell
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius:
                      BorderRadius.circular(TicTacToeConstants.gameCellRadius),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: TicTacToeConstants.cellTapDuration,
                    child: Text(
                      widget.player.symbol,
                      key: ValueKey(widget.player),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: widget.player == Player.x
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Game mode selection card widget
class GameModeCard extends StatelessWidget {
  final GameMode gameMode;
  final VoidCallback onTap;
  final bool isSelected;

  const GameModeCard({
    super.key,
    required this.gameMode,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getGameModeIcon(gameMode),
              size: AppConstants.iconXL,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              gameMode.displayName,
              style: TextStyle(
                fontSize: AppConstants.fontL,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              gameMode.description,
              style: TextStyle(
                fontSize: AppConstants.fontM,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGameModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.humanVsHuman:
        return Icons.people;
      case GameMode.humanVsComputer:
        return Icons.computer;
      case GameMode.computerVsComputer:
        return Icons.psychology;
    }
  }
}

/// Game status display widget
class GameStatusWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;

  const GameStatusWidget({
    super.key,
    required this.message,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: color ?? Theme.of(context).dividerColor,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color ?? Theme.of(context).iconTheme.color,
              size: AppConstants.iconL,
            ),
            const SizedBox(width: AppConstants.spacingM),
          ],
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: AppConstants.fontL,
                fontWeight: FontWeight.bold,
                color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Game board widget for Tic Tac Toe
class TicTacToeBoard extends StatelessWidget {
  final GameBoard board;
  final Function(int) onCellTap;
  final bool isEnabled;
  final List<int> winningCells;

  const TicTacToeBoard({
    super.key,
    required this.board,
    required this.onCellTap,
    this.isEnabled = true,
    this.winningCells = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 300,
        maxHeight: 300,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: TicTacToeConstants.boardSize,
            childAspectRatio: 1.0,
            crossAxisSpacing: TicTacToeConstants.gameGridSpacing,
            mainAxisSpacing: TicTacToeConstants.gameGridSpacing,
          ),
          itemCount: TicTacToeConstants.totalCells,
          itemBuilder: (context, index) {
            final player = board.getPlayerAt(index);
            final isWinningCell = winningCells.contains(index);
            return TicTacToeCell(
              player: player,
              onTap: () => onCellTap(index),
              isEnabled: isEnabled && player == Player.none,
              isWinningCell: isWinningCell,
            );
          },
        ),
      ),
    );
  }
}

/// Game action buttons widget
class GameActionButtons extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onChangeMode;
  final bool isEnabled;

  const GameActionButtons({
    super.key,
    required this.onReset,
    required this.onChangeMode,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AnimatedGameButton(
          text: TicTacToeStrings.resetGame,
          icon: Icons.refresh,
          backgroundColor: AppTheme.warningColor,
          width: AppConstants.buttonWidth * 0.8,
          height: AppConstants.buttonHeight,
          onPressed: isEnabled ? onReset : null,
          semanticLabel: TicTacToeStrings.resetButton,
        ),
        AnimatedGameButton(
          text: TicTacToeStrings.changeMode,
          icon: Icons.settings,
          backgroundColor: AppTheme.infoColor,
          width: AppConstants.buttonWidth * 0.8,
          height: AppConstants.buttonHeight,
          onPressed: isEnabled ? onChangeMode : null,
          semanticLabel: TicTacToeStrings.changeModeButton,
        ),
      ],
    );
  }
}

/// Difficulty selection widget
class DifficultySelector extends StatelessWidget {
  final Difficulty currentDifficulty;
  final Function(Difficulty) onDifficultyChanged;

  const DifficultySelector({
    super.key,
    required this.currentDifficulty,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Difficulty',
          style: TextStyle(
            fontSize: AppConstants.fontL,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Wrap(
          spacing: AppConstants.spacingM,
          runSpacing: AppConstants.spacingM,
          children: Difficulty.values.map((difficulty) {
            final isSelected = difficulty == currentDifficulty;
            return GestureDetector(
              onTap: () => onDifficultyChanged(difficulty),
              child: AnimatedContainer(
                duration: AppConstants.shortAnimation,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingS,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: Text(
                  difficulty.displayName,
                  style: TextStyle(
                    fontSize: AppConstants.fontM,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

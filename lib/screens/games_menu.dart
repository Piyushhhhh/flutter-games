import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/game_models.dart';
import '../games/tic_tac_toe.dart';
import '../games/space_shooter.dart';

class GamesMenu extends StatelessWidget {
  const GamesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: AppStrings.appTitle,
      ),
      body: SafeArea(
        child: ResponsivePadding(
          child: Column(
            children: [
              // Header section
              _buildHeader(),

              const SizedBox(height: AppConstants.spacingXL),

              // Games list
              Expanded(
                child: _buildGamesList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: AppConstants.spacingL),

        // App icon
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          ),
          child: const Icon(
            Icons.games,
            size: AppConstants.iconXXXL,
            color: AppTheme.primaryColor,
          ),
        ),

        const SizedBox(height: AppConstants.spacingL),

        // Title
        Text(
          AppStrings.chooseGame,
          style: const TextStyle(
            fontSize: AppConstants.fontDisplay,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGamesList(BuildContext context) {
    final games = _getAvailableGames();

    return ListView.builder(
      padding: const EdgeInsets.only(top: AppConstants.spacingM),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return _buildGameCard(context, game);
      },
    );
  }

  Widget _buildGameCard(BuildContext context, GameItem game) {
    return GameCard(
      title: game.name,
      description: game.description,
      icon: _getGameIcon(game.iconName),
      color: _getGameColor(game.id),
      isEnabled: game.isAvailable,
      onTap: game.isAvailable ? () => _navigateToGame(context, game) : null,
      semanticLabel: '${game.name} - ${game.description}',
    );
  }

  void _navigateToGame(BuildContext context, GameItem game) {
    switch (game.id) {
      case 'tic_tac_toe':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TicTacToeGame(),
          ),
        );
        break;
      case 'space_shooter':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SpaceShooterGame(),
          ),
        );
        break;
      // Add more games here as they are implemented
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${game.name} is not implemented yet'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  List<GameItem> _getAvailableGames() {
    return [
      const GameItem(
        id: 'tic_tac_toe',
        name: AppStrings.ticTacToe,
        description: AppStrings.ticTacToeDescription,
        iconName: 'grid_3x3',
        isAvailable: true,
      ),
      const GameItem(
        id: 'space_shooter',
        name: AppStrings.spaceShooter,
        description: AppStrings.spaceShooterDescription,
        iconName: 'rocket_launch',
        isAvailable: true,
      ),
      const GameItem(
        id: 'snake',
        name: AppStrings.snakeGame,
        description: AppStrings.snakeDescription,
        iconName: 'games',
        isAvailable: false,
      ),
      const GameItem(
        id: '2048',
        name: AppStrings.game2048,
        description: AppStrings.game2048Description,
        iconName: 'apps',
        isAvailable: false,
      ),
      const GameItem(
        id: 'memory_match',
        name: AppStrings.memoryMatch,
        description: AppStrings.memoryDescription,
        iconName: 'memory',
        isAvailable: false,
      ),
    ];
  }

  IconData _getGameIcon(String iconName) {
    switch (iconName) {
      case 'grid_3x3':
        return Icons.grid_3x3;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'games':
        return Icons.games;
      case 'apps':
        return Icons.apps;
      case 'memory':
        return Icons.memory;
      default:
        return Icons.videogame_asset;
    }
  }

  Color _getGameColor(String gameId) {
    switch (gameId) {
      case 'tic_tac_toe':
        return AppTheme.primaryColor;
      case 'space_shooter':
        return AppTheme.accentColor;
      case 'snake':
        return AppTheme.successColor;
      case '2048':
        return AppTheme.warningColor;
      case 'memory_match':
        return AppTheme.infoColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}

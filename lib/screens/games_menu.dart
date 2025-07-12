import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/game_models.dart';
import '../games/tic_tac_toe.dart';
import '../games/game_2048.dart';

class GamesMenu extends StatefulWidget {
  const GamesMenu({super.key});

  @override
  State<GamesMenu> createState() => _GamesMenuState();
}

class _GamesMenuState extends State<GamesMenu> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
            Color(0xFF6B73FF),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                const SizedBox(height: 100), // Space for page title overlay
                _buildHeader(),
                Expanded(
                  child: _buildGamesList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // App icon with floating animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.games,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          Text(
            'Select your next adventure',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    final games = _getAvailableGames();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: _buildInteractiveGameCard(games[index], index),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveGameCard(GameItem game, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (game.isAvailable) {
              _navigateToGame(context, game);
            } else {
              _showComingSoonDialog(game.name);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: game.isAvailable
                  ? _getGameGradient(game.id)
                  : LinearGradient(
                      colors: [Colors.grey.shade200, Colors.grey.shade300],
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: game.isAvailable
                      ? _getGameColor(game.id).withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
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
            child: Row(
              children: [
                // Icon container with glow effect
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withOpacity(game.isAvailable ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: game.isAvailable
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _getGameIcon(game.iconName),
                    size: 32,
                    color:
                        game.isAvailable ? Colors.white : Colors.grey.shade500,
                  ),
                ),

                const SizedBox(width: 20),

                // Game info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              game.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: game.isAvailable
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          if (!game.isAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Soon',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: game.isAvailable
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow with bounce animation
                if (game.isAvailable)
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(10 * (1 - value), 0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, GameItem game) {
    // Add a cool transition animation
    switch (game.id) {
      case 'tic_tac_toe':
        _navigateWithAnimation(const TicTacToeGame());
        break;
      case '2048':
        _navigateWithAnimation(const Game2048());
        break;
      default:
        _showComingSoonDialog(game.name);
    }
  }

  void _navigateWithAnimation(Widget destination) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _showComingSoonDialog(String gameName) {
    HapticFeedback.lightImpact();
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
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hourglass_empty,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Coming Soon!'),
          ],
        ),
        content: Text(
          '$gameName is under development and will be available soon. Stay tuned for updates!',
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
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

  List<GameItem> _getAvailableGames() {
    return [
      const GameItem(
        id: 'tic_tac_toe',
        name: 'Tic Tac Toe',
        description: 'Classic 3x3 grid game',
        iconName: 'grid_3x3',
        isAvailable: true,
      ),
      const GameItem(
        id: 'space_shooter',
        name: 'Space Shooter',
        description: 'Defend Earth from alien invasion',
        iconName: 'rocket_launch',
        isAvailable: false,
      ),
      const GameItem(
        id: 'snake',
        name: 'Snake Game',
        description: 'Classic snake game',
        iconName: 'games',
        isAvailable: false,
      ),
      const GameItem(
        id: '2048',
        name: '2048',
        description: 'Slide to combine numbers',
        iconName: 'apps',
        isAvailable: true,
      ),
      const GameItem(
        id: 'memory_match',
        name: 'Memory Match',
        description: 'Match the cards',
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
        return Colors.deepPurple;
      case 'space_shooter':
        return Colors.pink;
      case 'snake':
        return Colors.green;
      case '2048':
        return Colors.orange;
      case 'memory_match':
        return Colors.blue;
      default:
        return Colors.deepPurple;
    }
  }

  Gradient _getGameGradient(String gameId) {
    switch (gameId) {
      case 'tic_tac_toe':
        return LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
        );
      case 'space_shooter':
        return LinearGradient(
          colors: [Colors.pink.shade400, Colors.pink.shade700],
        );
      case 'snake':
        return LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade700],
        );
      case '2048':
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade700],
        );
      case 'memory_match':
        return LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        );
      default:
        return LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/game_models.dart';
import '../games/tic_tac_toe/tic_tac_toe.dart';
import '../games/game_2048/game_2048.dart';
import '../games/space_invaders/space_invaders.dart';
import '../games/neon_runner/neon_runner.dart';
import '../games/cyber_quest/cyber_quest.dart';

class GamesMenu extends StatefulWidget {
  const GamesMenu({super.key});

  @override
  State<GamesMenu> createState() => _GamesMenuState();
}

class _GamesMenuState extends State<GamesMenu> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _neonController;
  late AnimationController _scanlineController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _neonAnimation;
  late Animation<double> _scanlineAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _neonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scanlineController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _neonAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _neonController,
      curve: Curves.easeInOut,
    ));

    _scanlineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanlineController,
      curve: Curves.linear,
    ));

    _fadeController.forward();
    _neonController.repeat(reverse: true);
    _scanlineController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _neonController.dispose();
    _scanlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D001A), // Deep purple
            Color(0xFF1A0033), // Purple-black
            Color(0xFF2D1B69), // Electric purple
            Color(0xFF000000), // Black
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Retro grid background
          _buildRetroGrid(),
          // CRT scanlines effect
          _buildScanlines(),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    _buildRetroHeader(),
                    _buildRetroSearchBar(),
                    _buildRetroGamesList(),
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: RetroGridPainter(),
    );
  }

  Widget _buildScanlines() {
    return AnimatedBuilder(
      animation: _scanlineAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFF00FFFF).withOpacity(0.05),
                Colors.transparent,
              ],
              stops: [
                (_scanlineAnimation.value - 0.1).clamp(0.0, 1.0),
                _scanlineAnimation.value,
                (_scanlineAnimation.value + 0.1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRetroHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Neon logo
          AnimatedBuilder(
            animation: _neonAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00FFFF),
                    width: 2,
                  ),
                  borderRadius:
                      BorderRadius.circular(0), // Sharp corners for retro feel
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF)
                          .withOpacity(_neonAnimation.value * 0.8),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF0080)
                          .withOpacity(_neonAnimation.value * 0.6),
                      blurRadius: 30,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videogame_asset,
                      size: 40,
                      color: Color.lerp(
                        const Color(0xFF00FFFF),
                        const Color(0xFFFF0080),
                        _neonAnimation.value,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'RETRO ARCADE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Color.lerp(
                          const Color(0xFF00FFFF),
                          const Color(0xFFFF0080),
                          _neonAnimation.value,
                        ),
                        shadows: [
                          Shadow(
                            color: const Color(0xFF00FFFF)
                                .withOpacity(_neonAnimation.value),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'SELECT YOUR GAME',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: const Color(0xFF00FF00).withOpacity(0.8),
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: const Color(0xFF00FF00).withOpacity(0.5),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: const Color(0xFF00FFFF),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFFF).withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: TextField(
          style: const TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: 'monospace',
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: '> SEARCH GAMES_',
            hintStyle: TextStyle(
              color: const Color(0xFF00FF00).withOpacity(0.5),
              fontFamily: 'monospace',
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF00FFFF),
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildRetroGamesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border.all(
          color: const Color(0xFF00FFFF),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2D1B69),
                  Color(0xFF5B2C87),
                ],
              ),
            ),
            child: const Text(
              'GAME LIBRARY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: Color(0xFF00FFFF),
                letterSpacing: 2,
              ),
            ),
          ),
          // Games list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRetroGameCard(
                  'TIC TAC TOE',
                  'CLASSIC STRATEGY',
                  const Color(0xFF00FFFF),
                  const Color(0xFFFF0080),
                  true,
                  'tic_tac_toe',
                ),
                const SizedBox(height: 16),
                _buildRetroGameCard(
                  '2048',
                  'PUZZLE FUSION',
                  const Color(0xFF00FF00),
                  const Color(0xFFFFFF00),
                  true,
                  '2048',
                ),
                const SizedBox(height: 16),
                _buildRetroGameCard(
                  'SPACE INVADERS',
                  'ARCADE CLASSIC',
                  const Color(0xFFFF0080),
                  const Color(0xFF8A2BE2),
                  true,
                  'space_invaders',
                ),
                const SizedBox(height: 16),
                _buildRetroGameCard(
                  'NEON RUNNER',
                  'ENDLESS CHASE',
                  const Color(0xFFFFFF00),
                  const Color(0xFFFF4500),
                  false,
                  'neon_runner',
                ),
                const SizedBox(height: 16),
                _buildRetroGameCard(
                  'CYBER QUEST',
                  'RPG ADVENTURE',
                  const Color(0xFF8A2BE2),
                  const Color(0xFF00FFFF),
                  false,
                  'cyber_quest',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroGameCard(String title, String subtitle, Color primaryColor,
      Color accentColor, bool isAvailable, String gameId) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        if (isAvailable) {
          _navigateToGame(gameId);
        } else {
          _showRetroComingSoonDialog(title);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: isAvailable ? primaryColor : const Color(0xFF444444),
            width: 2,
          ),
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Game icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isAvailable
                    ? primaryColor.withOpacity(0.2)
                    : const Color(0xFF222222),
                border: Border.all(
                  color: isAvailable ? primaryColor : const Color(0xFF444444),
                  width: 2,
                ),
              ),
              child: Icon(
                _getGameIcon(gameId),
                size: 30,
                color: isAvailable ? primaryColor : const Color(0xFF666666),
              ),
            ),
            const SizedBox(width: 16),
            // Game info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color:
                          isAvailable ? primaryColor : const Color(0xFF666666),
                      shadows: isAvailable
                          ? [
                              Shadow(
                                color: primaryColor.withOpacity(0.5),
                                blurRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: isAvailable
                          ? accentColor.withOpacity(0.8)
                          : const Color(0xFF444444),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAvailable
                    ? primaryColor.withOpacity(0.2)
                    : const Color(0xFF222222),
                border: Border.all(
                  color: isAvailable ? primaryColor : const Color(0xFF444444),
                  width: 1,
                ),
              ),
              child: Text(
                isAvailable ? 'READY' : 'LOCKED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: isAvailable ? primaryColor : const Color(0xFF666666),
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Play button
            if (isAvailable)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  border: Border.all(
                    color: primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: primaryColor,
                  size: 20,
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  border: Border.all(
                    color: const Color(0xFF444444),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.lock,
                  color: Color(0xFF666666),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getGameIcon(String gameId) {
    switch (gameId) {
      case 'tic_tac_toe':
        return Icons.grid_3x3;
      case '2048':
        return Icons.apps;
      case 'space_invaders':
        return Icons.rocket_launch;
      case 'neon_runner':
        return Icons.directions_run;
      case 'cyber_quest':
        return Icons.psychology;
      default:
        return Icons.games;
    }
  }

  void _navigateToGame(String gameId) {
    Widget? gameWidget;

    switch (gameId) {
      case 'tic_tac_toe':
        gameWidget = const TicTacToeScreen();
        break;
      case '2048':
        gameWidget = const Game2048Screen();
        break;
      case 'space_invaders':
        gameWidget = const SpaceInvadersScreen();
        break;
      case 'neon_runner':
      case 'cyber_quest':
      default:
        _showRetroComingSoonDialog(gameId);
        return;
    }

    if (gameWidget != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => gameWidget!,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
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
  }

  void _showRetroComingSoonDialog(String gameName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: const Color(0xFF00FFFF),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SYSTEM MESSAGE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Color(0xFF00FFFF),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 2,
                color: const Color(0xFF00FFFF),
              ),
              const SizedBox(height: 16),
              Text(
                'GAME: $gameName',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace',
                  color: Color(0xFF00FF00),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'STATUS: UNDER DEVELOPMENT',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  color: Color(0xFFFFFF00),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AVAILABILITY: COMING SOON',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  color: Color(0xFFFF0080),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFFF).withOpacity(0.2),
                    border: Border.all(
                      color: const Color(0xFF00FFFF),
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    'ACKNOWLEDGE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Color(0xFF00FFFF),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RetroGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double gridSize = 30;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
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

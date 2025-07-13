/// 2048 Game Module
///
/// This module provides a complete 2048 game implementation with:
/// - Swipe-based tile movement
/// - Tile merging and scoring system
/// - Undo functionality
/// - Best score tracking
/// - Game over and win conditions
/// - Responsive grid layout
///
/// Usage:
/// ```dart
/// import 'package:flutter_games/games/game_2048/game_2048.dart';
///
/// // Navigate to the game
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const Game2048Screen()),
/// );
/// ```
library game_2048;

// Export all public interfaces
export 'views/game_2048_screen.dart';
export 'controllers/game_2048_controller.dart';

/// Tic Tac Toe Game Module
///
/// This module provides a complete Tic Tac Toe game implementation with:
/// - Multiple game modes (Human vs Human, Human vs Computer, Computer vs Computer)
/// - Difficulty levels for AI opponents
/// - Game state management and history tracking
/// - Responsive UI with animations and haptic feedback
/// - Score tracking and statistics
///
/// Usage:
/// ```dart
/// import 'package:flutter_games/games/tic_tac_toe/tic_tac_toe.dart';
///
/// // Navigate to the game
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const TicTacToeScreen()),
/// );
/// ```

// Export all public interfaces
export 'tic_tac_toe_screen.dart';
export 'tic_tac_toe_models.dart';
export 'tic_tac_toe_game.dart';
export 'tic_tac_toe_widgets.dart';
export 'tic_tac_toe_constants.dart';

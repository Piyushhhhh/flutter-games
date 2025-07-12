import 'tic_tac_toe_models.dart';
import 'tic_tac_toe_constants.dart';

/// Game logic and AI controller for Tic Tac Toe
class TicTacToeGameController {
  /// Check if the game result for the given board
  static GameResult checkGameResult(GameBoard board) {
    // Check all winning combinations
    for (List<int> combination in TicTacToeConstants.winningCombinations) {
      final player1 = board.getPlayerAt(combination[0]);
      final player2 = board.getPlayerAt(combination[1]);
      final player3 = board.getPlayerAt(combination[2]);

      if (player1 != Player.none && player1 == player2 && player2 == player3) {
        return player1 == Player.x
            ? GameResult.playerXWins
            : GameResult.playerOWins;
      }
    }

    // Check for draw
    if (board.isFull) {
      return GameResult.draw;
    }

    return GameResult.ongoing;
  }

  /// Get the best move for the computer player using minimax algorithm
  static int getBestMove(GameBoard board, Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return _getRandomMove(board);
      case Difficulty.medium:
        return _getMediumMove(board);
      case Difficulty.hard:
      case Difficulty.expert:
        return _getHardMove(board);
    }
  }

  /// Get a random valid move (Easy difficulty)
  static int _getRandomMove(GameBoard board) {
    final emptyPositions = board.emptyPositions;
    if (emptyPositions.isEmpty) return 0;

    emptyPositions.shuffle();
    return emptyPositions.first;
  }

  /// Get a strategic move (Medium difficulty)
  static int _getMediumMove(GameBoard board) {
    // 1. Try to win
    for (int i = 0; i < TicTacToeConstants.totalCells; i++) {
      if (board.isValidMove(i)) {
        final testBoard = board.makeMove(i, Player.o);
        if (checkGameResult(testBoard) == GameResult.playerOWins) {
          return i;
        }
      }
    }

    // 2. Block opponent from winning
    for (int i = 0; i < TicTacToeConstants.totalCells; i++) {
      if (board.isValidMove(i)) {
        final testBoard = board.makeMove(i, Player.x);
        if (checkGameResult(testBoard) == GameResult.playerXWins) {
          return i;
        }
      }
    }

    // 3. Take center if available
    if (board.isValidMove(TicTacToeConstants.centerPosition)) {
      return TicTacToeConstants.centerPosition;
    }

    // 4. Take corners
    for (int corner in TicTacToeConstants.corners) {
      if (board.isValidMove(corner)) {
        return corner;
      }
    }

    // 5. Take any remaining spot
    final emptyPositions = board.emptyPositions;
    if (emptyPositions.isNotEmpty) {
      return emptyPositions.first;
    }

    return 0; // Fallback
  }

  /// Get optimal move using minimax algorithm (Hard/Expert difficulty)
  static int _getHardMove(GameBoard board) {
    int bestScore = -1000;
    int bestMove = 0;

    for (int i = 0; i < TicTacToeConstants.totalCells; i++) {
      if (board.isValidMove(i)) {
        final testBoard = board.makeMove(i, Player.o);
        final score = _minimax(testBoard, 0, false);
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }

    return bestMove;
  }

  /// Minimax algorithm implementation
  static int _minimax(GameBoard board, int depth, bool isMaximizing) {
    final result = checkGameResult(board);

    if (result == GameResult.playerOWins) return 10 - depth;
    if (result == GameResult.playerXWins) return depth - 10;
    if (result == GameResult.draw) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < TicTacToeConstants.totalCells; i++) {
        if (board.isValidMove(i)) {
          final testBoard = board.makeMove(i, Player.o);
          final score = _minimax(testBoard, depth + 1, false);
          bestScore = _max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < TicTacToeConstants.totalCells; i++) {
        if (board.isValidMove(i)) {
          final testBoard = board.makeMove(i, Player.x);
          final score = _minimax(testBoard, depth + 1, true);
          bestScore = _min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  /// Helper function to get maximum of two integers
  static int _max(int a, int b) => a > b ? a : b;

  /// Helper function to get minimum of two integers
  static int _min(int a, int b) => a < b ? a : b;

  /// Validate a move
  static bool isValidMove(GameBoard board, int position) {
    return board.isValidMove(position);
  }

  /// Make a move on the board
  static GameBoard makeMove(GameBoard board, int position, Player player) {
    return board.makeMove(position, player);
  }

  /// Check if the game should end
  static bool isGameOver(GameResult result) {
    return result != GameResult.ongoing;
  }

  /// Get winning positions for a specific result
  static List<int> getWinningPositions(GameBoard board, GameResult result) {
    if (result == GameResult.ongoing || result == GameResult.draw) {
      return [];
    }

    final winningPlayer =
        result == GameResult.playerXWins ? Player.x : Player.o;

    for (List<int> combination in TicTacToeConstants.winningCombinations) {
      final player1 = board.getPlayerAt(combination[0]);
      final player2 = board.getPlayerAt(combination[1]);
      final player3 = board.getPlayerAt(combination[2]);

      if (player1 == winningPlayer &&
          player1 == player2 &&
          player2 == player3) {
        return combination;
      }
    }

    return [];
  }

  /// Calculate game score based on result and moves
  static int calculateScore(
      GameResult result, int moveCount, Duration gameDuration) {
    int baseScore = 0;

    switch (result) {
      case GameResult.playerXWins:
        baseScore = 100;
        break;
      case GameResult.playerOWins:
        baseScore = 50; // Less score for computer win in human vs computer
        break;
      case GameResult.draw:
        baseScore = 75;
        break;
      case GameResult.ongoing:
        baseScore = 0;
        break;
    }

    // Bonus for finishing quickly
    final timeBonus = (60 - gameDuration.inSeconds).clamp(0, 30);

    // Bonus for efficient play (fewer moves)
    final moveBonus = (10 - moveCount).clamp(0, 5) * 5;

    return baseScore + timeBonus + moveBonus;
  }
}

/// Tic Tac Toe game-specific constants
class TicTacToeConstants {
  // Private constructor to prevent instantiation
  TicTacToeConstants._();

  // Game Logic Constants
  static const String playerX = 'X';
  static const String playerO = 'O';
  static const String emptyCell = '';
  static const int totalCells = 9;
  static const int winCondition = 3;
  static const int boardSize = 3;

  // Computer AI delays
  static const Duration computerThinkingDelay = Duration(milliseconds: 800);
  static const Duration computerMoveDelay = Duration(milliseconds: 200);

  // Game grid positions
  static const List<int> corners = [0, 2, 6, 8];
  static const int centerPosition = 4;
  static const List<List<int>> winningCombinations = [
    // Rows
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    // Columns
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    // Diagonals
    [0, 4, 8],
    [2, 4, 6],
  ];

  // UI Constants
  static const double gameGridSpacing = 4.0;
  static const double gameCellSize = 80.0;
  static const double gameGridRadius = 8.0;
  static const double gameCellRadius = 4.0;

  // Animation Durations
  static const Duration cellTapDuration = Duration(milliseconds: 150);
  static const Duration gameOverDuration = Duration(milliseconds: 300);
  static const Duration statusChangeDuration = Duration(milliseconds: 200);
}

/// String constants for Tic Tac Toe game
class TicTacToeStrings {
  // Private constructor to prevent instantiation
  TicTacToeStrings._();

  // Game Title
  static const String gameTitle = 'Tic Tac Toe';
  static const String gameDescription = 'Classic 3x3 grid game';

  // Game Modes
  static const String chooseGameMode = 'Choose Game Mode';
  static const String humanVsHuman = 'Human vs Human';
  static const String humanVsComputer = 'Human vs Computer';
  static const String computerVsComputer = 'Computer vs Computer';

  // Game Mode Descriptions
  static const String humanVsHumanDesc = 'Play with a friend';
  static const String humanVsComputerDesc = 'Challenge the AI';
  static const String computerVsComputerDesc = 'Watch AI battle';

  // Game Status Messages
  static const String playerWon = 'Player won!';
  static const String computerWon = 'Computer won!';
  static const String xWins = 'X wins!';
  static const String oWins = 'O wins!';
  static const String draw = 'It\'s a Draw!';
  static const String yourTurn = 'Your turn (X)';
  static const String computerTurn = 'Computer\'s turn (O)';
  static const String currentPlayer = 'Current Player';
  static const String computerThinking = 'Computer is thinking...';

  // Actions
  static const String resetGame = 'Reset Game';
  static const String changeMode = 'Change Mode';
  static const String newGame = 'New Game';
  static const String back = 'Back';

  // Accessibility
  static const String ticTacToeGrid = 'Tic Tac Toe game grid';
  static const String gameCell = 'Game cell';
  static const String gameCellEmpty = 'Empty game cell';
  static const String gameCellX = 'Game cell with X';
  static const String gameCellO = 'Game cell with O';
  static const String resetButton = 'Reset game button';
  static const String changeModeButton = 'Change mode button';
  static const String gameModeButton = 'Game mode selection button';
}

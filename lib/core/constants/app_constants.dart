/// App constants for consistent values across the application
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App Information
  static const String appName = 'Flutter Games';
  static const String appVersion = '1.0.0';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Icon Sizes
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 80.0;
  static const double iconXXXL = 100.0;

  // Font Sizes
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 20.0;
  static const double fontXXXL = 24.0;
  static const double fontTitle = 28.0;
  static const double fontDisplay = 32.0;

  // Button Sizes
  static const double buttonHeight = 48.0;
  static const double buttonHeightLarge = 60.0;
  static const double buttonWidth = 200.0;
  static const double buttonWidthLarge = 280.0;

  // Game Grid
  static const int ticTacToeGridSize = 3;
  static const double gameGridSpacing = 4.0;
  static const double gameCellSize = 80.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}

/// String constants for the application
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // General
  static const String appTitle = 'Flutter Games';
  static const String chooseGame = 'Choose a Game';
  static const String comingSoon = 'Coming Soon!';
  static const String resetGame = 'Reset Game';
  static const String changeMode = 'Change Mode';
  static const String back = 'Back';

  // Game Modes
  static const String chooseGameMode = 'Choose Game Mode';
  static const String humanVsHuman = 'Human vs Human';
  static const String humanVsComputer = 'Human vs Computer';

  // Tic Tac Toe
  static const String ticTacToe = 'Tic Tac Toe';
  static const String ticTacToeDescription = 'Classic 3x3 grid game';
  static const String playerWon = 'Player won!';
  static const String computerWon = 'Computer won!';
  static const String draw = 'It\'s a Draw!';
  static const String winner = 'Winner';
  static const String yourTurn = 'Your turn (X)';
  static const String computerTurn = 'Computer\'s turn (O)';
  static const String currentPlayer = 'Current Player';
  static const String computerThinking = 'Computer is thinking...';

  // Game Names
  static const String spaceShooter = 'Space Shooter';
  static const String snakeGame = 'Snake Game';
  static const String game2048 = '2048';
  static const String memoryMatch = 'Memory Match';

  // Game Descriptions
  static const String spaceShooterDescription =
      'Defend Earth from alien invasion';
  static const String snakeDescription = 'Classic snake game';
  static const String game2048Description = 'Slide to combine numbers';
  static const String memoryDescription = 'Match the cards';

  // Accessibility
  static const String ticTacToeGrid = 'Tic Tac Toe game grid';
  static const String gameCell = 'Game cell';
  static const String menuButton = 'Menu button';
  static const String gameButton = 'Game button';

  // 2048 Game Strings
  static const String game2048Title = '2048';
  static const String game2048Subtitle =
      'Slide to combine numbers and reach 2048!';
  static const String score = 'Score';
  static const String bestScore = 'Best';
  static const String gameOver = 'Game Over!';
  static const String youWin = 'You Win!';
  static const String tryAgain = 'Try Again';
  static const String newGame = 'New Game';
  static const String undo = 'Undo';
  static const String continueGame = 'Continue';
  static const String keepGoing = 'Keep Going';
  static const String swipeToMove = 'Swipe to move tiles';
  static const String joinNumbers = 'Join numbers to reach 2048!';
  static const String howToPlay = 'How to Play';
  static const String game2048Instructions =
      'Swipe to move tiles. When two tiles with the same number touch, they merge into one!';
}

/// Game-specific constants
class GameConstants {
  // Private constructor to prevent instantiation
  GameConstants._();

  // Tic Tac Toe
  static const String playerX = 'X';
  static const String playerO = 'O';
  static const String emptyCell = '';
  static const int totalCells = 9;
  static const int winCondition = 3;

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

  // === 2048 Game Constants ===

  // Grid Configuration
  static const int game2048GridSize = 4;
  static const int game2048TotalCells = 16;
  static const double game2048GridSpacing = 8.0;
  static const double game2048TileSize = 70.0;
  static const double game2048GridPadding = 16.0;
  static const double game2048GridRadius = 8.0;
  static const double game2048TileRadius = 4.0;

  // Animation Durations
  static const Duration game2048MoveDuration = Duration(milliseconds: 150);
  static const Duration game2048MergeDuration = Duration(milliseconds: 100);
  static const Duration game2048AppearDuration = Duration(milliseconds: 200);
  static const Duration game2048ScaleDuration = Duration(milliseconds: 100);

  // Game Logic
  static const int game2048WinValue = 2048;
  static const int game2048InitialTileCount = 2;
  static const double game2048NewTileChance =
      0.9; // 90% chance for 2, 10% for 4

  // Scoring
  static const int game2048MergeScoreMultiplier = 1;
  static const int game2048BonusScoreThreshold = 2048;
  static const int game2048BonusScore = 1000;

  // Swipe Thresholds
  static const double game2048SwipeThreshold = 50.0;
  static const double game2048SwipeVelocityThreshold = 300.0;

  // Visual Effects
  static const double game2048TileScaleAnimation = 1.1;
  static const double game2048NewTileScale = 0.0;
  static const double game2048MergeTileScale = 1.2;

  // Grid Colors
  static const int game2048GridColorValue = 0xFFBBADA0;
  static const int game2048EmptyTileColorValue = 0xFFCDC1B4;
  static const int game2048BackgroundColorValue = 0xFFFAF8EF;

  // SharedPreferences Keys
  static const String game2048BestScoreKey = 'game_2048_best_score';
  static const String game2048GameStateKey = 'game_2048_game_state';
  static const String game2048StatisticsKey = 'game_2048_statistics';

  // Tile Values
  static const List<int> game2048TileValues = [
    2,
    4,
    8,
    16,
    32,
    64,
    128,
    256,
    512,
    1024,
    2048,
    4096,
    8192,
    16384,
    32768,
    65536
  ];

  // Achievement Thresholds
  static const Map<int, String> game2048Achievements = {
    128: 'Getting Started',
    256: 'Building Up',
    512: 'Half Way There',
    1024: 'Almost There',
    2048: 'Winner!',
    4096: 'Overachiever',
    8192: 'Legendary',
    16384: 'Master',
    32768: 'Grandmaster',
    65536: 'Ultimate Champion',
  };
}

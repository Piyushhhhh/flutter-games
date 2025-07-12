import 'package:flutter/foundation.dart';

/// Enum for different game modes
enum GameMode {
  humanVsHuman,
  humanVsComputer,
  computerVsComputer,
}

/// Extension for GameMode to provide display names
extension GameModeExtension on GameMode {
  String get displayName {
    switch (this) {
      case GameMode.humanVsHuman:
        return 'Human vs Human';
      case GameMode.humanVsComputer:
        return 'Human vs Computer';
      case GameMode.computerVsComputer:
        return 'Computer vs Computer';
    }
  }

  String get description {
    switch (this) {
      case GameMode.humanVsHuman:
        return 'Play with a friend';
      case GameMode.humanVsComputer:
        return 'Challenge the AI';
      case GameMode.computerVsComputer:
        return 'Watch AI battle';
    }
  }
}

/// Enum for game state
enum GameState {
  initial,
  playing,
  paused,
  gameOver,
  thinking,
}

/// Enum for game result
enum GameResult {
  ongoing,
  playerXWins,
  playerOWins,
  draw,
}

/// Extension for GameResult to provide display messages
extension GameResultExtension on GameResult {
  String getMessage(GameMode gameMode) {
    switch (this) {
      case GameResult.ongoing:
        return '';
      case GameResult.playerXWins:
        return gameMode == GameMode.humanVsComputer ? 'Player won!' : 'X wins!';
      case GameResult.playerOWins:
        return gameMode == GameMode.humanVsComputer
            ? 'Computer won!'
            : 'O wins!';
      case GameResult.draw:
        return 'It\'s a draw!';
    }
  }
}

/// Enum for players
enum Player {
  x,
  o,
  none,
}

/// Extension for Player to provide display values
extension PlayerExtension on Player {
  String get symbol {
    switch (this) {
      case Player.x:
        return 'X';
      case Player.o:
        return 'O';
      case Player.none:
        return '';
    }
  }

  Player get opponent {
    switch (this) {
      case Player.x:
        return Player.o;
      case Player.o:
        return Player.x;
      case Player.none:
        return Player.none;
    }
  }
}

/// Enum for difficulty levels
enum Difficulty {
  easy,
  medium,
  hard,
  expert,
}

/// Extension for Difficulty to provide display names
extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  String get description {
    switch (this) {
      case Difficulty.easy:
        return 'Good for beginners';
      case Difficulty.medium:
        return 'Balanced gameplay';
      case Difficulty.hard:
        return 'Challenging opponent';
      case Difficulty.expert:
        return 'Nearly unbeatable';
    }
  }
}

/// Represents a move in the tic-tac-toe game
@immutable
class GameMove {
  final int position;
  final Player player;
  final DateTime timestamp;

  const GameMove({
    required this.position,
    required this.player,
    required this.timestamp,
  });

  /// Create a copy with modified values
  GameMove copyWith({
    int? position,
    Player? player,
    DateTime? timestamp,
  }) {
    return GameMove(
      position: position ?? this.position,
      player: player ?? this.player,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameMove &&
        other.position == position &&
        other.player == player;
  }

  @override
  int get hashCode => position.hashCode ^ player.hashCode;

  @override
  String toString() => 'GameMove(position: $position, player: $player)';
}

/// Represents the game board state
@immutable
class GameBoard {
  final List<Player> cells;
  final int size;

  const GameBoard({
    required this.cells,
    this.size = 3,
  });

  /// Create an empty board
  factory GameBoard.empty({int size = 3}) {
    return GameBoard(
      cells: List.filled(size * size, Player.none),
      size: size,
    );
  }

  /// Create a copy with a move applied
  GameBoard makeMove(int position, Player player) {
    if (position < 0 || position >= cells.length) {
      throw ArgumentError('Invalid position: $position');
    }

    if (cells[position] != Player.none) {
      throw ArgumentError('Position $position is already occupied');
    }

    final newCells = List<Player>.from(cells);
    newCells[position] = player;

    return GameBoard(
      cells: newCells,
      size: size,
    );
  }

  /// Check if a position is valid and empty
  bool isValidMove(int position) {
    return position >= 0 &&
        position < cells.length &&
        cells[position] == Player.none;
  }

  /// Get all empty positions
  List<int> get emptyPositions {
    return cells
        .asMap()
        .entries
        .where((entry) => entry.value == Player.none)
        .map((entry) => entry.key)
        .toList();
  }

  /// Check if the board is full
  bool get isFull => !cells.contains(Player.none);

  /// Check if the board is empty
  bool get isEmpty => cells.every((cell) => cell == Player.none);

  /// Get the player at a specific position
  Player getPlayerAt(int position) {
    if (position < 0 || position >= cells.length) {
      return Player.none;
    }
    return cells[position];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameBoard &&
        listEquals(other.cells, cells) &&
        other.size == size;
  }

  @override
  int get hashCode => Object.hashAll([cells, size]);

  @override
  String toString() => 'GameBoard(cells: $cells, size: $size)';
}

/// Represents the complete game state
@immutable
class TicTacToeGameState {
  final GameBoard board;
  final Player currentPlayer;
  final GameMode gameMode;
  final GameState state;
  final GameResult result;
  final List<GameMove> moveHistory;
  final Difficulty difficulty;
  final bool isComputerThinking;
  final Duration gameDuration;
  final int playerXScore;
  final int playerOScore;
  final int drawCount;

  const TicTacToeGameState({
    required this.board,
    required this.currentPlayer,
    required this.gameMode,
    required this.state,
    required this.result,
    required this.moveHistory,
    required this.difficulty,
    required this.isComputerThinking,
    required this.gameDuration,
    required this.playerXScore,
    required this.playerOScore,
    required this.drawCount,
  });

  /// Create initial game state
  factory TicTacToeGameState.initial({
    GameMode gameMode = GameMode.humanVsHuman,
    Difficulty difficulty = Difficulty.medium,
  }) {
    return TicTacToeGameState(
      board: GameBoard.empty(),
      currentPlayer: Player.x,
      gameMode: gameMode,
      state: GameState.initial,
      result: GameResult.ongoing,
      moveHistory: [],
      difficulty: difficulty,
      isComputerThinking: false,
      gameDuration: Duration.zero,
      playerXScore: 0,
      playerOScore: 0,
      drawCount: 0,
    );
  }

  /// Create a copy with modified values
  TicTacToeGameState copyWith({
    GameBoard? board,
    Player? currentPlayer,
    GameMode? gameMode,
    GameState? state,
    GameResult? result,
    List<GameMove>? moveHistory,
    Difficulty? difficulty,
    bool? isComputerThinking,
    Duration? gameDuration,
    int? playerXScore,
    int? playerOScore,
    int? drawCount,
  }) {
    return TicTacToeGameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      gameMode: gameMode ?? this.gameMode,
      state: state ?? this.state,
      result: result ?? this.result,
      moveHistory: moveHistory ?? this.moveHistory,
      difficulty: difficulty ?? this.difficulty,
      isComputerThinking: isComputerThinking ?? this.isComputerThinking,
      gameDuration: gameDuration ?? this.gameDuration,
      playerXScore: playerXScore ?? this.playerXScore,
      playerOScore: playerOScore ?? this.playerOScore,
      drawCount: drawCount ?? this.drawCount,
    );
  }

  /// Check if it's currently a human player's turn
  bool get isHumanTurn {
    switch (gameMode) {
      case GameMode.humanVsHuman:
        return true;
      case GameMode.humanVsComputer:
        return currentPlayer == Player.x;
      case GameMode.computerVsComputer:
        return false;
    }
  }

  /// Check if the game is over
  bool get isGameOver => state == GameState.gameOver;

  /// Check if the game is in progress
  bool get isPlaying => state == GameState.playing;

  /// Get the current status message
  String get statusMessage {
    if (result != GameResult.ongoing) {
      return result.getMessage(gameMode);
    }

    if (isComputerThinking) {
      return 'Computer is thinking...';
    }

    switch (gameMode) {
      case GameMode.humanVsHuman:
        return 'Current Player: ${currentPlayer.symbol}';
      case GameMode.humanVsComputer:
        return currentPlayer == Player.x
            ? 'Your turn (X)'
            : 'Computer\'s turn (O)';
      case GameMode.computerVsComputer:
        return 'Computer ${currentPlayer.symbol} is thinking...';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicTacToeGameState &&
        other.board == board &&
        other.currentPlayer == currentPlayer &&
        other.gameMode == gameMode &&
        other.state == state &&
        other.result == result &&
        listEquals(other.moveHistory, moveHistory) &&
        other.difficulty == difficulty &&
        other.isComputerThinking == isComputerThinking &&
        other.gameDuration == gameDuration &&
        other.playerXScore == playerXScore &&
        other.playerOScore == playerOScore &&
        other.drawCount == drawCount;
  }

  @override
  int get hashCode => Object.hashAll([
        board,
        currentPlayer,
        gameMode,
        state,
        result,
        moveHistory,
        difficulty,
        isComputerThinking,
        gameDuration,
        playerXScore,
        playerOScore,
        drawCount,
      ]);

  @override
  String toString() =>
      'TicTacToeGameState(board: $board, currentPlayer: $currentPlayer, gameMode: $gameMode, state: $state, result: $result)';
}

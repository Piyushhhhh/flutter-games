/// Game-related data models and enums
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Added for Color

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
      'TicTacToeGameState(currentPlayer: $currentPlayer, state: $state)';
}

/// Represents a game item in the menu
@immutable
class GameItem {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final bool isAvailable;
  final String? route;

  const GameItem({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.isAvailable,
    this.route,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameItem &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.iconName == iconName &&
        other.isAvailable == isAvailable &&
        other.route == route;
  }

  @override
  int get hashCode =>
      Object.hashAll([id, name, description, iconName, isAvailable, route]);

  @override
  String toString() =>
      'GameItem(id: $id, name: $name, isAvailable: $isAvailable)';
}

// === 2048 Game Models ===

/// Enum for swipe directions in 2048
enum Direction {
  up,
  down,
  left,
  right,
}

/// Extension for Direction to provide utility methods
extension DirectionExtension on Direction {
  String get name {
    switch (this) {
      case Direction.up:
        return 'Up';
      case Direction.down:
        return 'Down';
      case Direction.left:
        return 'Left';
      case Direction.right:
        return 'Right';
    }
  }

  bool get isHorizontal {
    return this == Direction.left || this == Direction.right;
  }

  bool get isVertical {
    return this == Direction.up || this == Direction.down;
  }
}

/// Represents a position on the 2048 grid
@immutable
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  /// Create a position from index (0-15 for 4x4 grid)
  factory Position.fromIndex(int index) {
    return Position(index ~/ 4, index % 4);
  }

  /// Convert position to index (0-15 for 4x4 grid)
  int toIndex() => row * 4 + col;

  /// Check if position is valid for 4x4 grid
  bool get isValid => row >= 0 && row < 4 && col >= 0 && col < 4;

  /// Get adjacent position in given direction
  Position move(Direction direction) {
    switch (direction) {
      case Direction.up:
        return Position(row - 1, col);
      case Direction.down:
        return Position(row + 1, col);
      case Direction.left:
        return Position(row, col - 1);
      case Direction.right:
        return Position(row, col + 1);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'Position($row, $col)';
}

/// Represents a tile in the 2048 game
@immutable
class Tile {
  final int value;
  final Position position;
  final Position? previousPosition;
  final bool isNew;
  final bool wasMerged;
  final String id;

  const Tile({
    required this.value,
    required this.position,
    this.previousPosition,
    this.isNew = false,
    this.wasMerged = false,
    required this.id,
  });

  /// Create a new tile with random value (2 or 4)
  factory Tile.random(Position position) {
    final value = (DateTime.now().millisecondsSinceEpoch % 10 < 9) ? 2 : 4;
    return Tile(
      value: value,
      position: position,
      isNew: true,
      id: '${position.row}_${position.col}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Create a tile at specific position with value
  factory Tile.at(Position position, int value) {
    return Tile(
      value: value,
      position: position,
      id: '${position.row}_${position.col}_$value',
    );
  }

  /// Create a copy with modified values
  Tile copyWith({
    int? value,
    Position? position,
    Position? previousPosition,
    bool? isNew,
    bool? wasMerged,
    String? id,
  }) {
    return Tile(
      value: value ?? this.value,
      position: position ?? this.position,
      previousPosition: previousPosition ?? this.previousPosition,
      isNew: isNew ?? this.isNew,
      wasMerged: wasMerged ?? this.wasMerged,
      id: id ?? this.id,
    );
  }

  /// Move tile to new position
  Tile moveTo(Position newPosition) {
    return copyWith(
      position: newPosition,
      previousPosition: position,
      isNew: false,
      wasMerged: false,
    );
  }

  /// Merge with another tile
  Tile merge(Tile other) {
    return copyWith(
      value: value + other.value,
      wasMerged: true,
      isNew: false,
    );
  }

  /// Check if tile can merge with another
  bool canMergeWith(Tile other) {
    return value == other.value && !wasMerged && !other.wasMerged;
  }

  /// Get display color based on value
  Color get color {
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        return const Color(0xFF3C3A32);
    }
  }

  /// Get text color based on value
  Color get textColor {
    return value < 8 ? const Color(0xFF776E65) : Colors.white;
  }

  /// Get font size based on value
  double get fontSize {
    if (value < 100) return 55.0;
    if (value < 1000) return 45.0;
    if (value < 10000) return 35.0;
    return 30.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tile &&
        other.value == value &&
        other.position == position &&
        other.previousPosition == previousPosition &&
        other.isNew == isNew &&
        other.wasMerged == wasMerged &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hashAll([
        value,
        position,
        previousPosition,
        isNew,
        wasMerged,
        id,
      ]);

  @override
  String toString() => 'Tile(value: $value, position: $position)';
}

/// Represents the result of a move in 2048
@immutable
class MoveResult {
  final List<Tile> tiles;
  final int score;
  final bool moved;
  final bool gameOver;
  final bool won;

  const MoveResult({
    required this.tiles,
    required this.score,
    required this.moved,
    required this.gameOver,
    required this.won,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoveResult &&
        listEquals(other.tiles, tiles) &&
        other.score == score &&
        other.moved == moved &&
        other.gameOver == gameOver &&
        other.won == won;
  }

  @override
  int get hashCode => Object.hashAll([tiles, score, moved, gameOver, won]);

  @override
  String toString() => 'MoveResult(score: $score, moved: $moved)';
}

/// Represents the complete 2048 game state
@immutable
class Game2048State {
  final List<Tile> tiles;
  final int score;
  final int bestScore;
  final bool gameOver;
  final bool won;
  final int moves;
  final Duration gameDuration;
  final GameState state;
  final List<Game2048State> history;

  const Game2048State({
    required this.tiles,
    required this.score,
    required this.bestScore,
    required this.gameOver,
    required this.won,
    required this.moves,
    required this.gameDuration,
    required this.state,
    required this.history,
  });

  /// Create initial game state
  factory Game2048State.initial({int? bestScore}) {
    final initialTiles = _generateInitialTiles();
    return Game2048State(
      tiles: initialTiles,
      score: 0,
      bestScore: bestScore ?? 0,
      gameOver: false,
      won: false,
      moves: 0,
      gameDuration: Duration.zero,
      state: GameState.playing,
      history: [],
    );
  }

  /// Generate initial tiles for new game
  static List<Tile> _generateInitialTiles() {
    final tiles = <Tile>[];
    final positions = <Position>[];

    // Generate two random positions
    while (positions.length < 2) {
      final position = Position.fromIndex(
        DateTime.now().millisecondsSinceEpoch % 16,
      );
      if (!positions.contains(position)) {
        positions.add(position);
      }
    }

    // Create tiles at random positions
    for (final position in positions) {
      tiles.add(Tile.random(position));
    }

    return tiles;
  }

  /// Create a copy with modified values
  Game2048State copyWith({
    List<Tile>? tiles,
    int? score,
    int? bestScore,
    bool? gameOver,
    bool? won,
    int? moves,
    Duration? gameDuration,
    GameState? state,
    List<Game2048State>? history,
  }) {
    return Game2048State(
      tiles: tiles ?? this.tiles,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      gameOver: gameOver ?? this.gameOver,
      won: won ?? this.won,
      moves: moves ?? this.moves,
      gameDuration: gameDuration ?? this.gameDuration,
      state: state ?? this.state,
      history: history ?? this.history,
    );
  }

  /// Get tile at specific position
  Tile? getTileAt(Position position) {
    try {
      return tiles.firstWhere((tile) => tile.position == position);
    } catch (e) {
      return null;
    }
  }

  /// Check if position is occupied
  bool isPositionOccupied(Position position) {
    return getTileAt(position) != null;
  }

  /// Get all empty positions
  List<Position> get emptyPositions {
    final empty = <Position>[];
    for (int i = 0; i < 16; i++) {
      final position = Position.fromIndex(i);
      if (!isPositionOccupied(position)) {
        empty.add(position);
      }
    }
    return empty;
  }

  /// Check if board is full
  bool get isBoardFull => emptyPositions.isEmpty;

  /// Check if any moves are possible
  bool get canMove {
    if (!isBoardFull) return true;

    // Check if any adjacent tiles can merge
    for (final tile in tiles) {
      for (final direction in Direction.values) {
        final nextPosition = tile.position.move(direction);
        if (nextPosition.isValid) {
          final nextTile = getTileAt(nextPosition);
          if (nextTile != null && tile.canMergeWith(nextTile)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Check if game is won (has 2048 tile)
  bool get hasWon => tiles.any((tile) => tile.value >= 2048);

  /// Get highest tile value
  int get highestTileValue {
    return tiles.fold(0, (max, tile) => tile.value > max ? tile.value : max);
  }

  /// Get current status message
  String get statusMessage {
    if (won) return 'You Win!';
    if (gameOver) return 'Game Over!';
    return 'Score: $score';
  }

  /// Save state to history (for undo functionality)
  Game2048State saveToHistory() {
    final newHistory = List<Game2048State>.from(history);
    newHistory.add(this);

    // Keep only last 10 states
    if (newHistory.length > 10) {
      newHistory.removeAt(0);
    }

    return copyWith(history: newHistory);
  }

  /// Check if undo is possible
  bool get canUndo => history.isNotEmpty;

  /// Undo to previous state
  Game2048State undo() {
    if (!canUndo) return this;

    final previousState = history.last;
    final newHistory = List<Game2048State>.from(history);
    newHistory.removeLast();

    return previousState.copyWith(history: newHistory);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Game2048State &&
        listEquals(other.tiles, tiles) &&
        other.score == score &&
        other.bestScore == bestScore &&
        other.gameOver == gameOver &&
        other.won == won &&
        other.moves == moves &&
        other.gameDuration == gameDuration &&
        other.state == state &&
        listEquals(other.history, history);
  }

  @override
  int get hashCode => Object.hashAll([
        tiles,
        score,
        bestScore,
        gameOver,
        won,
        moves,
        gameDuration,
        state,
        history,
      ]);

  @override
  String toString() => 'Game2048State(score: $score, tiles: ${tiles.length})';
}

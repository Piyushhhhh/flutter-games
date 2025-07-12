import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/game_models.dart';
import '../../core/constants/app_constants.dart';

/// Controller for 2048 game logic
class Game2048Controller extends ChangeNotifier {
  Game2048State _state;
  final Random _random = Random();

  Game2048Controller({Game2048State? initialState})
      : _state = initialState ?? Game2048State.initial();

  /// Current game state
  Game2048State get state => _state;

  /// Initialize game with saved best score
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final bestScore = prefs.getInt(GameConstants.game2048BestScoreKey) ?? 0;

    _state = Game2048State.initial(bestScore: bestScore);
    notifyListeners();
  }

  /// Start a new game
  Future<void> newGame() async {
    final prefs = await SharedPreferences.getInstance();
    final bestScore = prefs.getInt(GameConstants.game2048BestScoreKey) ?? 0;

    _state = Game2048State.initial(bestScore: bestScore);
    notifyListeners();
  }

  /// Move tiles in specified direction
  Future<void> move(Direction direction) async {
    if (_state.gameOver || _state.won) return;

    final moveResult = _performMove(direction);

    if (!moveResult.moved) return;

    var newState = _state.copyWith(
      tiles: moveResult.tiles,
      score: _state.score + moveResult.score,
      moves: _state.moves + 1,
      gameOver: moveResult.gameOver,
      won: moveResult.won,
    );

    // Save to history for undo functionality
    newState = newState.saveToHistory();

    // Add new tile if game is not over
    if (!newState.gameOver && !newState.won) {
      newState = _addNewTile(newState);

      // Check for game over after adding new tile
      if (!newState.canMove) {
        newState = newState.copyWith(gameOver: true);
      }
    }

    // Update best score if needed
    if (newState.score > newState.bestScore) {
      newState = newState.copyWith(bestScore: newState.score);
      await _saveBestScore(newState.bestScore);
    }

    _state = newState;
    notifyListeners();
  }

  /// Perform the actual move logic
  MoveResult _performMove(Direction direction) {
    final tiles = List<Tile>.from(_state.tiles);
    final movedTiles = <Tile>[];
    int scoreGained = 0;
    bool moved = false;

    // Movement vectors are handled internally by tile movement logic

    // Determine traversal order
    final traversals = _buildTraversals(direction);

    // Clear merge flags
    for (final tile in tiles) {
      tile.copyWith(wasMerged: false);
    }

    // Move tiles
    for (final row in traversals.rows) {
      for (final col in traversals.cols) {
        final position = Position(row, col);
        final tile = _getTileAt(tiles, position);

        if (tile != null) {
          final positions = _findFarthestPosition(tiles, position, direction);
          final next = _getTileAt(tiles, positions.next);

          // Check if tiles can merge
          if (next != null && tile.canMergeWith(next) && !next.wasMerged) {
            // Merge tiles
            final mergedTile = next.merge(tile);
            movedTiles.add(mergedTile);
            tiles.remove(tile);
            tiles.remove(next);
            scoreGained += mergedTile.value;
            moved = true;
          } else {
            // Move tile to farthest position
            final movedTile = tile.moveTo(positions.farthest);
            movedTiles.add(movedTile);
            tiles.remove(tile);

            if (movedTile.position != tile.position) {
              moved = true;
            }
          }
        }
      }
    }

    // Add moved tiles back
    tiles.addAll(movedTiles);

    // Check for win condition
    final won =
        tiles.any((tile) => tile.value >= GameConstants.game2048WinValue);

    // Check for game over
    final gameOver = !_canMove(tiles);

    return MoveResult(
      tiles: tiles,
      score: scoreGained,
      moved: moved,
      gameOver: gameOver,
      won: won && !_state.won, // Only trigger win once
    );
  }

  /// Build traversal orders for efficient movement
  ({List<int> rows, List<int> cols}) _buildTraversals(Direction direction) {
    final rows = List.generate(4, (i) => i);
    final cols = List.generate(4, (i) => i);

    // Reverse traversal order for opposite directions
    switch (direction) {
      case Direction.down:
        rows.sort((a, b) => b.compareTo(a));
        break;
      case Direction.right:
        cols.sort((a, b) => b.compareTo(a));
        break;
      case Direction.up:
      case Direction.left:
        // Default order is fine
        break;
    }

    return (rows: rows, cols: cols);
  }

  /// Find the farthest position a tile can move to
  ({Position farthest, Position next}) _findFarthestPosition(
    List<Tile> tiles,
    Position position,
    Direction direction,
  ) {
    Position previous = position;
    Position current = position.move(direction);

    while (current.isValid && _getTileAt(tiles, current) == null) {
      previous = current;
      current = current.move(direction);
    }

    return (farthest: previous, next: current);
  }

  /// Get tile at specific position
  Tile? _getTileAt(List<Tile> tiles, Position position) {
    try {
      return tiles.firstWhere((tile) => tile.position == position);
    } catch (e) {
      return null;
    }
  }

  /// Check if any moves are possible
  bool _canMove(List<Tile> tiles) {
    // Check for empty cells
    if (tiles.length < 16) return true;

    // Check for possible merges
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        final position = Position(row, col);
        final tile = _getTileAt(tiles, position);

        if (tile != null) {
          // Check adjacent tiles
          for (final direction in Direction.values) {
            final adjacentPos = position.move(direction);
            if (adjacentPos.isValid) {
              final adjacentTile = _getTileAt(tiles, adjacentPos);
              if (adjacentTile != null && tile.canMergeWith(adjacentTile)) {
                return true;
              }
            }
          }
        }
      }
    }

    return false;
  }

  /// Add a new tile to the board
  Game2048State _addNewTile(Game2048State state) {
    final emptyPositions = state.emptyPositions;

    if (emptyPositions.isEmpty) {
      return state;
    }

    // Choose random empty position
    final randomIndex = _random.nextInt(emptyPositions.length);
    final position = emptyPositions[randomIndex];

    // Create new tile
    final newTile = Tile.random(position);

    // Add to tiles list
    final newTiles = List<Tile>.from(state.tiles);
    newTiles.add(newTile);

    return state.copyWith(tiles: newTiles);
  }

  /// Undo last move
  void undo() {
    if (_state.canUndo) {
      _state = _state.undo();
      notifyListeners();
    }
  }

  /// Continue game after winning
  void continueGame() {
    if (_state.won) {
      _state = _state.copyWith(won: false);
      notifyListeners();
    }
  }

  /// Save best score to SharedPreferences
  Future<void> _saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(GameConstants.game2048BestScoreKey, score);
  }

  /// Get tile position as offset for animations
  Offset getTileOffset(Position position, double gridSize, double tileSize) {
    const spacing = GameConstants.game2048GridSpacing;
    final x = position.col * (tileSize + spacing) + spacing;
    final y = position.row * (tileSize + spacing) + spacing;
    return Offset(x, y);
  }

  /// Get tile at specific grid position for UI
  Tile? getTileAtPosition(Position position) {
    return _state.getTileAt(position);
  }

  /// Get all tiles for UI rendering
  List<Tile> get tiles => _state.tiles;

  /// Get current score
  int get score => _state.score;

  /// Get best score
  int get bestScore => _state.bestScore;

  /// Check if game is over
  bool get isGameOver => _state.gameOver;

  /// Check if game is won
  bool get isWon => _state.won;

  /// Check if undo is available
  bool get canUndo => _state.canUndo;

  /// Get number of moves
  int get moves => _state.moves;

  /// Get highest tile value
  int get highestTileValue => _state.highestTileValue;

  /// Get game status message
  String get statusMessage => _state.statusMessage;
}

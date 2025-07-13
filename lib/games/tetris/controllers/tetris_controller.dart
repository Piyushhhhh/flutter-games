import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/tetris_models.dart';

/// TetrisController manages all game logic and state for Tetris
/// Following MVC pattern, this handles business logic and state management
class TetrisController extends ChangeNotifier {
  // Private game state variables
  GameState _gameState = GameState.playing;
  late List<List<BoardCell>> _board;
  ActivePiece? _currentPiece;
  ActivePiece? _ghostPiece;
  ActivePiece? _heldPiece;
  bool _canHold = true;

  // Next pieces queue
  final List<Tetromino> _nextPieces = [];

  // Game statistics
  GameStats _stats = const GameStats();

  // Timing controllers
  Timer? _dropTimer;
  Timer? _gameTimer;
  DateTime? _gameStartTime;

  // Animation state
  LineClearAnimation? _lineClearAnimation;
  Timer? _lineClearTimer;

  // Random generator for pieces
  final math.Random _random = math.Random();

  // Public getters - read-only access to state
  GameState get gameState => _gameState;
  List<List<BoardCell>> get board => _board;
  ActivePiece? get currentPiece => _currentPiece;
  ActivePiece? get ghostPiece => _ghostPiece;
  ActivePiece? get heldPiece => _heldPiece;
  bool get canHold => _canHold;
  List<Tetromino> get nextPieces => _nextPieces;
  GameStats get stats => _stats;
  LineClearAnimation? get lineClearAnimation => _lineClearAnimation;

  // Computed state properties
  bool get isGameOver => _gameState == GameState.gameOver;
  bool get isPaused => _gameState == GameState.paused;
  bool get isPlaying => _gameState == GameState.playing;
  bool get isLineClearing => _gameState == GameState.lineClearing;

  /// Initialize the game controller
  void initialize() {
    _initializeBoard();
    _fillNextPieces();
    _spawnNewPiece();
    _startGameTimer();
    _startDropTimer();
    _gameStartTime = DateTime.now();
  }

  /// Initialize empty board
  void _initializeBoard() {
    _board = List.generate(
      TetrisConstants.boardHeight + TetrisConstants.bufferHeight,
      (row) => List.generate(
        TetrisConstants.boardWidth,
        (col) => const BoardCell(),
      ),
    );
  }

  /// Fill the next pieces queue with random pieces
  void _fillNextPieces() {
    while (_nextPieces.length < TetrisConstants.previewCount + 1) {
      _nextPieces.add(Tetromino.getRandom());
    }
  }

  /// Spawn a new piece at the top of the board
  void _spawnNewPiece() {
    if (_nextPieces.isEmpty) {
      _fillNextPieces();
    }

    final tetromino = _nextPieces.removeAt(0);
    _fillNextPieces();

    _currentPiece = ActivePiece(
      tetromino: tetromino,
      position: TetrisConstants.spawnPosition,
    );

    _updateGhostPiece();
    _canHold = true;

    // Check for game over
    if (_isCollision(_currentPiece!)) {
      _gameState = GameState.gameOver;
      _dropTimer?.cancel();
      _gameTimer?.cancel();
    }

    // Update statistics
    _stats = _stats.copyWith(pieces: _stats.pieces + 1);
    notifyListeners();
  }

  /// Update the ghost piece position (preview where piece will land)
  void _updateGhostPiece() {
    if (_currentPiece == null) return;

    _ghostPiece = _currentPiece!.copyWith();

    // Drop ghost piece to the bottom
    while (!_isCollision(_ghostPiece!)) {
      _ghostPiece!.move(1, 0);
    }
    _ghostPiece!.move(-1, 0); // Move back up one step
  }

  /// Get board cell at specific position
  BoardCell getBoardCell(int row, int col) {
    // Check if current piece occupies this position
    if (_currentPiece != null) {
      final currentPositions = _currentPiece!.getOccupiedPositions();
      for (final pos in currentPositions) {
        if (pos.row == row && pos.col == col) {
          return BoardCell(
            isOccupied: true,
            color: _currentPiece!.tetromino.color,
            gradient: _currentPiece!.tetromino.gradient,
            glowColor: _currentPiece!.tetromino.glowColor,
          );
        }
      }
    }

    // Check if ghost piece occupies this position
    if (_ghostPiece != null && _currentPiece != null) {
      final ghostPositions = _ghostPiece!.getOccupiedPositions();
      for (final pos in ghostPositions) {
        if (pos.row == row && pos.col == col) {
          // Don't show ghost if current piece is already there
          final currentPositions = _currentPiece!.getOccupiedPositions();
          final isCurrentPiece =
              currentPositions.any((cp) => cp.row == row && cp.col == col);

          if (!isCurrentPiece) {
            return BoardCell(
              isOccupied: true,
              color: _ghostPiece!.tetromino.color.withOpacity(0.3),
              gradient: LinearGradient(
                colors: [
                  _ghostPiece!.tetromino.color.withOpacity(0.3),
                  _ghostPiece!.tetromino.color.withOpacity(0.1),
                ],
              ),
              glowColor: _ghostPiece!.tetromino.glowColor.withOpacity(0.3),
            );
          }
        }
      }
    }

    // Return board cell
    if (row >= 0 && row < _board.length && col >= 0 && col < _board[0].length) {
      return _board[row][col];
    }

    return const BoardCell();
  }

  /// Check collision for a piece
  bool _isCollision(ActivePiece piece) {
    final positions = piece.getOccupiedPositions();

    for (final pos in positions) {
      // Check bounds
      if (pos.row >= _board.length ||
          pos.col < 0 ||
          pos.col >= TetrisConstants.boardWidth) {
        return true;
      }

      // Check if position is occupied (only check if row is valid)
      if (pos.row >= 0 && _board[pos.row][pos.col].isOccupied) {
        return true;
      }
    }

    return false;
  }

  /// Move piece left
  bool moveLeft() {
    if (_currentPiece == null || _gameState != GameState.playing) return false;

    _currentPiece!.move(0, -1);
    if (_isCollision(_currentPiece!)) {
      _currentPiece!.move(0, 1); // Revert
      return false;
    }

    _updateGhostPiece();
    HapticFeedback.lightImpact();
    notifyListeners();
    return true;
  }

  /// Move piece right
  bool moveRight() {
    if (_currentPiece == null || _gameState != GameState.playing) return false;

    _currentPiece!.move(0, 1);
    if (_isCollision(_currentPiece!)) {
      _currentPiece!.move(0, -1); // Revert
      return false;
    }

    _updateGhostPiece();
    HapticFeedback.lightImpact();
    notifyListeners();
    return true;
  }

  /// Move piece down (soft drop)
  bool moveDown() {
    if (_currentPiece == null || _gameState != GameState.playing) return false;

    _currentPiece!.move(1, 0);
    if (_isCollision(_currentPiece!)) {
      _currentPiece!.move(-1, 0); // Revert
      _lockPiece();
      return false;
    }

    // Award soft drop points
    _stats =
        _stats.copyWith(score: _stats.score + TetrisConstants.softDropPoints);
    notifyListeners();
    return true;
  }

  /// Hard drop (instant drop)
  void hardDrop() {
    if (_currentPiece == null || _gameState != GameState.playing) return;

    int dropDistance = 0;
    while (moveDown()) {
      dropDistance++;
    }

    // Award hard drop points
    final hardDropPoints = dropDistance * TetrisConstants.hardDropMultiplier;
    _stats = _stats.copyWith(score: _stats.score + hardDropPoints);

    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  /// Rotate current piece
  bool rotate() {
    if (_currentPiece == null || _gameState != GameState.playing) return false;

    final originalRotation = _currentPiece!.rotation;
    _currentPiece!.rotate();

    // Try wall kicks if rotation causes collision
    if (_isCollision(_currentPiece!)) {
      final kicks = _getWallKicks(_currentPiece!.tetromino.type,
          originalRotation, _currentPiece!.rotation);

      bool kicked = false;
      for (final kick in kicks) {
        _currentPiece!.move(kick.row, kick.col);
        if (!_isCollision(_currentPiece!)) {
          kicked = true;
          break;
        }
        _currentPiece!.move(-kick.row, -kick.col); // Revert kick
      }

      if (!kicked) {
        _currentPiece!.rotation = originalRotation; // Revert rotation
        return false;
      }
    }

    _updateGhostPiece();
    HapticFeedback.lightImpact();
    notifyListeners();
    return true;
  }

  /// Get wall kick offsets for rotation
  List<Position> _getWallKicks(
      TetrominoType type, int fromRotation, int toRotation) {
    // Basic wall kicks - can be enhanced with official SRS kicks
    return [
      const Position(0, -1),
      const Position(0, 1),
      const Position(-1, 0),
      const Position(1, 0),
      const Position(-1, -1),
      const Position(-1, 1),
      const Position(1, -1),
      const Position(1, 1),
    ];
  }

  /// Hold current piece
  void hold() {
    if (_currentPiece == null || !_canHold || _gameState != GameState.playing)
      return;

    if (_heldPiece == null) {
      // First hold
      _heldPiece = ActivePiece(
        tetromino: _currentPiece!.tetromino,
        position: TetrisConstants.spawnPosition,
      );
      _spawnNewPiece();
    } else {
      // Swap with held piece
      final currentTetromino = _currentPiece!.tetromino;
      _currentPiece = ActivePiece(
        tetromino: _heldPiece!.tetromino,
        position: TetrisConstants.spawnPosition,
      );
      _heldPiece = ActivePiece(
        tetromino: currentTetromino,
        position: TetrisConstants.spawnPosition,
      );
      _updateGhostPiece();
    }

    _canHold = false;
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  /// Lock current piece to board
  void _lockPiece() {
    if (_currentPiece == null) return;

    final positions = _currentPiece!.getOccupiedPositions();
    for (final pos in positions) {
      if (pos.row >= 0 && pos.row < _board.length) {
        _board[pos.row][pos.col] = BoardCell(
          isOccupied: true,
          color: _currentPiece!.tetromino.color,
          gradient: _currentPiece!.tetromino.gradient,
          glowColor: _currentPiece!.tetromino.glowColor,
        );
      }
    }

    HapticFeedback.mediumImpact();
    _checkForCompleteLines();
    _spawnNewPiece();
  }

  /// Check for complete lines
  void _checkForCompleteLines() {
    final completeRows = <int>[];

    for (int row = 0; row < _board.length; row++) {
      bool isComplete = true;
      for (int col = 0; col < TetrisConstants.boardWidth; col++) {
        if (!_board[row][col].isOccupied) {
          isComplete = false;
          break;
        }
      }
      if (isComplete) {
        completeRows.add(row);
      }
    }

    if (completeRows.isNotEmpty) {
      _startLineClearAnimation(completeRows);
    }
  }

  /// Start line clear animation
  void _startLineClearAnimation(List<int> rows) {
    _gameState = GameState.lineClearing;
    _dropTimer?.cancel();

    _lineClearAnimation = LineClearAnimation(
      clearingRows: rows,
      progress: 0.0,
      duration: const Duration(milliseconds: 500),
    );

    // Animate line clearing
    _lineClearTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) {
        final elapsed = timer.tick * 16;
        final progress = elapsed / _lineClearAnimation!.duration.inMilliseconds;

        if (progress >= 1.0) {
          timer.cancel();
          _completeLinesClearing();
        } else {
          _lineClearAnimation = LineClearAnimation(
            clearingRows: _lineClearAnimation!.clearingRows,
            progress: progress,
            duration: _lineClearAnimation!.duration,
          );
          notifyListeners();
        }
      },
    );
  }

  /// Complete lines clearing process
  void _completeLinesClearing() {
    if (_lineClearAnimation == null) return;

    final clearedRows = _lineClearAnimation!.clearingRows;
    final linesCleared = clearedRows.length;

    // Remove cleared lines
    clearedRows.sort((a, b) => b.compareTo(a)); // Sort descending
    for (final row in clearedRows) {
      _board.removeAt(row);
      // Add new empty row at top
      _board.insert(
          0,
          List.generate(
            TetrisConstants.boardWidth,
            (col) => const BoardCell(),
          ));
    }

    // Update statistics
    final lineScore = _stats.getLineScore(linesCleared);
    final newLines = _stats.lines + linesCleared;
    final newLevel = (newLines ~/ TetrisConstants.linesPerLevel) + 1;

    _stats = _stats.copyWith(
      score: _stats.score + lineScore,
      lines: newLines,
      level: newLevel,
    );

    // Special effects for Tetris (4 lines)
    if (linesCleared == 4) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    // Update drop speed if level changed
    if (newLevel != _stats.level) {
      _updateDropTimer();
    }

    _lineClearAnimation = null;
    _gameState = GameState.playing;
    _startDropTimer();
    notifyListeners();
  }

  /// Pause/unpause game
  void togglePause() {
    if (_gameState == GameState.gameOver) return;

    if (_gameState == GameState.playing) {
      _gameState = GameState.paused;
      _dropTimer?.cancel();
    } else if (_gameState == GameState.paused) {
      _gameState = GameState.playing;
      _startDropTimer();
    }

    notifyListeners();
  }

  /// Start new game
  void newGame() {
    // Cancel existing timers
    _dropTimer?.cancel();
    _gameTimer?.cancel();
    _lineClearTimer?.cancel();

    // Reset state
    _gameState = GameState.playing;
    _currentPiece = null;
    _ghostPiece = null;
    _heldPiece = null;
    _canHold = true;
    _nextPieces.clear();
    _stats = const GameStats();
    _lineClearAnimation = null;

    // Reinitialize
    initialize();
    notifyListeners();
  }

  /// Start drop timer
  void _startDropTimer() {
    _dropTimer?.cancel();
    final dropSpeed = _stats.getDropSpeed();

    _dropTimer = Timer.periodic(dropSpeed, (timer) {
      if (_gameState == GameState.playing) {
        moveDown();
      }
    });
  }

  /// Update drop timer when level changes
  void _updateDropTimer() {
    if (_gameState == GameState.playing) {
      _startDropTimer();
    }
  }

  /// Start game timer
  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == GameState.playing) {
        final elapsed = DateTime.now().difference(_gameStartTime!);
        _stats = _stats.copyWith(gameTime: elapsed);
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _dropTimer?.cancel();
    _gameTimer?.cancel();
    _lineClearTimer?.cancel();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'tetris_models.dart';

class TetrisController extends ChangeNotifier {
  // Game state
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

  // Timing
  Timer? _dropTimer;
  Timer? _gameTimer;
  DateTime? _gameStartTime;

  // Animation
  LineClearAnimation? _lineClearAnimation;
  Timer? _lineClearTimer;

  // Random generator for pieces
  final math.Random _random = math.Random();

  // Getters
  GameState get gameState => _gameState;
  List<List<BoardCell>> get board => _board;
  ActivePiece? get currentPiece => _currentPiece;
  ActivePiece? get ghostPiece => _ghostPiece;
  ActivePiece? get heldPiece => _heldPiece;
  bool get canHold => _canHold;
  List<Tetromino> get nextPieces => _nextPieces;
  GameStats get stats => _stats;
  LineClearAnimation? get lineClearAnimation => _lineClearAnimation;

  bool get isGameOver => _gameState == GameState.gameOver;
  bool get isPaused => _gameState == GameState.paused;
  bool get isPlaying => _gameState == GameState.playing;
  bool get isLineClearing => _gameState == GameState.lineClearing;

  // Initialize the game
  void initialize() {
    _initializeBoard();
    _fillNextPieces();
    _spawnNewPiece();
    _startGameTimer();
    _startDropTimer();
    _gameStartTime = DateTime.now();
  }

  // Initialize empty board
  void _initializeBoard() {
    _board = List.generate(
      TetrisConstants.boardHeight + TetrisConstants.bufferHeight,
      (row) => List.generate(
        TetrisConstants.boardWidth,
        (col) => const BoardCell(),
      ),
    );
  }

  // Fill the next pieces queue
  void _fillNextPieces() {
    while (_nextPieces.length < TetrisConstants.previewCount) {
      _nextPieces.add(Tetromino.getRandomPiece());
    }
  }

  // Start game timer
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == GameState.playing) {
        final now = DateTime.now();
        final elapsed = now.difference(_gameStartTime ?? now);
        _stats = _stats.copyWith(gameTime: elapsed);
        notifyListeners();
      }
    });
  }

  // Start drop timer
  void _startDropTimer() {
    _dropTimer?.cancel();
    _dropTimer = Timer.periodic(_stats.getDropSpeed(), (timer) {
      if (_gameState == GameState.playing) {
        moveDown();
      }
    });
  }

  // Update drop timer speed
  void _updateDropTimer() {
    if (_dropTimer != null && _dropTimer!.isActive) {
      _startDropTimer();
    }
  }

  // Spawn a new piece
  void _spawnNewPiece() {
    if (_nextPieces.isEmpty) {
      _fillNextPieces();
    }

    final nextPiece = _nextPieces.removeAt(0);
    _fillNextPieces();

    _currentPiece = ActivePiece(
      tetromino: nextPiece,
      position: TetrisConstants.spawnPosition,
    );

    _canHold = true;
    _updateGhostPiece();

    // Check if game is over (can't spawn new piece)
    if (_isCollision(_currentPiece!)) {
      _gameState = GameState.gameOver;
      _dropTimer?.cancel();
      _gameTimer?.cancel();
      HapticFeedback.heavyImpact();
    }

    _stats = _stats.copyWith(pieces: _stats.pieces + 1);
    notifyListeners();
  }

  // Update ghost piece position
  void _updateGhostPiece() {
    if (_currentPiece == null) return;

    _ghostPiece = _currentPiece!.copy();
    _ghostPiece!.isGhost = true;

    // Drop ghost piece to lowest valid position
    while (!_isCollision(_ghostPiece!)) {
      _ghostPiece!.move(1, 0);
    }
    _ghostPiece!.move(-1, 0); // Move back to last valid position
  }

  // Check collision for a piece
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

  // Move piece left
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

  // Move piece right
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

  // Move piece down (soft drop)
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

  // Hard drop (instant drop)
  void hardDrop() {
    if (_currentPiece == null || _gameState != GameState.playing) return;

    int dropDistance = 0;
    while (moveDown()) {
      dropDistance++;
    }

    // Award hard drop points
    final points = dropDistance * TetrisConstants.hardDropMultiplier;
    _stats = _stats.copyWith(score: _stats.score + points);

    HapticFeedback.mediumImpact();
  }

  // Rotate piece clockwise
  bool rotate() {
    if (_currentPiece == null || _gameState != GameState.playing) return false;

    final originalRotation = _currentPiece!.rotation;
    _currentPiece!.rotate();

    if (_isCollision(_currentPiece!)) {
      // Try wall kicks
      if (!_tryWallKicks()) {
        _currentPiece!.rotation = originalRotation; // Revert
        return false;
      }
    }

    _updateGhostPiece();
    HapticFeedback.lightImpact();
    notifyListeners();
    return true;
  }

  // Try wall kicks for rotation
  bool _tryWallKicks() {
    if (_currentPiece == null) return false;

    // Simple wall kick offsets (can be expanded for SRS)
    final offsets = [
      const Position(0, -1), // Left
      const Position(0, 1), // Right
      const Position(-1, 0), // Up
      const Position(1, 0), // Down
    ];

    for (final offset in offsets) {
      _currentPiece!.position = _currentPiece!.position + offset;
      if (!_isCollision(_currentPiece!)) {
        return true; // Success
      }
      _currentPiece!.position = _currentPiece!.position - offset; // Revert
    }

    return false; // No valid wall kick found
  }

  // Hold current piece
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

  // Lock current piece to board
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

  // Check for complete lines
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

  // Start line clear animation
  void _startLineClearAnimation(List<int> rows) {
    _gameState = GameState.lineClearing;
    _dropTimer?.cancel();

    // Mark rows as clearing
    for (final row in rows) {
      for (int col = 0; col < TetrisConstants.boardWidth; col++) {
        _board[row][col] = _board[row][col].copyWith(isClearing: true);
      }
    }

    _lineClearAnimation = LineClearAnimation(
      clearingRows: rows,
      progress: 0.0,
      duration: const Duration(milliseconds: 500),
    );

    notifyListeners();

    // Animate line clear
    _lineClearTimer?.cancel();
    _lineClearTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_lineClearAnimation != null) {
        final elapsed = timer.tick * 16;
        final progress = elapsed / _lineClearAnimation!.duration.inMilliseconds;

        _lineClearAnimation = LineClearAnimation(
          clearingRows: _lineClearAnimation!.clearingRows,
          progress: progress.clamp(0.0, 1.0),
          duration: _lineClearAnimation!.duration,
        );

        if (_lineClearAnimation!.isComplete) {
          _completeLinesClearing();
          timer.cancel();
        }

        notifyListeners();
      }
    });
  }

  // Complete lines clearing
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

  // Pause/unpause game
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

  // Start new game
  void newGame() {
    _gameState = GameState.playing;
    _stats = const GameStats();
    _currentPiece = null;
    _ghostPiece = null;
    _heldPiece = null;
    _canHold = true;
    _nextPieces.clear();
    _lineClearAnimation = null;

    _dropTimer?.cancel();
    _gameTimer?.cancel();
    _lineClearTimer?.cancel();

    _initializeBoard();
    _fillNextPieces();
    _spawnNewPiece();
    _startGameTimer();
    _startDropTimer();
    _gameStartTime = DateTime.now();

    HapticFeedback.lightImpact();
    notifyListeners();
  }

  // Get board cell with current piece overlay
  BoardCell getBoardCell(int row, int col) {
    // Start with base board cell
    BoardCell cell = _board[row][col];

    // Add current piece if it occupies this position
    if (_currentPiece != null && !_currentPiece!.isGhost) {
      final positions = _currentPiece!.getOccupiedPositions();
      if (positions.contains(Position(row, col))) {
        cell = BoardCell(
          isOccupied: true,
          color: _currentPiece!.tetromino.color,
          gradient: _currentPiece!.tetromino.gradient,
          glowColor: _currentPiece!.tetromino.glowColor,
        );
      }
    }

    // Add ghost piece if it occupies this position (and no solid piece)
    if (_ghostPiece != null && !cell.isOccupied) {
      final positions = _ghostPiece!.getOccupiedPositions();
      if (positions.contains(Position(row, col))) {
        cell = BoardCell(
          isOccupied: false, // Ghost pieces are not solid
          color: _ghostPiece!.tetromino.color.withOpacity(0.3),
          gradient: const LinearGradient(
            colors: [
              Color(0x4DFFFFFF),
              Color(0x1AFFFFFF),
            ],
          ),
          glowColor: _ghostPiece!.tetromino.glowColor.withOpacity(0.3),
        );
      }
    }

    return cell;
  }

  @override
  void dispose() {
    _dropTimer?.cancel();
    _gameTimer?.cancel();
    _lineClearTimer?.cancel();
    super.dispose();
  }
}

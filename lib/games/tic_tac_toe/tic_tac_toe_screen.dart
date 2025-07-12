import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'tic_tac_toe_models.dart';
import 'tic_tac_toe_constants.dart';
import 'tic_tac_toe_game.dart';
import 'tic_tac_toe_widgets.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  late TicTacToeGameState gameState;
  bool gameStarted = false;
  late DateTime gameStartTime;
  List<int> winningCells = [];

  @override
  void initState() {
    super.initState();
    gameState = TicTacToeGameState.initial();
    gameStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: TicTacToeStrings.gameTitle,
        actions: [
          if (gameStarted)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showGameInfo,
              tooltip: 'Game Info',
            ),
        ],
      ),
      body: SafeArea(
        child: ResponsivePadding(
          child: gameStarted ? _buildGameView() : _buildGameModeSelection(),
        ),
      ),
    );
  }

  Widget _buildGameModeSelection() {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                AppConstants.spacingXL * 2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppConstants.spacingXL),

              // Game icon
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                ),
                child: const Icon(
                  Icons.grid_3x3,
                  size: AppConstants.iconXXL,
                  color: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Title
              Text(
                TicTacToeStrings.chooseGameMode,
                style: const TextStyle(
                  fontSize: AppConstants.fontTitle,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.spacingXXL),

              // Game mode cards
              _buildGameModeCards(),

              const SizedBox(height: AppConstants.spacingL),

              // Difficulty selector (only for human vs computer)
              if (gameState.gameMode == GameMode.humanVsComputer)
                DifficultySelector(
                  currentDifficulty: gameState.difficulty,
                  onDifficultyChanged: _changeDifficulty,
                ),

              const SizedBox(height: AppConstants.spacingXL),

              // Start game button
              AnimatedGameButton(
                text: 'Start Game',
                icon: Icons.play_arrow,
                backgroundColor: AppTheme.primaryColor,
                onPressed: _startGame,
                semanticLabel: 'Start Tic Tac Toe game',
              ),

              const SizedBox(height: AppConstants.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeCards() {
    return Column(
      children: GameMode.values.map((mode) {
        return Column(
          children: [
            GameModeCard(
              gameMode: mode,
              isSelected: gameState.gameMode == mode,
              onTap: () => _selectGameMode(mode),
            ),
            const SizedBox(height: AppConstants.spacingL),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGameView() {
    return Column(
      children: [
        // Status section
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameStatusWidget(
                message: gameState.statusMessage,
                color: _getStatusColor(),
                icon: _getStatusIcon(),
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildGameStats(),
            ],
          ),
        ),

        // Game board
        Expanded(
          flex: 4,
          child: Center(
            child: TicTacToeBoard(
              board: gameState.board,
              onCellTap: _makeMove,
              isEnabled: !gameState.isComputerThinking && !gameState.isGameOver,
              winningCells: winningCells,
            ),
          ),
        ),

        // Action buttons
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameActionButtons(
                onReset: _resetGame,
                onChangeMode: _changeGameMode,
                isEnabled: !gameState.isComputerThinking,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Moves', gameState.moveHistory.length.toString()),
        _buildStatItem('X Wins', gameState.playerXScore.toString()),
        _buildStatItem('O Wins', gameState.playerOScore.toString()),
        _buildStatItem('Draws', gameState.drawCount.toString()),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: AppConstants.fontXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.fontM,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _selectGameMode(GameMode mode) {
    setState(() {
      gameState = gameState.copyWith(gameMode: mode);
    });
  }

  void _changeDifficulty(Difficulty difficulty) {
    setState(() {
      gameState = gameState.copyWith(difficulty: difficulty);
    });
  }

  void _startGame() {
    setState(() {
      gameState = gameState.copyWith(
        state: GameState.playing,
        board: GameBoard.empty(),
        currentPlayer: Player.x,
        result: GameResult.ongoing,
      );
      gameStarted = true;
      gameStartTime = DateTime.now();
      winningCells = [];
    });
  }

  void _makeMove(int position) {
    if (!TicTacToeGameController.isValidMove(gameState.board, position) ||
        gameState.isGameOver ||
        gameState.isComputerThinking) {
      return;
    }

    setState(() {
      // Make the move
      final newBoard = TicTacToeGameController.makeMove(
        gameState.board,
        position,
        gameState.currentPlayer,
      );
      final move = GameMove(
        position: position,
        player: gameState.currentPlayer,
        timestamp: DateTime.now(),
      );

      // Check for win or draw
      GameResult result = TicTacToeGameController.checkGameResult(newBoard);
      Player nextPlayer = gameState.currentPlayer.opponent;

      if (result != GameResult.ongoing) {
        // Game over
        winningCells =
            TicTacToeGameController.getWinningPositions(newBoard, result);
        final gameDuration = DateTime.now().difference(gameStartTime);
        gameState = gameState.copyWith(
          board: newBoard,
          result: result,
          state: GameState.gameOver,
          moveHistory: [...gameState.moveHistory, move],
          gameDuration: gameDuration,
          playerXScore: result == GameResult.playerXWins
              ? gameState.playerXScore + 1
              : gameState.playerXScore,
          playerOScore: result == GameResult.playerOWins
              ? gameState.playerOScore + 1
              : gameState.playerOScore,
          drawCount: result == GameResult.draw
              ? gameState.drawCount + 1
              : gameState.drawCount,
        );
        HapticFeedback.mediumImpact();
        _showGameOverDialog();
      } else {
        // Continue game
        gameState = gameState.copyWith(
          board: newBoard,
          currentPlayer: nextPlayer,
          moveHistory: [...gameState.moveHistory, move],
          state: GameState.playing,
        );
        HapticFeedback.lightImpact();
      }
    });

    // Handle computer move if needed
    if (gameState.gameMode == GameMode.humanVsComputer &&
        gameState.currentPlayer == Player.o &&
        !gameState.isGameOver) {
      _makeComputerMove();
    }
  }

  void _makeComputerMove() async {
    setState(() {
      gameState = gameState.copyWith(isComputerThinking: true);
    });

    // Add delay to simulate thinking
    await Future.delayed(TicTacToeConstants.computerThinkingDelay);

    if (!mounted) return;

    final bestMove = TicTacToeGameController.getBestMove(
      gameState.board,
      gameState.difficulty,
    );

    setState(() {
      // Make computer move
      final newBoard = TicTacToeGameController.makeMove(
        gameState.board,
        bestMove,
        Player.o,
      );
      final move = GameMove(
        position: bestMove,
        player: Player.o,
        timestamp: DateTime.now(),
      );

      // Check for win or draw
      GameResult result = TicTacToeGameController.checkGameResult(newBoard);

      if (result != GameResult.ongoing) {
        // Game over
        winningCells =
            TicTacToeGameController.getWinningPositions(newBoard, result);
        final gameDuration = DateTime.now().difference(gameStartTime);
        gameState = gameState.copyWith(
          board: newBoard,
          result: result,
          state: GameState.gameOver,
          moveHistory: [...gameState.moveHistory, move],
          isComputerThinking: false,
          gameDuration: gameDuration,
          playerXScore: result == GameResult.playerXWins
              ? gameState.playerXScore + 1
              : gameState.playerXScore,
          playerOScore: result == GameResult.playerOWins
              ? gameState.playerOScore + 1
              : gameState.playerOScore,
          drawCount: result == GameResult.draw
              ? gameState.drawCount + 1
              : gameState.drawCount,
        );
        HapticFeedback.mediumImpact();
        _showGameOverDialog();
      } else {
        // Continue game
        gameState = gameState.copyWith(
          board: newBoard,
          currentPlayer: Player.x,
          moveHistory: [...gameState.moveHistory, move],
          state: GameState.playing,
          isComputerThinking: false,
        );
        HapticFeedback.lightImpact();
      }
    });
  }

  void _resetGame() {
    setState(() {
      gameState = gameState.copyWith(
        board: GameBoard.empty(),
        currentPlayer: Player.x,
        result: GameResult.ongoing,
        state: GameState.playing,
        moveHistory: [],
        isComputerThinking: false,
      );
      gameStartTime = DateTime.now();
      winningCells = [];
    });
  }

  void _changeGameMode() {
    setState(() {
      gameStarted = false;
      gameState = TicTacToeGameState.initial();
      winningCells = [];
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getStatusIcon(),
              color: _getStatusColor(),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Text(
              gameState.result == GameResult.draw ? 'Draw!' : 'Game Over!',
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gameState.statusMessage,
              style: TextStyle(
                fontSize: AppConstants.fontL,
                color: _getStatusColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'Moves: ${gameState.moveHistory.length}',
              style: const TextStyle(fontSize: AppConstants.fontM),
            ),
            Text(
              'Time: ${gameState.gameDuration.inSeconds}s',
              style: const TextStyle(fontSize: AppConstants.fontM),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _changeGameMode();
            },
            child: const Text('Change Mode'),
          ),
        ],
      ),
    );
  }

  void _showGameInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mode: ${gameState.gameMode.displayName}'),
            if (gameState.gameMode == GameMode.humanVsComputer)
              Text('Difficulty: ${gameState.difficulty.displayName}'),
            Text('Current Player: ${gameState.currentPlayer.symbol}'),
            Text('Moves Made: ${gameState.moveHistory.length}'),
            Text(
                'Game Duration: ${DateTime.now().difference(gameStartTime).inSeconds}s'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color? _getStatusColor() {
    if (gameState.result == GameResult.playerXWins) {
      return Theme.of(context).colorScheme.primary;
    } else if (gameState.result == GameResult.playerOWins) {
      return gameState.gameMode == GameMode.humanVsComputer
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary;
    } else if (gameState.result == GameResult.draw) {
      return Theme.of(context).colorScheme.tertiary;
    }
    return null;
  }

  IconData? _getStatusIcon() {
    if (gameState.result == GameResult.playerXWins ||
        gameState.result == GameResult.playerOWins) {
      return Icons.emoji_events;
    } else if (gameState.result == GameResult.draw) {
      return Icons.handshake;
    } else if (gameState.isComputerThinking) {
      return Icons.psychology;
    }
    return null;
  }
}

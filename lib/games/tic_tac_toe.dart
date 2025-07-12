import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/game_models.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  late TicTacToeGameState gameState;
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();
    gameState = TicTacToeGameState.initial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: AppStrings.ticTacToe,
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
                AppStrings.chooseGameMode,
                style: const TextStyle(
                  fontSize: AppConstants.fontTitle,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.spacingXXL),

              // Game mode buttons
              AnimatedGameButton(
                text: AppStrings.humanVsHuman,
                icon: Icons.people,
                backgroundColor: AppTheme.primaryColor,
                onPressed: () => _startGame(GameMode.humanVsHuman),
                semanticLabel: 'Play Human vs Human mode',
              ),

              const SizedBox(height: AppConstants.spacingL),

              AnimatedGameButton(
                text: AppStrings.humanVsComputer,
                icon: Icons.computer,
                backgroundColor: AppTheme.secondaryColor,
                onPressed: () => _startGame(GameMode.humanVsComputer),
                semanticLabel: 'Play Human vs Computer mode',
              ),

              const SizedBox(height: AppConstants.spacingXL),
            ],
          ),
        ),
      ),
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
              GameStatus(
                message: gameState.statusMessage,
                color: _getStatusColor(),
                icon: _getStatusIcon(),
              ),
            ],
          ),
        ),

        // Game board
        Expanded(
          flex: 4,
          child: _buildGameBoard(),
        ),

        // Action buttons
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedGameButton(
                    text: AppStrings.resetGame,
                    icon: Icons.refresh,
                    backgroundColor: AppTheme.warningColor,
                    width: AppConstants.buttonWidth * 0.8,
                    height: AppConstants.buttonHeight,
                    onPressed: _resetGame,
                    semanticLabel: 'Reset the current game',
                  ),
                  AnimatedGameButton(
                    text: AppStrings.changeMode,
                    icon: Icons.settings,
                    backgroundColor: AppTheme.infoColor,
                    width: AppConstants.buttonWidth * 0.8,
                    height: AppConstants.buttonHeight,
                    onPressed: _changeGameMode,
                    semanticLabel: 'Change game mode',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 300,
          maxHeight: 300,
        ),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: AbsorbPointer(
            absorbing: gameState.isComputerThinking,
            child: Opacity(
              opacity: gameState.isComputerThinking ? 0.5 : 1.0,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: GameConstants.winCondition,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: AppConstants.gameGridSpacing,
                  mainAxisSpacing: AppConstants.gameGridSpacing,
                ),
                itemCount: GameConstants.totalCells,
                itemBuilder: (context, index) {
                  final player = gameState.board.getPlayerAt(index);
                  return GameGridCell(
                    value: player.symbol,
                    onTap: () => _makeMove(index),
                    isEnabled:
                        !gameState.isComputerThinking && !gameState.isGameOver,
                    backgroundColor: gameState.isComputerThinking
                        ? Theme.of(context).gameGridDisabledColor
                        : Theme.of(context).gameGridColor,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(GameMode mode) {
    setState(() {
      gameState = TicTacToeGameState.initial(gameMode: mode);
      gameStarted = true;
    });
  }

  void _makeMove(int position) {
    if (!gameState.board.isValidMove(position) ||
        gameState.isGameOver ||
        gameState.isComputerThinking) {
      return;
    }

    setState(() {
      // Make the move
      final newBoard =
          gameState.board.makeMove(position, gameState.currentPlayer);
      final move = GameMove(
        position: position,
        player: gameState.currentPlayer,
        timestamp: DateTime.now(),
      );

      // Check for win or draw
      GameResult result = _checkGameResult(newBoard);
      Player nextPlayer = gameState.currentPlayer.opponent;

      if (result != GameResult.ongoing) {
        // Game over
        gameState = gameState.copyWith(
          board: newBoard,
          result: result,
          state: GameState.gameOver,
          moveHistory: [...gameState.moveHistory, move],
        );
      } else {
        // Continue game
        gameState = gameState.copyWith(
          board: newBoard,
          currentPlayer: nextPlayer,
          moveHistory: [...gameState.moveHistory, move],
          state: GameState.playing,
        );
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
    await Future.delayed(GameConstants.computerThinkingDelay);

    if (!mounted) return;

    final bestMove = _getBestMove();

    setState(() {
      // Make computer move
      final newBoard = gameState.board.makeMove(bestMove, Player.o);
      final move = GameMove(
        position: bestMove,
        player: Player.o,
        timestamp: DateTime.now(),
      );

      // Check for win or draw
      GameResult result = _checkGameResult(newBoard);

      if (result != GameResult.ongoing) {
        // Game over
        gameState = gameState.copyWith(
          board: newBoard,
          result: result,
          state: GameState.gameOver,
          moveHistory: [...gameState.moveHistory, move],
          isComputerThinking: false,
        );
      } else {
        // Continue game
        gameState = gameState.copyWith(
          board: newBoard,
          currentPlayer: Player.x,
          moveHistory: [...gameState.moveHistory, move],
          state: GameState.playing,
          isComputerThinking: false,
        );
      }
    });
  }

  int _getBestMove() {
    final board = gameState.board;

    // 1. Try to win
    for (int i = 0; i < GameConstants.totalCells; i++) {
      if (board.isValidMove(i)) {
        final testBoard = board.makeMove(i, Player.o);
        if (_checkGameResult(testBoard) == GameResult.playerOWins) {
          return i;
        }
      }
    }

    // 2. Block opponent from winning
    for (int i = 0; i < GameConstants.totalCells; i++) {
      if (board.isValidMove(i)) {
        final testBoard = board.makeMove(i, Player.x);
        if (_checkGameResult(testBoard) == GameResult.playerXWins) {
          return i;
        }
      }
    }

    // 3. Take center if available
    if (board.isValidMove(GameConstants.centerPosition)) {
      return GameConstants.centerPosition;
    }

    // 4. Take corners
    for (int corner in GameConstants.corners) {
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

  GameResult _checkGameResult(GameBoard board) {
    // Check all winning combinations
    for (List<int> combination in GameConstants.winningCombinations) {
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

  void _resetGame() {
    setState(() {
      gameState = TicTacToeGameState.initial(gameMode: gameState.gameMode);
    });
  }

  void _changeGameMode() {
    setState(() {
      gameStarted = false;
      gameState = TicTacToeGameState.initial();
    });
  }

  Color? _getStatusColor() {
    if (gameState.result == GameResult.playerXWins) {
      return Theme.of(context).successColor;
    } else if (gameState.result == GameResult.playerOWins) {
      return gameState.gameMode == GameMode.humanVsComputer
          ? Theme.of(context).errorColor
          : Theme.of(context).successColor;
    } else if (gameState.result == GameResult.draw) {
      return Theme.of(context).warningColor;
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import 'tic_tac_toe_models.dart';
import 'tic_tac_toe_constants.dart';
import 'tic_tac_toe_game.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen>
    with TickerProviderStateMixin {
  late TicTacToeGameState gameState;
  bool gameStarted = false;
  late DateTime gameStartTime;
  List<int> winningCells = [];

  // Animation controllers for retro effects
  late AnimationController _fadeController;
  late AnimationController _neonController;
  late AnimationController _scanlineController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _neonAnimation;
  late Animation<double> _scanlineAnimation;

  @override
  void initState() {
    super.initState();
    gameState = TicTacToeGameState.initial();
    gameStartTime = DateTime.now();

    // Initialize retro animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _neonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scanlineController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _neonAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _neonController,
      curve: Curves.easeInOut,
    ));

    _scanlineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanlineController,
      curve: Curves.linear,
    ));

    _fadeController.forward();
    _neonController.repeat(reverse: true);
    _scanlineController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _neonController.dispose();
    _scanlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D001A), // Deep purple
            Color(0xFF1A0033), // Purple-black
            Color(0xFF2D1B69), // Electric purple
            Color(0xFF000000), // Black
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildRetroAppBar(),
        body: Stack(
          children: [
            // Retro grid background
            _buildRetroGrid(),
            // CRT scanlines effect
            _buildScanlines(),
            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child:
                    gameStarted ? _buildGameView() : _buildGameModeSelection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildRetroAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2D1B69),
              Color(0xFF5B2C87),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: Color(0xFF00FFFF),
              width: 2,
            ),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF00FFFF),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: AnimatedBuilder(
            animation: _neonAnimation,
            builder: (context, child) {
              return Text(
                'TIC TAC TOE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Color.lerp(
                    const Color(0xFF00FFFF),
                    const Color(0xFFFF0080),
                    _neonAnimation.value,
                  ),
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00FFFF)
                          .withOpacity(_neonAnimation.value),
                      blurRadius: 10,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            if (gameStarted)
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF00FF00),
                ),
                onPressed: _showGameInfo,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetroGrid() {
    return CustomPaint(
      size: Size.infinite,
      painter: RetroGridPainter(),
    );
  }

  Widget _buildScanlines() {
    return AnimatedBuilder(
      animation: _scanlineAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFF00FFFF).withOpacity(0.03),
                Colors.transparent,
              ],
              stops: [
                (_scanlineAnimation.value - 0.1).clamp(0.0, 1.0),
                _scanlineAnimation.value,
                (_scanlineAnimation.value + 0.1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameModeSelection() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildRetroHeader(),
          const SizedBox(height: 40),
          _buildRetroGameModeSelection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildRetroHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Neon logo
          AnimatedBuilder(
            animation: _neonAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00FFFF),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF)
                          .withOpacity(_neonAnimation.value * 0.8),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF0080)
                          .withOpacity(_neonAnimation.value * 0.6),
                      blurRadius: 30,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.grid_3x3,
                  size: 60,
                  color: Color.lerp(
                    const Color(0xFF00FFFF),
                    const Color(0xFFFF0080),
                    _neonAnimation.value,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'CHOOSE GAME MODE',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'monospace',
              color: const Color(0xFF00FF00).withOpacity(0.8),
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: const Color(0xFF00FF00).withOpacity(0.5),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroGameModeSelection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border.all(
          color: const Color(0xFF00FFFF),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2D1B69),
                  Color(0xFF5B2C87),
                ],
              ),
            ),
            child: const Text(
              'SELECT MODE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: Color(0xFF00FFFF),
                letterSpacing: 2,
              ),
            ),
          ),
          // Game modes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRetroGameModeCard(
                  GameMode.humanVsHuman,
                  'HUMAN VS HUMAN',
                  'Play with a friend',
                  Icons.people,
                  const Color(0xFF00FFFF),
                  const Color(0xFF00FF00),
                ),
                const SizedBox(height: 16),
                _buildRetroGameModeCard(
                  GameMode.humanVsComputer,
                  'HUMAN VS COMPUTER',
                  'Challenge the AI',
                  Icons.computer,
                  const Color(0xFFFF0080),
                  const Color(0xFFFFFF00),
                ),
                const SizedBox(height: 16),
                _buildRetroGameModeCard(
                  GameMode.computerVsComputer,
                  'COMPUTER VS COMPUTER',
                  'Watch AI battle',
                  Icons.psychology,
                  const Color(0xFF8A2BE2),
                  const Color(0xFF00FFFF),
                ),
                const SizedBox(height: 20),
                // Difficulty selector
                if (gameState.gameMode == GameMode.humanVsComputer)
                  _buildRetrodifficultySelectorSelector(),
                const SizedBox(height: 20),
                // Start button
                _buildRetroStartButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroGameModeCard(
    GameMode mode,
    String title,
    String subtitle,
    IconData icon,
    Color primaryColor,
    Color accentColor,
  ) {
    final isSelected = gameState.gameMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _selectGameMode(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.black,
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFF444444),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.2)
                    : const Color(0xFF222222),
                border: Border.all(
                  color: isSelected ? primaryColor : const Color(0xFF444444),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? primaryColor : const Color(0xFF666666),
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color:
                          isSelected ? primaryColor : const Color(0xFF666666),
                      shadows: isSelected
                          ? [
                              Shadow(
                                color: primaryColor.withOpacity(0.5),
                                blurRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: isSelected
                          ? accentColor.withOpacity(0.8)
                          : const Color(0xFF444444),
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetrodifficultySelectorSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border.all(
          color: const Color(0xFF00FF00),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'DIFFICULTY LEVEL',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Color(0xFF00FF00),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: Difficulty.values.map((difficulty) {
              final isSelected = gameState.difficulty == difficulty;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _changeDifficulty(difficulty);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00FF00).withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00FF00)
                          : const Color(0xFF444444),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    difficulty.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: isSelected
                          ? const Color(0xFF00FF00)
                          : const Color(0xFF666666),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroStartButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        _startGame();
      },
      child: AnimatedBuilder(
        animation: _neonAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFFF).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFF00FFFF),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF)
                      .withOpacity(_neonAnimation.value * 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow,
                  color: const Color(0xFF00FFFF),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'INITIALIZE GAME',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: const Color(0xFF00FFFF),
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF00FFFF)
                            .withOpacity(_neonAnimation.value),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Status section - more compact
              _buildRetroStatusSection(),
              const SizedBox(height: 12),
              // Game board - flexible
              Expanded(
                flex: 3,
                child: _buildRetroGameBoard(),
              ),
              const SizedBox(height: 12),
              // Stats section - compact
              _buildRetroStats(),
              const SizedBox(height: 12),
              // Action buttons - always visible
              _buildRetroActionButtons(),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRetroStatusSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border.all(
          color: const Color(0xFF00FFFF),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Status header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF00FFFF),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'GAME STATUS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Color(0xFF00FFFF),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Current player or status
          if (gameState.isComputerThinking)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology,
                  color: Color(0xFFFFFF00),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'COMPUTER THINKING...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: const Color(0xFFFFFF00),
                    shadows: [
                      Shadow(
                        color: const Color(0xFFFFFF00).withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            )
          else if (gameState.isGameOver)
            AnimatedBuilder(
              animation: _neonAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getStatusIcon(),
                      color: _getRetroStatusColor(),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      gameState.statusMessage.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: _getRetroStatusColor(),
                        shadows: [
                          Shadow(
                            color: _getRetroStatusColor()
                                .withOpacity(_neonAnimation.value),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  gameState.currentPlayer == Player.x
                      ? Icons.clear
                      : Icons.radio_button_unchecked,
                  color: gameState.currentPlayer == Player.x
                      ? const Color(0xFF00FFFF)
                      : const Color(0xFFFF0080),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'PLAYER ${gameState.currentPlayer.symbol} TURN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: gameState.currentPlayer == Player.x
                        ? const Color(0xFF00FFFF)
                        : const Color(0xFFFF0080),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRetroGameBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth > constraints.maxHeight
            ? constraints.maxHeight
            : constraints.maxWidth;
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: size - 40,
            height: size - 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              border: Border.all(
                color: const Color(0xFF00FFFF),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final player = gameState.board.cells[index];
                final isWinning = winningCells.contains(index);
                final isEnabled =
                    !gameState.isComputerThinking && !gameState.isGameOver;

                return GestureDetector(
                  onTap: isEnabled && player == Player.none
                      ? () => _makeMove(index)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isWinning
                          ? const Color(0xFF00FFFF).withOpacity(0.2)
                          : Colors.black.withOpacity(0.5),
                      border: Border.all(
                        color: isWinning
                            ? const Color(0xFF00FFFF)
                            : const Color(0xFF444444),
                        width: 1,
                      ),
                      boxShadow: isWinning
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00FFFF).withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: player != Player.none
                          ? AnimatedBuilder(
                              animation: _neonAnimation,
                              builder: (context, child) {
                                return Text(
                                  player.symbol,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: player == Player.x
                                        ? const Color(0xFF00FFFF)
                                        : const Color(0xFFFF0080),
                                    shadows: [
                                      Shadow(
                                        color: (player == Player.x
                                                ? const Color(0xFF00FFFF)
                                                : const Color(0xFFFF0080))
                                            .withOpacity(
                                                _neonAnimation.value * 0.8),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Container(),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRetroStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border.all(
          color: const Color(0xFF00FF00),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF00).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          const Text(
            'GAME STATISTICS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Color(0xFF00FF00),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          // Stats grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRetroStatItem(
                  'MOVES',
                  gameState.moveHistory.length.toString(),
                  const Color(0xFF00FFFF)),
              _buildRetroStatItem('X WINS', gameState.playerXScore.toString(),
                  const Color(0xFF00FFFF)),
              _buildRetroStatItem('O WINS', gameState.playerOScore.toString(),
                  const Color(0xFFFF0080)),
              _buildRetroStatItem('DRAWS', gameState.drawCount.toString(),
                  const Color(0xFFFFFF00)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetroStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: color,
            shadows: [
              Shadow(
                color: color.withOpacity(0.5),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontFamily: 'monospace',
            color: Color(0xFF666666),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRetroActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: gameState.isComputerThinking
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      _resetGame();
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF00).withOpacity(0.2),
                  border: Border.all(
                    color: gameState.isComputerThinking
                        ? const Color(0xFF444444)
                        : const Color(0xFF00FF00),
                    width: 2,
                  ),
                  boxShadow: gameState.isComputerThinking
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF00FF00).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: gameState.isComputerThinking
                          ? const Color(0xFF666666)
                          : const Color(0xFF00FF00),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RESET',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: gameState.isComputerThinking
                            ? const Color(0xFF666666)
                            : const Color(0xFF00FF00),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: gameState.isComputerThinking
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      _changeGameMode();
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0080).withOpacity(0.2),
                  border: Border.all(
                    color: gameState.isComputerThinking
                        ? const Color(0xFF444444)
                        : const Color(0xFFFF0080),
                    width: 2,
                  ),
                  boxShadow: gameState.isComputerThinking
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFFFF0080).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings,
                      color: gameState.isComputerThinking
                          ? const Color(0xFF666666)
                          : const Color(0xFFFF0080),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CHANGE MODE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: gameState.isComputerThinking
                            ? const Color(0xFF666666)
                            : const Color(0xFFFF0080),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

  Future<void> _makeComputerMove() async {
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: const Color(0xFF00FFFF),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getRetroStatusColor(),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    gameState.result == GameResult.draw
                        ? 'DRAW!'
                        : 'GAME OVER!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: _getRetroStatusColor(),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: _getRetroStatusColor().withOpacity(0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Divider
              Container(
                width: double.infinity,
                height: 2,
                color: const Color(0xFF00FFFF),
              ),
              const SizedBox(height: 20),
              // Result message
              Text(
                gameState.statusMessage.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: _getRetroStatusColor(),
                ),
              ),
              const SizedBox(height: 20),
              // Game stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRetroDialogStat(
                      'MOVES', gameState.moveHistory.length.toString()),
                  _buildRetroDialogStat(
                      'TIME', '${gameState.gameDuration.inSeconds}S'),
                ],
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                        _resetGame();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF00).withOpacity(0.2),
                          border: Border.all(
                            color: const Color(0xFF00FF00),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF00).withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Text(
                          'PLAY AGAIN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Color(0xFF00FF00),
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                        _changeGameMode();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0080).withOpacity(0.2),
                          border: Border.all(
                            color: const Color(0xFFFF0080),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF0080).withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Text(
                          'CHANGE MODE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Color(0xFFFF0080),
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetroDialogStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: Color(0xFF00FFFF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  void _showGameInfo() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: const Color(0xFF00FF00),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF00).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'GAME INFORMATION',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Color(0xFF00FF00),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Container(
                width: double.infinity,
                height: 2,
                color: const Color(0xFF00FF00),
              ),
              const SizedBox(height: 16),
              // Info items
              _buildRetroInfoItem(
                  'MODE', gameState.gameMode.displayName.toUpperCase()),
              if (gameState.gameMode == GameMode.humanVsComputer)
                _buildRetroInfoItem('DIFFICULTY',
                    gameState.difficulty.displayName.toUpperCase()),
              _buildRetroInfoItem(
                  'CURRENT PLAYER', gameState.currentPlayer.symbol),
              _buildRetroInfoItem(
                  'MOVES MADE', gameState.moveHistory.length.toString()),
              _buildRetroInfoItem('DURATION',
                  '${DateTime.now().difference(gameStartTime).inSeconds}S'),
              const SizedBox(height: 20),
              // Close button
              Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF00).withOpacity(0.2),
                      border: Border.all(
                        color: const Color(0xFF00FF00),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF00).withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text(
                      'CLOSE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Color(0xFF00FF00),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetroInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: Color(0xFF00FF00),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: Color(0xFF00FFFF),
              ),
            ),
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

  Color _getRetroStatusColor() {
    if (gameState.result == GameResult.playerXWins) {
      return const Color(0xFF00FFFF);
    } else if (gameState.result == GameResult.playerOWins) {
      return const Color(0xFFFF0080);
    } else if (gameState.result == GameResult.draw) {
      return const Color(0xFFFFFF00);
    }
    return const Color(0xFF00FF00);
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

class RetroGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double gridSize = 30;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

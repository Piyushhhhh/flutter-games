import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../controllers/tetris_controller.dart';
import '../models/tetris_models.dart';

/// TetrisScreen is the main view for the Tetris game
/// Following MVC pattern, this handles only UI presentation and user input
class TetrisScreen extends StatefulWidget {
  const TetrisScreen({super.key});

  @override
  State<TetrisScreen> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen>
    with TickerProviderStateMixin {
  late TetrisController _controller;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeAnimations();
  }

  /// Initialize the game controller
  void _initializeController() {
    _controller = TetrisController();
    _controller.initialize();
    _controller.addListener(_onGameStateChanged);
  }

  /// Initialize UI animations
  void _initializeAnimations() {
    // Pulse animation for game over
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Glow animation for UI elements
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// Handle game state changes for UI updates
  void _onGameStateChanged() {
    if (_controller.isGameOver) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF1A0A1A),
              Color(0xFF2D1B2D),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Stack(
                  children: [
                    Row(
                      children: [
                        // Left panel - Hold and stats
                        Expanded(
                          flex: 2,
                          child: _buildLeftPanel(),
                        ),
                        // Center - Game board
                        Expanded(
                          flex: 4,
                          child: _buildGameBoard(),
                        ),
                        // Right panel - Next pieces and controls
                        Expanded(
                          flex: 2,
                          child: _buildRightPanel(),
                        ),
                      ],
                    ),
                    // Game over overlay at higher level
                    if (_controller.isGameOver) _buildGameOverlay(),
                    if (_controller.isPaused) _buildPauseOverlay(),
                  ],
                ),
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the app bar with title and controls
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FFFF).withOpacity(0.3),
                  const Color(0xFF00FFFF).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00FFFF)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Spacer(),
          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FFFF).withOpacity(0.2),
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Text(
                  'TETRIS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00FFFF),
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF00FFFF)
                            .withOpacity(_glowAnimation.value),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          // Pause/Play button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FF00).withOpacity(0.3),
                  const Color(0xFF00FF00).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00FF00).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                _controller.isPaused ? Icons.play_arrow : Icons.pause,
                color: const Color(0xFF00FF00),
              ),
              onPressed: _controller.togglePause,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the left panel with hold section and statistics
  Widget _buildLeftPanel() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHoldSection(),
          const SizedBox(height: 20),
          _buildStatsSection(),
          const Spacer(),
        ],
      ),
    );
  }

  /// Build the hold section UI
  Widget _buildHoldSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A0A1A).withOpacity(0.8),
            const Color(0xFF2D1B2D).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'HOLD',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B5CF6),
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: const Color(0xFF8B5CF6),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF333333).withOpacity(0.3),
                  const Color(0xFF222222).withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: _controller.heldPiece != null
                ? _buildMiniPiece(_controller.heldPiece!.tetromino)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Build the statistics section UI
  Widget _buildStatsSection() {
    return Column(
      children: [
        _buildStatCard('SCORE', _controller.stats.score.toString(),
            const Color(0xFF00FFFF), Icons.star),
        const SizedBox(height: 12),
        _buildStatCard('LEVEL', _controller.stats.level.toString(),
            const Color(0xFF00FF00), Icons.trending_up),
        const SizedBox(height: 12),
        _buildStatCard('LINES', _controller.stats.lines.toString(),
            const Color(0xFFFF8000), Icons.format_line_spacing),
        const SizedBox(height: 12),
        _buildStatCard('PIECES', _controller.stats.pieces.toString(),
            const Color(0xFFFF0080), Icons.extension),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
            shadows: [
              Shadow(
                color: color,
                blurRadius: 8,
              ),
            ],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the game board container
  Widget _buildGameBoard() {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTap: _controller.hardDrop,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A0A1A),
              Color(0xFF2D1B2D),
              Color(0xFF0F0F0F),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00FFFF).withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFFF).withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              blurRadius: 50,
              spreadRadius: 2,
            ),
          ],
        ),
        child: _buildBoard(),
      ),
    );
  }

  /// Build the actual tetris board grid
  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: TetrisConstants.boardWidth / TetrisConstants.visibleHeight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: TetrisConstants.boardWidth,
        ),
        itemCount: TetrisConstants.boardWidth * TetrisConstants.visibleHeight,
        itemBuilder: (context, index) {
          final row = index ~/ TetrisConstants.boardWidth +
              TetrisConstants.bufferHeight;
          final col = index % TetrisConstants.boardWidth;

          final cell = _controller.getBoardCell(row, col);

          return Container(
            margin: const EdgeInsets.all(0.5),
            decoration: BoxDecoration(
              gradient: cell.isOccupied
                  ? cell.gradient
                  : LinearGradient(
                      colors: [
                        const Color(0xFF333333).withOpacity(0.1),
                        const Color(0xFF222222).withOpacity(0.2),
                      ],
                    ),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: cell.isOccupied
                    ? (cell.glowColor ?? Colors.white).withOpacity(0.7)
                    : const Color(0xFF00FFFF).withOpacity(0.2),
                width: 0.5,
              ),
              boxShadow: cell.isOccupied
                  ? [
                      BoxShadow(
                        color:
                            (cell.glowColor ?? Colors.white).withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Build the right panel with next pieces and controls
  Widget _buildRightPanel() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildNextSection(),
          const SizedBox(height: 20),
          _buildControlButtons(),
          const Spacer(),
        ],
      ),
    );
  }

  /// Build the next pieces preview section
  Widget _buildNextSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A0A1A).withOpacity(0.8),
            const Color(0xFF2D1B2D).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FF00).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF00).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'NEXT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00FF00),
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: const Color(0xFF00FF00),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            math.min(_controller.nextPieces.length, 3),
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF333333).withOpacity(0.3),
                      const Color(0xFF222222).withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00FF00).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: _buildMiniPiece(_controller.nextPieces[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build mini piece preview
  Widget _buildMiniPiece(Tetromino tetromino) {
    final shape = tetromino.getShape(0);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: shape[0].length,
        ),
        itemCount: shape.length * shape[0].length,
        itemBuilder: (context, index) {
          final row = index ~/ shape[0].length;
          final col = index % shape[0].length;
          final isFilled = shape[row][col] == 1;

          return Container(
            margin: const EdgeInsets.all(0.5),
            decoration: BoxDecoration(
              gradient: isFilled ? tetromino.gradient : null,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isFilled
                  ? [
                      BoxShadow(
                        color: tetromino.glowColor.withOpacity(0.4),
                        blurRadius: 2,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Build control buttons section
  Widget _buildControlButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildControlButton(
                'NEW',
                Icons.refresh,
                _controller.newGame,
                const Color(0xFF00FF00),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildControlButton(
                'HOLD',
                Icons.inventory,
                _controller.canHold ? _controller.hold : null,
                _controller.canHold
                    ? const Color(0xFFFFFF00)
                    : const Color(0xFF666666),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildControlButton(
          'ROTATE',
          Icons.rotate_right,
          _controller.rotate,
          const Color(0xFF8B5CF6),
          isWide: true,
        ),
      ],
    );
  }

  /// Build individual control button
  Widget _buildControlButton(
    String label,
    IconData icon,
    VoidCallback? onPressed,
    Color color, {
    bool isWide = false,
  }) {
    return Container(
      width: isWide ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: onPressed != null
              ? [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ]
              : [
                  const Color(0xFF333333).withOpacity(0.3),
                  const Color(0xFF222222).withOpacity(0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: onPressed != null
              ? color.withOpacity(0.5)
              : const Color(0xFF666666).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: onPressed != null ? color : const Color(0xFF666666),
                  size: 20,
                  shadows: onPressed != null
                      ? [
                          Shadow(
                            color: color,
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: onPressed != null ? color : const Color(0xFF666666),
                    letterSpacing: 1.0,
                    shadows: onPressed != null
                        ? [
                            Shadow(
                              color: color,
                              blurRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build bottom direction controls
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDirectionButton(
              Icons.keyboard_arrow_left, _controller.moveLeft),
          _buildDirectionButton(
              Icons.keyboard_arrow_down, _controller.moveDown),
          _buildDirectionButton(
              Icons.keyboard_arrow_right, _controller.moveRight),
        ],
      ),
    );
  }

  /// Build individual direction button
  Widget _buildDirectionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00FFFF),
            Color(0xFF0099FF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
            shadows: const [
              Shadow(
                color: Color(0xFF00FFFF),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build game over overlay
  Widget _buildGameOverlay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.98),
                const Color(0xFF0A0A0A).withOpacity(0.95),
                const Color(0xFF1A0619).withOpacity(0.98),
                Colors.black.withOpacity(0.98),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFF0066).withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF0066).withOpacity(0.4),
                blurRadius: 50,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Retro scanlines effect
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.black.withOpacity(0.1),
                  backgroundBlendMode: BlendMode.overlay,
                ),
                child: CustomPaint(
                  painter: RetroScanlinesPainter(),
                  size: Size.infinite,
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Retro "GAME OVER" title
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFF0066).withOpacity(0.2),
                                const Color(0xFFFF0033).withOpacity(0.1),
                                const Color(0xFFFF0066).withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFF0066).withOpacity(0.8),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF0066).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // "GAME OVER" text with retro effect
                              Transform.scale(
                                scale: _pulseAnimation.value,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      const Color(0xFFFF0066),
                                      const Color(0xFFFF3399),
                                      const Color(0xFFFF0066),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'GAME OVER',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 3.0,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFFFF0066),
                                          blurRadius: 15,
                                          offset: Offset(0, 2),
                                        ),
                                        Shadow(
                                          color: const Color(0xFFFF0066)
                                              .withOpacity(0.5),
                                          blurRadius: 25,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Retro subtitle
                              Text(
                                'SYSTEM FAILURE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      const Color(0xFFFF0066).withOpacity(0.8),
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFFFF0066)
                                          .withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Score display with retro CRT effect
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0A0A0A).withOpacity(0.9),
                            const Color(0xFF1A1A1A).withOpacity(0.8),
                            const Color(0xFF0A0A0A).withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00FFFF).withOpacity(0.5),
                          width: 1,
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
                          // Score
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.stars,
                                size: 20,
                                color: const Color(0xFF00FFFF),
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF00FFFF),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'FINAL SCORE',
                                style: TextStyle(
                                  color: const Color(0xFF00FFFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF00FFFF),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Animated score
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale:
                                    1.0 + (_pulseAnimation.value - 1.0) * 0.3,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      const Color(0xFF00FFFF),
                                      const Color(0xFF00CCFF),
                                      const Color(0xFF00FFFF),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    '${_controller.stats.score}',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2.0,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFF00FFFF),
                                          blurRadius: 20,
                                          offset: Offset(0, 2),
                                        ),
                                        Shadow(
                                          color: const Color(0xFF00FFFF)
                                              .withOpacity(0.5),
                                          blurRadius: 30,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Stats grid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildRetroStat(
                                  'LVL',
                                  '${_controller.stats.level}',
                                  const Color(0xFF00FF00)),
                              _buildRetroStat(
                                  'LINES',
                                  '${_controller.stats.lines}',
                                  const Color(0xFFFF8000)),
                              _buildRetroStat(
                                  'BLOCKS',
                                  '${_controller.stats.pieces}',
                                  const Color(0xFF8B5CF6)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Retro action buttons
                    Column(
                      children: [
                        // NEW GAME button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFF0066),
                                const Color(0xFFFF0033),
                                const Color(0xFFFF0066),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFF0066).withOpacity(0.8),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF0066).withOpacity(0.5),
                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: const Color(0xFFFF0066).withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _controller.newGame,
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.refresh,
                                      size: 20,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFFFF0066),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'NEW GAME',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2.0,
                                        shadows: [
                                          Shadow(
                                            color: const Color(0xFFFF0066),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // EXIT button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF333333).withOpacity(0.8),
                                const Color(0xFF1A1A1A).withOpacity(0.9),
                                const Color(0xFF333333).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF666666).withOpacity(0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF666666).withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.exit_to_app,
                                      size: 18,
                                      color: const Color(0xFF999999),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'EXIT TO MENU',
                                      style: TextStyle(
                                        color: const Color(0xFF999999),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build retro stat display for game over screen
  Widget _buildRetroStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
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
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build pause overlay
  Widget _buildPauseOverlay() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.8),
            const Color(0xFF1A0A1A).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.7),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00FFFF), Color(0xFF0099FF)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.pause,
              size: 60,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0xFF00FFFF),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'PAUSED',
            style: TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              shadows: [
                Shadow(
                  color: Color(0xFF00FFFF),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Touch gesture handlers
  double? _panStartX;
  double? _panStartY;

  /// Handle pan update for touch gestures
  void _handlePanUpdate(DragUpdateDetails details) {
    _panStartX ??= details.localPosition.dx;
    _panStartY ??= details.localPosition.dy;
  }

  /// Handle pan end for touch gestures
  void _handlePanEnd(DragEndDetails details) {
    if (_panStartX == null || _panStartY == null) return;

    final dx = details.localPosition.dx - _panStartX!;
    final dy = details.localPosition.dy - _panStartY!;

    // Reset pan coordinates
    _panStartX = null;
    _panStartY = null;

    // Determine gesture direction
    if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      if (dx > 0) {
        _controller.moveRight();
      } else {
        _controller.moveLeft();
      }
    } else {
      // Vertical swipe
      if (dy > 0) {
        _controller.moveDown();
      } else {
        _controller.rotate();
      }
    }
  }
}

/// Custom painter for retro scanlines effect
class RetroScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Add some retro CRT curvature effect
    final curvePaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Subtle vignette effect
    final vignetteGradient = RadialGradient(
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.1),
      ],
      stops: const [0.5, 1.0],
    );

    final vignetteRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final vignettePaint = Paint()
      ..shader = vignetteGradient.createShader(vignetteRect);

    canvas.drawRect(vignetteRect, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

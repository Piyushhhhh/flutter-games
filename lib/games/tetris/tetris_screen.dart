import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'tetris_controller.dart';
import 'tetris_models.dart';

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
    _controller = TetrisController();
    _controller.initialize();
    _controller.addListener(_onGameStateChanged);

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
                child: Row(
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
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
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
            size: 20,
            shadows: [
              Shadow(
                color: color,
                blurRadius: 10,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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
        child: Stack(
          children: [
            _buildBoard(),
            if (_controller.isGameOver) _buildGameOverlay(),
            if (_controller.isPaused) _buildPauseOverlay(),
          ],
        ),
      ),
    );
  }

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

  Widget _buildGameOverlay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.9),
                  const Color(0xFF1A0A1A).withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF0066).withOpacity(0.7),
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
                      colors: [Color(0xFFFF0066), Color(0xFFFF0033)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF0066).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.gamepad,
                    size: 60,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color(0xFFFF0066),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: Color(0xFFFF0066),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Color(0xFFFF0066),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Score: ${_controller.stats.score}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: const [
                      Shadow(
                        color: Color(0xFFFF0066),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _controller.newGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0066),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'PLAY AGAIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
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
          const SizedBox(height: 16),
          const Text(
            'Tap Play to Resume',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Touch gesture handling
  Offset? _panStartOffset;

  void _handlePanUpdate(DragUpdateDetails details) {
    _panStartOffset ??= details.globalPosition;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_panStartOffset == null) return;

    final delta = details.globalPosition - _panStartOffset!;
    final dx = delta.dx;
    final dy = delta.dy;

    // Reset pan start offset
    _panStartOffset = null;

    // Check if the swipe distance is significant enough
    if (dx.abs() < 20 && dy.abs() < 20) {
      return;
    }

    // Determine direction based on the larger displacement
    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        _controller.moveRight();
      } else {
        _controller.moveLeft();
      }
    } else {
      if (dy > 0) {
        _controller.moveDown();
      } else {
        _controller.rotate();
      }
    }
  }
}

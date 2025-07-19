import 'package:flutter/material.dart';
import 'mario_player.dart';
import 'mario_world.dart';

/// Overlay UI for Mario game: score, world, lives, etc.
class MarioUI extends StatelessWidget {
  final MarioPlayer mario;
  final MarioWorld world;
  final int score;
  final int lives;

  const MarioUI({Key? key, required this.mario, required this.world, this.score = 0, this.lives = 3}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          _retroText('SCORE', value: score.toString()),
          // World (static for now)
          _retroText('WORLD', value: '1-1'),
          // Lives
          _retroText('LIVES', value: lives.toString()),
        ],
      ),
    );
  }

  Widget _retroText(String label, {required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 10,
            color: Color(0xFF00FFF7),
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 13,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Color(0xFF00FFF7),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

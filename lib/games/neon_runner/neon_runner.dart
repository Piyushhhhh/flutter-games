/// Neon Runner Game Module
///
/// This module will provide a complete Neon Runner game implementation with:
/// - Endless runner gameplay
/// - Neon visual effects
/// - Obstacle avoidance
/// - Power-ups and bonuses
/// - Speed progression
/// - Distance and score tracking
///
/// Usage:
/// ```dart
/// import 'package:flutter_games/games/neon_runner/neon_runner.dart';
///
/// // Navigate to the game
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const NeonRunnerScreen()),
/// );
/// ```

import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';

class NeonRunnerScreen extends StatefulWidget {
  const NeonRunnerScreen({super.key});

  @override
  State<NeonRunnerScreen> createState() => _NeonRunnerScreenState();
}

class _NeonRunnerScreenState extends State<NeonRunnerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: 'Neon Runner',
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_run,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Neon Runner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

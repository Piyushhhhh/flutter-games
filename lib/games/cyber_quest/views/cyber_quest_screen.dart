import 'package:flutter/material.dart';
import '../../../widgets/common_widgets.dart';
import '../controllers/cyber_quest_controller.dart';
import '../models/cyber_quest_models.dart';

/// Cyber Quest Screen - View Component
///
/// This screen handles the presentation layer for the Cyber Quest RPG game.
/// It displays the user interface and delegates all business logic to the controller.
///
/// **MVC Architecture:**
/// - Models: Character and game state data structures (CyberQuestState)
/// - View: User interface and presentation logic (this class)
/// - Controller: Game logic and state management (CyberQuestController)
class CyberQuestScreen extends StatefulWidget {
  const CyberQuestScreen({super.key});

  @override
  State<CyberQuestScreen> createState() => _CyberQuestScreenState();
}

class _CyberQuestScreenState extends State<CyberQuestScreen> {
  late CyberQuestController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CyberQuestController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GameAppBar(
        title: 'Cyber Quest',
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return _buildGameContent();
        },
      ),
    );
  }

  Widget _buildGameContent() {
    switch (_controller.state.gameState) {
      case CyberQuestGameState.initial:
        return _buildInitialScreen();
      case CyberQuestGameState.playing:
        return _buildGameScreen();
      case CyberQuestGameState.paused:
        return _buildPausedScreen();
      case CyberQuestGameState.gameOver:
        return _buildGameOverScreen();
    }
  }

  Widget _buildInitialScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0F23),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.psychology,
                size: 80,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'CYBER QUEST',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Neural Interface Adventure',
              style: TextStyle(
                fontSize: 16,
                color: Colors.purple.shade300,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 40),
            _buildCharacterCreationCard(),
            const SizedBox(height: 20),
            const Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.cyan,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCreationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.cyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Your Character',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...CharacterClass.values.map((characterClass) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: Colors.black.withOpacity(0.2),
                child: ListTile(
                  leading: Icon(
                    _getClassIcon(characterClass),
                    color: _getClassColor(characterClass),
                  ),
                  title: Text(
                    characterClass.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    characterClass.description,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade500,
                    size: 16,
                  ),
                  onTap: () {
                    _showCharacterCreationDialog(characterClass);
                  },
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    final character = _controller.state.character!;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0F23),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildStatusBar(character),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${character.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current Location: ${_controller.state.currentLocation}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Game implementation in progress...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(Character character) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: Colors.cyan.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LVL ${character.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                LinearProgressIndicator(
                  value: character.experience / (character.level * 100),
                  backgroundColor: Colors.grey.shade700,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HP ${character.health}/${character.maxHealth}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                LinearProgressIndicator(
                  value: character.health / character.maxHealth,
                  backgroundColor: Colors.grey.shade700,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '₡${character.credits}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPausedScreen() {
    return const Center(
      child: Text(
        'Game Paused',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return const Center(
      child: Text(
        'Game Over',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  IconData _getClassIcon(CharacterClass characterClass) {
    switch (characterClass) {
      case CharacterClass.hacker:
        return Icons.code;
      case CharacterClass.netrunner:
        return Icons.cable;
      case CharacterClass.techie:
        return Icons.build;
      case CharacterClass.corporate:
        return Icons.business;
    }
  }

  Color _getClassColor(CharacterClass characterClass) {
    switch (characterClass) {
      case CharacterClass.hacker:
        return Colors.green;
      case CharacterClass.netrunner:
        return Colors.purple;
      case CharacterClass.techie:
        return Colors.orange;
      case CharacterClass.corporate:
        return Colors.blue;
    }
  }

  void _showCharacterCreationDialog(CharacterClass characterClass) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Create ${characterClass.displayName}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Character Name',
                labelStyle: TextStyle(color: Colors.cyan),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              characterClass.description,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _controller.createCharacter(
                    nameController.text, characterClass);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.black,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

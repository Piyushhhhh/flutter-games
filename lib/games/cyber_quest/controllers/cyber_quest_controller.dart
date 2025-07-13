import 'package:flutter/foundation.dart';
import '../models/cyber_quest_models.dart';

/// Cyber Quest Controller
///
/// This controller handles all the game logic and state management for the
/// Cyber Quest RPG game. It follows the MVC pattern by managing the game state
/// and notifying the view when changes occur.
class CyberQuestController extends ChangeNotifier {
  CyberQuestState _state = CyberQuestState();

  /// Current game state
  CyberQuestState get state => _state;

  /// Initialize the controller
  void initialize() {
    _state = CyberQuestState(
      gameState: CyberQuestGameState.initial,
      currentLocation: 'Neo-Tokyo Central',
      score: 0,
    );
    notifyListeners();
  }

  /// Create a new character and start the game
  void createCharacter(String name, CharacterClass characterClass) {
    if (name.isEmpty) return;

    final character = Character(
      name: name,
      characterClass: characterClass,
    );

    _state = _state.copyWith(
      character: character,
      gameState: CyberQuestGameState.playing,
    );

    notifyListeners();
  }

  /// Start a new game
  void startGame() {
    if (_state.character == null) return;

    _state = _state.copyWith(
      gameState: CyberQuestGameState.playing,
    );

    notifyListeners();
  }

  /// Pause the game
  void pauseGame() {
    if (_state.gameState == CyberQuestGameState.playing) {
      _state = _state.copyWith(
        gameState: CyberQuestGameState.paused,
      );
      notifyListeners();
    }
  }

  /// Resume the game
  void resumeGame() {
    if (_state.gameState == CyberQuestGameState.paused) {
      _state = _state.copyWith(
        gameState: CyberQuestGameState.playing,
      );
      notifyListeners();
    }
  }

  /// End the game
  void endGame() {
    _state = _state.copyWith(
      gameState: CyberQuestGameState.gameOver,
    );
    notifyListeners();
  }

  /// Reset the game to initial state
  void resetGame() {
    _state = CyberQuestState(
      gameState: CyberQuestGameState.initial,
      currentLocation: 'Neo-Tokyo Central',
      score: 0,
    );
    notifyListeners();
  }

  /// Move to a new location
  void moveToLocation(String location) {
    if (_state.gameState != CyberQuestGameState.playing) return;

    _state = _state.copyWith(
      currentLocation: location,
    );
    notifyListeners();
  }

  /// Add experience to the character
  void addExperience(int experience) {
    final character = _state.character;
    if (character == null || _state.gameState != CyberQuestGameState.playing) {
      return;
    }

    character.addExperience(experience);
    notifyListeners();
  }

  /// Add credits to the character
  void addCredits(int credits) {
    final character = _state.character;
    if (character == null || _state.gameState != CyberQuestGameState.playing) {
      return;
    }

    character.addCredits(credits);
    notifyListeners();
  }

  /// Spend credits
  bool spendCredits(int credits) {
    final character = _state.character;
    if (character == null || _state.gameState != CyberQuestGameState.playing) {
      return false;
    }

    final success = character.spendCredits(credits);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  /// Deal damage to the character
  void takeDamage(int damage) {
    final character = _state.character;
    if (character == null || _state.gameState != CyberQuestGameState.playing) {
      return;
    }

    character.takeDamage(damage);

    // Check if character is dead
    if (!character.isAlive) {
      endGame();
    } else {
      notifyListeners();
    }
  }

  /// Heal the character
  void heal(int amount) {
    final character = _state.character;
    if (character == null || _state.gameState != CyberQuestGameState.playing) {
      return;
    }

    character.heal(amount);
    notifyListeners();
  }

  /// Update the game score
  void updateScore(int newScore) {
    _state = _state.copyWith(score: newScore);
    notifyListeners();
  }

  /// Add to the game score
  void addScore(int points) {
    _state = _state.copyWith(score: _state.score + points);
    notifyListeners();
  }

  /// Get character stats summary
  Map<String, dynamic> getCharacterStats() {
    final character = _state.character;
    if (character == null) return {};

    return {
      'name': character.name,
      'class': character.characterClass.displayName,
      'level': character.level,
      'experience': character.experience,
      'experienceToNext': character.experienceToNextLevel,
      'health': character.health,
      'maxHealth': character.maxHealth,
      'credits': character.credits,
      'intelligence': character.intelligence,
      'strength': character.strength,
      'dexterity': character.dexterity,
      'charisma': character.charisma,
      'tech': character.tech,
    };
  }

  /// Get game state summary
  Map<String, dynamic> getGameStateSummary() {
    return {
      'gameState': _state.gameState.toString(),
      'currentLocation': _state.currentLocation,
      'score': _state.score,
      'hasCharacter': _state.character != null,
      'characterName': _state.character?.name ?? 'None',
    };
  }

  /// Check if game is in progress
  bool get isGameActive => _state.gameState == CyberQuestGameState.playing;

  /// Check if game is paused
  bool get isGamePaused => _state.gameState == CyberQuestGameState.paused;

  /// Check if game is over
  bool get isGameOver => _state.gameState == CyberQuestGameState.gameOver;

  /// Check if game is at initial state
  bool get isGameInitial => _state.gameState == CyberQuestGameState.initial;

  /// Check if character exists
  bool get hasCharacter => _state.character != null;

  /// Get current character
  Character? get currentCharacter => _state.character;

  /// Get current location
  String get currentLocation => _state.currentLocation;

  /// Get current score
  int get currentScore => _state.score;

  @override
  void dispose() {
    // Clean up any resources here if needed
    super.dispose();
  }
}

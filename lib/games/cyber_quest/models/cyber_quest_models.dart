/// Cyber Quest Models
///
/// This file contains all the data models for the Cyber Quest RPG game.
/// It defines the game state, character classes, and character data structures.
library cyber_quest_models;

/// Game state enum
enum CyberQuestGameState {
  initial,
  playing,
  paused,
  gameOver,
}

/// Character class enum with display properties
enum CharacterClass {
  hacker,
  netrunner,
  techie,
  corporate;

  /// Display name for the character class
  String get displayName {
    switch (this) {
      case CharacterClass.hacker:
        return 'Hacker';
      case CharacterClass.netrunner:
        return 'Netrunner';
      case CharacterClass.techie:
        return 'Techie';
      case CharacterClass.corporate:
        return 'Corporate';
    }
  }

  /// Description for the character class
  String get description {
    switch (this) {
      case CharacterClass.hacker:
        return 'Master of code and digital infiltration. High intelligence and hacking skills.';
      case CharacterClass.netrunner:
        return 'Neural interface specialist. Can directly interface with the net.';
      case CharacterClass.techie:
        return 'Technology expert and gadget specialist. Great with hardware and repairs.';
      case CharacterClass.corporate:
        return 'Business-savvy with resources and connections. High charisma and credits.';
    }
  }
}

/// Character data model
class Character {
  final String name;
  final CharacterClass characterClass;
  int level;
  int experience;
  int health;
  int maxHealth;
  int credits;

  // Stats
  int intelligence;
  int strength;
  int dexterity;
  int charisma;
  int tech;

  Character({
    required this.name,
    required this.characterClass,
    this.level = 1,
    this.experience = 0,
    this.health = 100,
    this.maxHealth = 100,
    this.credits = 1000,
    this.intelligence = 10,
    this.strength = 10,
    this.dexterity = 10,
    this.charisma = 10,
    this.tech = 10,
  }) {
    // Adjust stats based on character class
    switch (characterClass) {
      case CharacterClass.hacker:
        intelligence += 5;
        tech += 3;
        credits += 500;
        break;
      case CharacterClass.netrunner:
        intelligence += 3;
        tech += 5;
        dexterity += 2;
        break;
      case CharacterClass.techie:
        tech += 5;
        intelligence += 2;
        strength += 3;
        break;
      case CharacterClass.corporate:
        charisma += 5;
        credits += 2000;
        intelligence += 2;
        break;
    }
  }

  /// Calculate experience needed for next level
  int get experienceToNextLevel => level * 100;

  /// Check if character can level up
  bool get canLevelUp => experience >= experienceToNextLevel;

  /// Level up the character
  void levelUp() {
    if (canLevelUp) {
      level++;
      experience -= experienceToNextLevel;
      maxHealth += 10;
      health = maxHealth; // Full heal on level up

      // Increase stats based on class
      switch (characterClass) {
        case CharacterClass.hacker:
          intelligence += 2;
          tech += 1;
          break;
        case CharacterClass.netrunner:
          intelligence += 1;
          tech += 2;
          dexterity += 1;
          break;
        case CharacterClass.techie:
          tech += 2;
          strength += 1;
          intelligence += 1;
          break;
        case CharacterClass.corporate:
          charisma += 2;
          intelligence += 1;
          credits += 500;
          break;
      }
    }
  }

  /// Take damage
  void takeDamage(int damage) {
    health = (health - damage).clamp(0, maxHealth);
  }

  /// Heal the character
  void heal(int amount) {
    health = (health + amount).clamp(0, maxHealth);
  }

  /// Check if character is alive
  bool get isAlive => health > 0;

  /// Add experience
  void addExperience(int exp) {
    experience += exp;
    while (canLevelUp) {
      levelUp();
    }
  }

  /// Add credits
  void addCredits(int amount) {
    credits += amount;
  }

  /// Spend credits
  bool spendCredits(int amount) {
    if (credits >= amount) {
      credits -= amount;
      return true;
    }
    return false;
  }
}

/// Game state data model
class CyberQuestState {
  CyberQuestGameState gameState;
  Character? character;
  String currentLocation;
  int score;

  CyberQuestState({
    this.gameState = CyberQuestGameState.initial,
    this.character,
    this.currentLocation = 'Neo-Tokyo Central',
    this.score = 0,
  });

  /// Copy constructor for state updates
  CyberQuestState copyWith({
    CyberQuestGameState? gameState,
    Character? character,
    String? currentLocation,
    int? score,
  }) {
    return CyberQuestState(
      gameState: gameState ?? this.gameState,
      character: character ?? this.character,
      currentLocation: currentLocation ?? this.currentLocation,
      score: score ?? this.score,
    );
  }
}

/// Item data model
class Item {
  final String id;
  final String name;
  final String description;
  final int value;
  final ItemType type;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.type,
  });
}

/// Item type enum
enum ItemType {
  weapon,
  armor,
  consumable,
  quest,
  misc,
}

/// Quest data model
class Quest {
  final String id;
  final String title;
  final String description;
  final int reward;
  final int expReward;
  bool isCompleted;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.expReward,
    this.isCompleted = false,
  });

  void complete() {
    isCompleted = true;
  }
}

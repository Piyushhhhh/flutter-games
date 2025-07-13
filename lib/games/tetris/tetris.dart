// Tetris Game - Professional Retro Implementation
//
// A classic Tetris game with modern Flutter features and retro cyberpunk aesthetics.
// Structured using MVC (Model-View-Controller) pattern for clean architecture.
//
// MVC Architecture:
// - Models: Data structures and game entities (tetris_models.dart)
// - Controllers: Business logic and state management (tetris_controller.dart)
// - Views: UI components and presentation layer (tetris_screen.dart)
//
// Features include:
// - 7 standard tetromino pieces with proper rotation
// - Ghost piece preview showing landing position
// - Hold functionality to save pieces for later
// - Progressive difficulty with increasing speed
// - Line clear animations with particle effects
// - Touch controls with gesture support
// - Professional scoring system
// - Retro neon visual design matching other games

// Export MVC components following proper architecture
export 'models/tetris_models.dart';
export 'controllers/tetris_controller.dart';
export 'views/tetris_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class BombermanGame extends StatefulWidget {
  const BombermanGame({Key? key}) : super(key: key);

  @override
  State<BombermanGame> createState() => _BombermanGameState();
}

class _BombermanGameState extends State<BombermanGame> {
  static const int gridSize = 13;
  static const int tileSize = 30;

  // Game state
  List<List<TileType>> grid = [];
  PlayerPosition player = PlayerPosition(1, 1);
  List<Bomb> bombs = [];
  List<Explosion> explosions = [];
  List<Enemy> enemies = [];
  bool gameOver = false;
  bool gameWon = false;
  int score = 0;

  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    initializeGame();
    startGameLoop();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void initializeGame() {
    // Initialize grid
    grid = List.generate(
        gridSize, (i) => List.generate(gridSize, (j) => TileType.empty));

    // Create walls pattern
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (i == 0 || i == gridSize - 1 || j == 0 || j == gridSize - 1) {
          grid[i][j] = TileType.wall;
        } else if (i % 2 == 0 && j % 2 == 0) {
          grid[i][j] = TileType.wall;
        }
      }
    }

    // Add destructible blocks
    Random random = Random();
    for (int i = 1; i < gridSize - 1; i++) {
      for (int j = 1; j < gridSize - 1; j++) {
        if (grid[i][j] == TileType.empty &&
            !(i == 1 && j == 1) && // Don't block player start
            !(i == 1 && j == 2) &&
            !(i == 2 && j == 1)) {
          if (random.nextDouble() < 0.3) {
            grid[i][j] = TileType.destructible;
          }
        }
      }
    }

    // Add enemies
    enemies.clear();
    enemies.add(Enemy(gridSize - 2, gridSize - 2));
    enemies.add(Enemy(gridSize - 2, 1));
    enemies.add(Enemy(1, gridSize - 2));

    // Reset player position
    player = PlayerPosition(1, 1);
    bombs.clear();
    explosions.clear();
    gameOver = false;
    gameWon = false;
    score = 0;
  }

  void startGameLoop() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    if (gameOver || gameWon) return;

    setState(() {
      // Update bombs
      bombs.removeWhere((bomb) {
        bomb.timer--;
        if (bomb.timer <= 0) {
          explodeBomb(bomb);
          return true;
        }
        return false;
      });

      // Update explosions
      explosions.removeWhere((explosion) {
        explosion.timer--;
        return explosion.timer <= 0;
      });

      // Update enemies
      for (var enemy in enemies) {
        moveEnemy(enemy);
      }

      // Check collisions
      checkCollisions();

      // Check win condition
      if (enemies.isEmpty) {
        gameWon = true;
        gameTimer?.cancel();
      }
    });
  }

  void moveEnemy(Enemy enemy) {
    Random random = Random();
    List<Direction> possibleMoves = [];

    // Check all directions
    if (canMoveTo(enemy.x - 1, enemy.y)) possibleMoves.add(Direction.up);
    if (canMoveTo(enemy.x + 1, enemy.y)) possibleMoves.add(Direction.down);
    if (canMoveTo(enemy.x, enemy.y - 1)) possibleMoves.add(Direction.left);
    if (canMoveTo(enemy.x, enemy.y + 1)) possibleMoves.add(Direction.right);

    if (possibleMoves.isNotEmpty) {
      Direction direction = possibleMoves[random.nextInt(possibleMoves.length)];
      switch (direction) {
        case Direction.up:
          enemy.x--;
          break;
        case Direction.down:
          enemy.x++;
          break;
        case Direction.left:
          enemy.y--;
          break;
        case Direction.right:
          enemy.y++;
          break;
      }
    }
  }

  bool canMoveTo(int x, int y) {
    if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) return false;
    return grid[x][y] == TileType.empty;
  }

  void explodeBomb(Bomb bomb) {
    // Create explosion at bomb position
    explosions.add(Explosion(bomb.x, bomb.y, 30));

    // Create explosions in all directions
    for (Direction direction in Direction.values) {
      for (int i = 1; i <= bomb.range; i++) {
        int newX = bomb.x;
        int newY = bomb.y;

        switch (direction) {
          case Direction.up:
            newX -= i;
            break;
          case Direction.down:
            newX += i;
            break;
          case Direction.left:
            newY -= i;
            break;
          case Direction.right:
            newY += i;
            break;
        }

        if (newX < 0 || newX >= gridSize || newY < 0 || newY >= gridSize) break;

        if (grid[newX][newY] == TileType.wall) break;

        explosions.add(Explosion(newX, newY, 30));

        if (grid[newX][newY] == TileType.destructible) {
          grid[newX][newY] = TileType.empty;
          score += 10;
          break;
        }
      }
    }
  }

  void checkCollisions() {
    // Check player-enemy collision
    for (var enemy in enemies) {
      if (enemy.x == player.x && enemy.y == player.y) {
        gameOver = true;
        gameTimer?.cancel();
        return;
      }
    }

    // Check player-explosion collision
    for (var explosion in explosions) {
      if (explosion.x == player.x && explosion.y == player.y) {
        gameOver = true;
        gameTimer?.cancel();
        return;
      }
    }

    // Check enemy-explosion collision
    enemies.removeWhere((enemy) {
      for (var explosion in explosions) {
        if (explosion.x == enemy.x && explosion.y == enemy.y) {
          score += 100;
          return true;
        }
      }
      return false;
    });
  }

  void movePlayer(Direction direction) {
    if (gameOver || gameWon) return;

    int newX = player.x;
    int newY = player.y;

    switch (direction) {
      case Direction.up:
        newX--;
        break;
      case Direction.down:
        newX++;
        break;
      case Direction.left:
        newY--;
        break;
      case Direction.right:
        newY++;
        break;
    }

    if (canMoveTo(newX, newY)) {
      setState(() {
        player.x = newX;
        player.y = newY;
      });
    }
  }

  void placeBomb() {
    if (gameOver || gameWon) return;

    // Check if there's already a bomb at this position
    bool bombExists =
        bombs.any((bomb) => bomb.x == player.x && bomb.y == player.y);
    if (bombExists) return;

    setState(() {
      bombs.add(Bomb(player.x, player.y, 30, 2)); // 3 second timer, range 2
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Bomberman', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Score: $score',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowUp:
                movePlayer(Direction.up);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowDown:
                movePlayer(Direction.down);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowLeft:
                movePlayer(Direction.left);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowRight:
                movePlayer(Direction.right);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.space:
                placeBomb();
                return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: gridSize * tileSize.toDouble(),
                height: gridSize * tileSize.toDouble(),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Stack(
                  children: [
                    // Grid
                    ...buildGrid(),
                    // Player
                    buildPlayer(),
                    // Enemies
                    ...buildEnemies(),
                    // Bombs
                    ...buildBombs(),
                    // Explosions
                    ...buildExplosions(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => movePlayer(Direction.up),
                    child: const Text('↑'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: placeBomb,
                    child: const Text('💣'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => movePlayer(Direction.left),
                    child: const Text('←'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => movePlayer(Direction.down),
                    child: const Text('↓'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => movePlayer(Direction.right),
                    child: const Text('→'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (gameOver)
                Column(
                  children: [
                    const Text(
                      'Game Over!',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        initializeGame();
                        startGameLoop();
                      },
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              if (gameWon)
                Column(
                  children: [
                    const Text(
                      'You Win!',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        initializeGame();
                        startGameLoop();
                      },
                      child: const Text('Play Again'),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              const Text(
                'Use arrow keys to move, space to place bomb',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildGrid() {
    List<Widget> tiles = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        tiles.add(
          Positioned(
            left: j * tileSize.toDouble(),
            top: i * tileSize.toDouble(),
            child: Container(
              width: tileSize.toDouble(),
              height: tileSize.toDouble(),
              decoration: BoxDecoration(
                color: getTileColor(grid[i][j]),
                border: Border.all(color: Colors.grey.shade800, width: 0.5),
              ),
              child: getTileIcon(grid[i][j]),
            ),
          ),
        );
      }
    }
    return tiles;
  }

  Color getTileColor(TileType type) {
    switch (type) {
      case TileType.empty:
        return Colors.green.shade900;
      case TileType.wall:
        return Colors.grey.shade700;
      case TileType.destructible:
        return Colors.brown.shade600;
    }
  }

  Widget? getTileIcon(TileType type) {
    switch (type) {
      case TileType.wall:
        return const Icon(Icons.stop, color: Colors.white, size: 20);
      case TileType.destructible:
        return const Icon(Icons.grass, color: Colors.green, size: 20);
      default:
        return null;
    }
  }

  Widget buildPlayer() {
    return Positioned(
      left: player.y * tileSize.toDouble(),
      top: player.x * tileSize.toDouble(),
      child: Container(
        width: tileSize.toDouble(),
        height: tileSize.toDouble(),
        child: const Icon(
          Icons.person,
          color: Colors.blue,
          size: 25,
        ),
      ),
    );
  }

  List<Widget> buildEnemies() {
    return enemies
        .map((enemy) => Positioned(
              left: enemy.y * tileSize.toDouble(),
              top: enemy.x * tileSize.toDouble(),
              child: Container(
                width: tileSize.toDouble(),
                height: tileSize.toDouble(),
                child: const Icon(
                  Icons.bug_report,
                  color: Colors.red,
                  size: 25,
                ),
              ),
            ))
        .toList();
  }

  List<Widget> buildBombs() {
    return bombs
        .map((bomb) => Positioned(
              left: bomb.y * tileSize.toDouble(),
              top: bomb.x * tileSize.toDouble(),
              child: Container(
                width: tileSize.toDouble(),
                height: tileSize.toDouble(),
                child: Icon(
                  Icons.circle,
                  color: bomb.timer > 15 ? Colors.black : Colors.red,
                  size: 20,
                ),
              ),
            ))
        .toList();
  }

  List<Widget> buildExplosions() {
    return explosions
        .map((explosion) => Positioned(
              left: explosion.y * tileSize.toDouble(),
              top: explosion.x * tileSize.toDouble(),
              child: Container(
                width: tileSize.toDouble(),
                height: tileSize.toDouble(),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.yellow,
                  size: 20,
                ),
              ),
            ))
        .toList();
  }
}

// Data classes
class PlayerPosition {
  int x, y;
  PlayerPosition(this.x, this.y);
}

class Bomb {
  int x, y, timer, range;
  Bomb(this.x, this.y, this.timer, this.range);
}

class Explosion {
  int x, y, timer;
  Explosion(this.x, this.y, this.timer);
}

class Enemy {
  int x, y;
  Enemy(this.x, this.y);
}

enum TileType { empty, wall, destructible }

enum Direction { up, down, left, right }

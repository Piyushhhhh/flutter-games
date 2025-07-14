// Represents a point on the game grid.
class Point {
  final int x, y;
  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) => other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

// Represents the direction of movement.
enum Direction { up, down, left, right }

// Represents the player (Pac-Man).
class Player {
  Point position;
  Direction direction;
  Player({required this.position, required this.direction});
}

// Represents a ghost.
enum GhostState { normal, frightened, eaten }

class Ghost {
  Point position;
  String imageAsset;
  Direction direction;
  bool isReleased;
  GhostState state;

  Ghost({
    required this.position,
    required this.imageAsset,
    this.direction = Direction.up,
    this.isReleased = false,
    this.state = GhostState.normal,
  });
}

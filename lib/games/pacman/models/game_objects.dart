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
class Ghost {
  Point position;
  Direction direction;
  final String imageAsset;
  bool isReleased;

  Ghost({
    required this.position,
    this.direction = Direction.up,
    required this.imageAsset,
    this.isReleased = false,
  });
}

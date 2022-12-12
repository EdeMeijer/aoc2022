class Coord {
  final int x, y;

  const Coord(this.x, this.y);

  Coord operator +(Coord other) => Coord(x + other.x, y + other.y);

  Coord operator -(Coord other) => Coord(x - other.x, y - other.y);

  @override
  bool operator ==(Object other) =>
      other is Coord && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Coord (y=$y, x=$x)';
}

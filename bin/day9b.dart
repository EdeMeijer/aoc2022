import 'package:aoc2022/data.dart';
import 'package:aoc2022/spatial.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  var input = await loadDataLines(9);

  var rope = [for (var _ in 0.until(10)) Coord(0, 0)];

  var visited = {rope[9]};

  for (final cmd in input.expand(parseCommand)) {
    rope[0] += cmd;
    for (var i = 1; i < 10; i ++) {
      rope[i] = moveKnot(rope[i - 1], rope[i]);
    }
    visited.add(rope[9]);
  }

  print(visited.length);
}

const commands = {
  'R': Coord(1, 0),
  'U': Coord(0, -1),
  'L': Coord(-1, 0),
  'D': Coord(0, 1)
};

Iterable<Coord> parseCommand(String line) sync* {
  final parts = line.split(' ');
  for (var i = 0; i < int.parse(parts[1]); i++) {
    yield commands[parts[0]]!;
  }
}

Coord moveKnot(Coord parent, Coord knot) {
  var delta = parent - knot;

  if (delta.x.abs() == 2 || delta.y.abs() == 2) {
    return Coord(knot.x + delta.x.sign, knot.y + delta.y.sign);
  } else {
    return knot;
  }
}

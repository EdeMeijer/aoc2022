import 'package:aoc2022/data.dart';
import 'package:aoc2022/spatial.dart';

Future<void> main() async {
  var input = await loadDataLines(9);

  var head = Coord(0, 0);
  var tail = Coord(0, 0);

  var visited = {tail};

  for (final cmd in input.expand(parseCommand)) {
    head += cmd;
    tail = moveTail(head, tail);
    visited.add(tail);
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

Coord moveTail(Coord head, Coord tail) {
  var delta = head - tail;

  if (delta.x.abs() == 2 || delta.y.abs() == 2) {
    return Coord(tail.x + delta.x.sign, tail.y + delta.y.sign);
  } else {
    return tail;
  }
}

import 'package:aoc2022/data.dart';
import 'package:aoc2022/spatial.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final input = await loadDataLines(14);
  final lines = input.map(parseLine).toList();

  // Prepare world
  final world = <Coord, String>{};
  for (final line in lines) {
    for (var i = 0; i < line.length - 1; i ++) {
      var pos = line[i];
      world[pos] = '#';
      final end = line[i + 1];
      while (pos != end) {
        pos += (end - pos).sign;
        world[pos] = '#';
      }
    }
  }

  // Simulate sand
  final maxY = world.keys.map((e) => e.y).max();
  final order = [0, -1, 1];

  var overflowing = false;
  while (!overflowing) {
    var pos = Coord(500, 0);
    var landed = false;

    while (!landed && !overflowing) {
      var moved = false;
      for (final offset in order) {
        final candidate = pos + Coord(offset, 1);
        if (!world.containsKey(candidate)) {
          pos = candidate;
          moved = true;
          break;
        }
      }
      if (!moved) {
        landed = true;
        world[pos] = 'o';
      }
      if (pos.y == maxY) {
        overflowing = true;
      }
    }
  }

  final result = world.values.where((e) => e == 'o').length;

  print(result);
}

List<Coord> parseLine(String input) {
  return input.split(' -> ').map(parseCoord).toList();
}

Coord parseCoord(String input) {
  final parts = input.split(',').map(int.parse).toList();
  return Coord(parts[0], parts[1]);
}

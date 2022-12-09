import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final forest = (await loadDataLines(8))
      .map((line) => line.chars().map(int.parse).toList())
      .toList();

  final height = forest.length;
  final width = forest[0].length;
  final grid = 0.until(height).expand((y) => 0.until(width).map((x) => [y, x]));

  final scores = grid.map((c) {
    final y = c[0];
    final x = c[1];
    final tree = forest[y][x];
    final scanLines = [
      ScanLine(y, x, -1, 0, y),
      ScanLine(y, x, 1, 0, height - y - 1),
      ScanLine(y, x, 0, -1, x),
      ScanLine(y, x, 0, 1, width - x - 1),
    ];
    return scanLines
        .map((l) => project(forest, l))
        .fold(1, (cur, e) => cur * getVisible(tree, e).length);
  });

  print(scores.max());
}

class ScanLine {
  final int y, x, dy, dx, steps;

  const ScanLine(this.y, this.x, this.dy, this.dx, this.steps);
}

Iterable<int> project(List<List<int>> forest, ScanLine scanLine) sync* {
  var x = scanLine.x;
  var y = scanLine.y;
  for (var i = 0; i < scanLine.steps; i++) {
    y += scanLine.dy;
    x += scanLine.dx;
    yield forest[y][x];
  }
}

Iterable<int> getVisible(int baseHeight, Iterable<int> projection) sync* {
  for (final height in projection) {
    yield height;
    if (height >= baseHeight) {
      break;
    }
  }
}

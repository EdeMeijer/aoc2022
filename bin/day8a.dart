import 'dart:math';

import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  var id = 0;
  final forest = (await loadDataLines(8))
      .map((line) => line.chars().map((c) => Tree(id++, int.parse(c))).toList())
      .toList();

  final height = forest.length;
  final width = forest[0].length;

  final scanLines = [
    ...0.until(width).map((x) => ScanLine(-1, x, 1, 0, height)),
    ...0.until(width).map((x) => ScanLine(height, x, -1, 0, height)),
    ...0.until(height).map((y) => ScanLine(y, -1, 0, 1, width)),
    ...0.until(height).map((y) => ScanLine(y, width, 0, -1, width)),
  ];

  var visibleIds = scanLines
      .map((l) => project(forest, l))
      .expand(getVisible)
      .map((t) => t.id)
      .toSet();

  print(visibleIds.length);
}

class Tree {
  final int id, height;

  const Tree(this.id, this.height);
}

class ScanLine {
  final int y, x, dy, dx, steps;

  const ScanLine(this.y, this.x, this.dy, this.dx, this.steps);
}

Iterable<Tree> project(List<List<Tree>> forest, ScanLine scanLine) sync* {
  var x = scanLine.x;
  var y = scanLine.y;
  for (var i = 0; i < scanLine.steps; i++) {
    y += scanLine.dy;
    x += scanLine.dx;
    yield forest[y][x];
  }
}

Iterable<Tree> getVisible(Iterable<Tree> projection) sync* {
  var height = -1;
  for (final tree in projection) {
    if (tree.height > height) {
      yield tree;
    }
    height = max(height, tree.height);
  }
}

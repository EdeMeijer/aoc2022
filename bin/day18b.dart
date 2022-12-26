import 'dart:collection';
import 'dart:math';

import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final input = await loadDataLines(18);
  final points = input.map(parse).toSet();
  final outside = <Point>{};
  // Flood fill the outside of the shape in a bounding box so we know what's in and what's out
  final bb = getBoundingBox(points);
  final bbMin = bb.start.translate([-1, -1, -1]);
  final bbMax = bb.end.translate([1, 1, 1]);

  final queue = Queue<Point>()..add(bbMin);
  while (queue.isNotEmpty) {
    final next = queue.removeFirst();
    for (var dim = 0; dim < 3; dim++) {
      for (final sign in [-1, 1]) {
        final neighbor = next.modify(dim, sign);
        final inBB = 0.until(3).where((dim) => neighbor.loc[dim] < bbMin.loc[dim] || neighbor.loc[dim] > bbMax.loc[dim]).isEmpty;
        if (inBB && !points.contains(neighbor) && outside.add(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
  }

  var result = 0;
  for (final point in points) {
    for (var dim = 0; dim < 3; dim++) {
      for (final sign in [-1, 1]) {
        final neighbor = point.modify(dim, sign);
        final isOutside = outside.contains(neighbor);
        if (isOutside) {
          result++;
        }
      }
    }
  }

  print(result);
}

class Point {
  final List<int> loc;

  const Point(this.loc);

  Point modify(int dim, int value) {
    final newLoc = loc.toList();
    newLoc[dim] += value;
    return Point(newLoc);
  }

  Point translate(List<int> mod) {
    final newLoc = 0.until(3).map((e) => loc[e] + mod[e]).toList();
    return Point(newLoc);
  }

  @override
  int get hashCode => Object.hashAll(loc);

  @override
  bool operator ==(Object other) => other is Point && loc.listEquals(other.loc);

  @override
  String toString() => loc.toString();
}

BoundingBox getBoundingBox(Set<Point> points) {
  var start = points.first.loc.toList();
  var end = start.toList();
  for (final point in points) {
    for (var d = 0; d < 3; d ++) {
      start[d] = min(start[d], point.loc[d]);
      end[d] = max(end[d], point.loc[d]);
    }
  }
  return BoundingBox(Point(start), Point(end));
}

class BoundingBox {
  final Point start, end;

  const BoundingBox(this.start, this.end);
}

Point parse(String input) {
  return Point(input.split(',').map(int.parse).toList());
}

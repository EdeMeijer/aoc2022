import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final input = await loadDataLines(18);
  final points = input.map(parse).toSet();

  var result = 0;
  for (final point in points) {
    for (var dim = 0; dim < 3; dim++) {
      for (final sign in [-1, 1]) {
        final neighbor = point.modify(dim, sign);
        final touching = points.contains(neighbor);
        if (!touching) {
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

  @override
  int get hashCode => Object.hashAll(loc);

  @override
  bool operator ==(Object other) => other is Point && loc.listEquals(other.loc);
}

Point parse(String input) {
  return Point(input.split(',').map(int.parse).toList());
}

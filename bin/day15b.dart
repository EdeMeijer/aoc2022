import 'package:aoc2022/data.dart';
import 'package:aoc2022/range.dart';
import 'package:aoc2022/spatial.dart';

Future<void> main() async {
  final input = await loadDataLines(15);
  final sensors = input.map(parse).toList();

  for (var scanY = 0; scanY <= 4000000; scanY ++) {
    // For each sensor, determine the horizontal range it can see at the scan
    // position, if any
    final scanRanges = sensors
        .map((s) => s.getVisibleRowRangeAt(scanY))
        .where((r) => r != null)
        .map((r) => r!)
        .toList();

    // Merge the ranges together
    final merged = Range.union(scanRanges);
    if (merged.length > 1) {
      final x = merged[0].end;
      final result = x * 4000000 + scanY;
      print(result);
      break;
    }
  }
}

class Sensor {
  final Coord pos, beacon;

  const Sensor(this.pos, this.beacon);

  int get range => pos.manhattanDist(beacon);

  Range? getVisibleRowRangeAt(int y) {
    final rowRange = range - (pos.y - y).abs();
    if (rowRange < 0) {
      return null;
    }
    return Range(pos.x - rowRange, pos.x + rowRange + 1);
  }
}

final numberPattern = RegExp(r'-?\d+');

Sensor parse(String line) {
  final values = numberPattern
      .allMatches(line)
      .map((m) => int.parse(m.group(0)!))
      .toList();

  return Sensor(Coord(values[0], values[1]), Coord(values[2], values[3]));
}

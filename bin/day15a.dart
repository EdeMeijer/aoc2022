import 'package:aoc2022/data.dart';
import 'package:aoc2022/range.dart';
import 'package:aoc2022/spatial.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final input = await loadDataLines(15);
  final sensors = input.map(parse).toList();

  const scanY = 2000000;

  // Collect unique beacons
  final beacons = sensors.map((s) => s.beacon).toSet();

  // For each sensor, determine the horizontal range it can see at the scan
  // position, if any
  final scanRanges = sensors
      .map((s) => s.getVisibleRowRangeAt(scanY))
      .where((r) => r != null)
      .map((r) => r!)
      .toList();

  // Merge the ranges together
  final merged = Range.union(scanRanges);

  final numBeacons = beacons.where((b) => b.y == scanY).length;
  final result = merged.map((e) => e.length).sum() - numBeacons;

  print(result);
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

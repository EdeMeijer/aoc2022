import 'package:aoc2022/data.dart';
import 'package:aoc2022/spatial.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final input = await loadDataLines(12);

  final height = input.length;
  final width = input[0].length;

  final coords = [...0.until(height).expand((y) => 0.until(width).map((x) => Coord(x, y)))];
  final start = coords.where((c) => input[c.y][c.x] == 'E').first;

  final heightmap = Map.fromEntries(coords.map((c) => MapEntry(c, parseHeight(input[c.y][c.x]))));

  // Dijkstra's algorithm
  final offsets = [Coord(-1, 0), Coord(1, 0), Coord(0, -1), Coord(0, 1)];

  final dist = Map.fromEntries(coords.map((c) => MapEntry(c, 2 << 52)));
  dist[start] = 0;

  final Q = [...coords];
  while (Q.isNotEmpty) {
    Q.sort((a, b) => dist[a]!.compareTo(dist[b]!));
    final u = Q[0];
    Q.removeAt(0);
    for (final offset in offsets) {
      final v = u + offset;
      if (Q.contains(v) && heightmap[v]! - heightmap[u]! >= -1) {
        final alt = dist[u]! + 1;
        if (alt < dist[v]!) {
          dist[v] = alt;
        }
      }
    }
  }

  final result = heightmap.entries.where((e) => e.value == 0).map((e) => dist[e.key]!).min();

  print(result);
}

int charCode(String char) => char.runes.first;

int parseHeight(String c) =>
    c == 'S' ? 0 : c == 'E' ? 25 : charCode(c) - charCode('a');

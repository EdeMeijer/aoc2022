import 'package:aoc2022/data.dart';

Future<void> main() async {
  final lines = await loadDataLines(4);
  final result = lines.map(parsePair).where(isRedundant).length;

  print(result);
}

class Pair {
  final Range a, b;

  const Pair(this.a, this.b);
}

class Range {
  final int first, last;

  const Range(this.first, this.last);

  bool contains(Range other) => first <= other.first && last >= other.last;
}

Range parseRange(String input) {
  final parts = input.split('-').map(int.parse).toList();
  return Range(parts[0], parts[1]);
}

Pair parsePair(String input) {
  final ranges = input.split(',').map(parseRange).toList();
  return Pair(ranges[0], ranges[1]);
}

bool isRedundant(Pair pair) =>
    pair.a.contains(pair.b) || pair.b.contains(pair.a);

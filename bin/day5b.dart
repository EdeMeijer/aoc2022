import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final input = await loadDataString(5);
  final inputSegments = input.split('\n\n');

  final stackLines = inputSegments[0].split('\n').toList()..removeLast();
  final stackRows = stackLines
      .map((e) => e.chars().chunk(4).map((e) => e[1] == ' ' ? null : e[1]).toList())
      .toList();
  final numStacks = stackRows.map((e) => e.length).max();
  final stacks = 0.until(numStacks)
      .map((i) => stackRows
          .map((r) => i >= r.length ? null : r[i])
          .where((e) => e != null)
          .toList())
      .toList();

  final moveValuePattern = RegExp('\\d+');
  final moves = inputSegments[1]
      .split('\n')
      .map((e) => moveValuePattern
          .allMatches(e)
          .map((e) => int.parse(e.group(0)!))
          .toList())
      .toList();

  for (final move in moves) {
      final source = stacks[move[1] - 1];
      final items = source.sublist(0, move[0]);
      source.removeRange(0, move[0]);
      stacks[move[2] - 1].insertAll(0, items);
  }

  final result = stacks.map((e) => e.first!).join();

  print(result);
}

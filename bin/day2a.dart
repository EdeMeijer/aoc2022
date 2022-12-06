import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final lines = await loadDataLines(2);
  final rules = lines.map(parseRule).toList();
  final result = rules.map(playRound).sum();

  print(result);
}

class Rule {
  final int other, me;

  const Rule(this.other, this.me);
}

Rule parseRule(String line) {
  final moves = line.split(' ').map(parseMove).toList();
  return Rule(moves[0], moves[1]);
}

const movesMap = {'A': 0, 'B': 1, 'C': 2, 'X': 0, 'Y': 1, 'Z': 2};

int parseMove(String move) => movesMap[move]!;

int playRound(Rule rule) {
  final delta = (rule.me - rule.other) % 3;
  return (delta == 2 ? 0 : delta == 1 ? 6 : 3) + rule.me + 1;
}

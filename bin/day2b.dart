import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final lines = await loadDataLines(2);
  final rules = lines.map(parseRule).toList();
  final result = rules.map(playRound).sum();

  print(result);
}

class Rule {
  final int other, outcome;

  const Rule(this.other, this.outcome);
}

Rule parseRule(String line) {
  final moves = line.split(' ');
  return Rule(parseMove(moves[0]), parseOutcome(moves[1]));
}

const movesMap = {'A': 0, 'B': 1, 'C': 2};
const outcomesMap = {'X': 2, 'Y': 0, 'Z': 1};

int parseMove(String input) => movesMap[input]!;
int parseOutcome(String input) => outcomesMap[input]!;

int playRound(Rule rule) {
  final me = (rule.other + rule.outcome) % 3;
  return (rule.outcome == 2 ? 0 : rule.outcome == 1 ? 6 : 3) + me + 1;
}

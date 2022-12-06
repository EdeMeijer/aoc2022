import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final lines = await loadDataLines(3);
  final result = lines.chunk(3).map(getGroupBadge).map(getPrio).sum();

  print(result);
}

const items = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

int getPrio(String item) => items.indexOf(item) + 1;

String getGroupBadge(List<String> group) => group
    .map((sack) => sack.chars().toSet())
    .reduce((value, element) => value.intersection(element))
    .first;

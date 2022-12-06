import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final lines = await loadDataLines(3);
  final result = lines.map(getDuplicateItem).map(getPrio).sum();

  print(result);
}

const items = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

int getPrio(String item) => items.indexOf(item) + 1;

String getDuplicateItem(String sack) {
  final mid = sack.length ~/ 2;
  final left = sack.substring(0, mid);
  final right = sack.substring(mid);
  return left.chars().toSet().intersection(right.chars().toSet()).first;
}

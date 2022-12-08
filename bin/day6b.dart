import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final buffer = await loadDataString(6);

  final result = 14.until(buffer.length + 1)
      .where((i) => buffer.substring(i - 14, i).chars().toSet().length == 14)
      .first;

  print(result);
}

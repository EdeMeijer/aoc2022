import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final contents = await loadDataString(1);

  final result = contents
      .split('\n\n')
      .map((e) => e.split('\n').map(int.parse).sum())
      .max();

  print(result);
}

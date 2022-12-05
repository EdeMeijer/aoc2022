import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final contents = await loadDataString(1);

  final perElfSorted = contents
      .split('\n\n')
      .map((e) => e.split('\n').map(int.parse).sum())
      .toList()
      ..sort((a, b) => -a.compareTo(b));

  final result = perElfSorted.sublist(0, 3).sum();

  print(result);
}

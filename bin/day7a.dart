import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final lines = await loadDataLines(7);

  final files = <String, int>{};
  final dirs = <String>{};

  var dirParts = [];
  var dir = '/';

  for (final line in lines.skip(1)) {
    if (line.startsWith(r'$')) {
      final args = line.substring(2).split(' ');

      if (args[0] == 'cd') {
        if (args[1] == '..') {
          dirParts.removeLast();
        } else {
          dirParts.add(args[1]);
        }
        dir = '/${dirParts.join('/')}${dirParts.isNotEmpty ? '/' : ''}';
        dirs.add(dir);
      }
    } else {
      final parts = line.split(' ');
      if (parts[0] != 'dir') {
        final file = '$dir${parts[1]}';
        files[file] = int.parse(parts[0]);
      }
    }
  }

  final stats = dirs.map((d) => files.entries
      .where((e) => e.key.startsWith(d))
      .map((e) => e.value)
      .sum());

  final result = stats.where((stat) => stat <= 100000).sum();

  print(result);
}

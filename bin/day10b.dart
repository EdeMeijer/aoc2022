import 'dart:collection';

import 'package:aoc2022/data.dart';

Future<void> main() async {
  var input = await loadDataLines(10);
  var inputQueue = Queue<String>.from(input);

  var pos = 1;
  int? addBuffer;

  var result = [for(var y = 0; y < 6; y ++) List.filled(40, false)];

  for (var cycle = 0; cycle < 6 * 40; cycle++) {
    final y = cycle ~/ 40;
    final x = cycle % 40;
    result[y][x] = x >= pos - 1 && x <= pos + 1;

    if (addBuffer != null) {
      pos += addBuffer;
      addBuffer = null;
    } else {
      if (inputQueue.isEmpty) {
        break;
      }
      var next = inputQueue.removeFirst();
      if (next != 'noop') {
        var parts = next.split(' ');
        addBuffer = int.parse(parts[1]);
      }
    }
  }

  print(result.map((l) => l.map((on) => on ? '#' : '.').join()).join('\n'));
}

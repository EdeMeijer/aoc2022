import 'dart:collection';

import 'package:aoc2022/data.dart';

Future<void> main() async {
  var input = await loadDataLines(10);
  var inputQueue = Queue<String>.from(input);

  var x = 1;
  int? addBuffer;
  var result = 0;

  for (var cycle = 1;; cycle++) {
    if ((cycle - 20) % 40 == 0) {
      result += x * cycle;
    }

    if (addBuffer != null) {
      x += addBuffer;
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

  print(result);
}

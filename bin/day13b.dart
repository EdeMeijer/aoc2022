import 'dart:math';

import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final input = await loadDataLines(13);

  final packets = input
      .where((l) => l != '')
      .map((l) => parse(Reader(l)))
      .toList();

  packets.addAll([
    [[2]],
    [[6]]
  ]);

  packets.sort(compare);

  final result = 0.until(packets.length).where((i) {
    final packStr = packets[i].toString();
    return packStr == '[[2]]' || packStr == '[[6]]';
  }).fold(1, (prev, e) => prev * (e + 1));

  print(result);
}

class Reader {
  final String buf;
  int pos = 0;

  Reader(this.buf);

  String peek() => buf[pos];

  String next() => buf[pos++];
}

Object parse(Reader input) {
  if (input.peek() == '[') {
    // It's a list
    input.next();
    final result = [];
    while (input.peek() != ']') {
      result.add(parse(input));
      if (input.peek() == ',') {
        input.next();
      }
    }
    input.next();
    return result;
  } else {
    final digits = <String>[];
    while (int.tryParse(input.peek()) != null) {
      digits.add(input.next());
    }
    return int.parse(digits.join());
  }
}

int compare(dynamic left, dynamic right) {
  if (left is int && right is int) {
    return left.compareTo(right);
  }
  if (left is int) {
    left = [left];
  }
  if (right is int) {
    right = [right];
  }
  for (var i = 0; i < min(left.length, right.length); i++) {
    final cmp = compare(left[i], right[i]);
    if (cmp != 0) {
      return cmp;
    }
  }

  return left.length.compareTo(right.length);
}

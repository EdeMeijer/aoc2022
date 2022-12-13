import 'dart:math';

import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final input = await loadDataString(13);

  final pairs = input
      .split('\n\n')
      .map((e) => e.split('\n').map((l) => parse(Reader(l))).toList())
      .toList();

  final result = 0
      .until(pairs.length)
      .where((i) => compare(pairs[i][0], pairs[i][1]) == -1)
      .map((i) => i + 1)
      .sum();

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

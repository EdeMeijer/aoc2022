import 'dart:math' as math;

extension NumberReductions on Iterable<int> {
  int sum() => reduce((a, b) => a + b);

  int max() => reduce((a, b) => math.max(a, b));
}

extension NumberRanges on int {
  Iterable<int> until(int end) sync* {
    for (var i = this; i < end; i++) {
      yield i;
    }
  }
}

extension StringIterations on String {
  Iterable<String> chars() => 0.until(length).map((i) => this[i]);
}

extension IterableChunking<T> on Iterable<T> {
  Iterable<List<T>> chunk(int size) sync* {
    List<T> next = [];
    for (final item in this) {
      next.add(item);
      if (next.length == size) {
        yield next;
        next = [];
      }
    }
    if (next.isNotEmpty) {
      yield next;
    }
  }
}

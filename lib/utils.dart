import 'dart:math' as math;

extension IntReductions on Iterable<int> {
  int sum() => fold(0, (a, b) => a + b);

  int min() => reduce((a, b) => math.min(a, b));

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

Iterable<List<T>> permute<T>(Set<T> items) sync* {
  if (items.length == 1) {
    yield items.toList();
    return;
  }
  for (final item in items) {
    final remaining = items.toSet()..remove(item);
    for (final rest in permute(remaining)) {
      yield [item, ...rest];
    }
  }
}

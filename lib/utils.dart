import 'dart:math' as math;

extension NumberReductions on Iterable<int> {
  int sum() => reduce((a, b) => a + b);

  int max() => reduce((a, b) => math.max(a, b));
}

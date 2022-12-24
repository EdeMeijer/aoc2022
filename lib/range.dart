import 'dart:math';

class Range {
  final int start, end;

  const Range(this.start, this.end);

  bool overlapsWith(Range other) => other.start < end && start < other.end;

  Range mergeWith(Range other) {
    if (!overlapsWith(other)) {
      throw Exception('Ranges do not overlap');
    }
    return Range(min(start, other.start), max(end, other.end));
  }

  int get length => end - start;

  @override
  String toString() => '$start - $end';

  static List<Range> union(Iterable<Range> ranges) {
    final remaining = [...ranges];
    remaining.sort((a, b) => a.start.compareTo(b.start));

    final merged = <Range>[];
    while (remaining.isNotEmpty) {
      var next = remaining.first;
      remaining.remove(next);

      final taken = <Range>[];
      for (final other in remaining) {
        if (other.overlapsWith(next)) {
          next = next.mergeWith(other);
          taken.add(other);
        }
      }
      for (final range in taken) {
        remaining.remove(range);
      }
      merged.add(next);
    }
    return merged;
  }
}

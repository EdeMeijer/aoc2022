import 'dart:collection';

import 'package:aoc2022/data.dart';

Future<void> main() async {
  final input = await loadDataLines(16);
  final valves = Map.fromEntries(input.map(parse).map((e) => MapEntry(e.id, e)));

  // Calculate the walking distances between all valves using BFS
  final allDistances = <String, Map<String, int>>{};

  for (final origin in valves.keys) {
    var todo = Queue<String>()..add(origin);

    final distances = <String, int>{};
    distances[origin] = 0;

    while (todo.isNotEmpty) {
      final cur = todo.removeFirst();
      final nextDist = distances[cur]! + 1;
      for (final target in valves[cur]!.targets) {
        if (!distances.containsKey(target)) {
          distances[target] = nextDist;
          todo.add(target);
        }
      }
    }

    allDistances[origin] = distances;
  }

  int getUpperBound(Iterable<String> partialSolution, Set<String> remaining) {
    var totalRate = 0;
    var score = 0;
    var cur = 'AA';
    var time = 0;

    for (final target in partialSolution) {
      final dist = allDistances[cur]![target]!;
      final nextTime = time + dist + 1;
      if (nextTime >= 30) {
        // Time is up, cannot open next valve
        break;
      }

      time = nextTime;
      score += (dist + 1) * totalRate;
      totalRate += valves[target]!.rate;
      cur = target;
    }

    // For the remaining nodes, compute an upper bound on the additional score they could provide. Just order them
    // by flow rate, and pretend all their distances are always 1.
    final remainingRates = remaining.map((e) => valves[e]!.rate).toList()..sort((a, b) => b.compareTo(a));
    for (final rate in remainingRates) {
      final nextTime = time + 2;
      if (nextTime >= 30) {
        // Time is up, cannot open next valve
        break;
      }

      time = nextTime;
      score += 2 * totalRate;
      totalRate += rate;
    }

    // Wait out remaining time for the opened valves
    score += (30 - time) * totalRate;

    return score;
  }

  // Select valve IDs that have any flow
  var useValves = valves.values.where((v) => v.rate > 0).map((e) => e.id).toList();

  var highScore = 0;

  void solveRecursive(List<String> solution) {
    final available = useValves.toSet()..removeAll(solution);

    // We need to go deeper
    final newAvailable = available.toSet();
    final upperBounds = <String, int>{};
    for (final candidate in available) {
      newAvailable.remove(candidate);
      final newSolution = [...solution, candidate];
      final upperBound = getUpperBound(newSolution, newAvailable);
      if (upperBound > highScore) {
        upperBounds[candidate] = upperBound;
      }
      if (newAvailable.isEmpty) {
        // End of search
        if (upperBound > highScore) {
          highScore = upperBound;
        }
        return;
      }
      newAvailable.add(candidate);
    }

    final entries = upperBounds.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (var entry in entries) {
      solveRecursive([...solution, entry.key]);
    }
  }

  solveRecursive([]);

  print(highScore);
}

class Valve {
  final String id;
  final int rate;
  final List<String> targets;

  const Valve(this.id, this.rate, this.targets);
}

Valve parse(String input) {
  final parts = input.replaceAll(';', '').replaceAll(',', '').split(' ');
  final rate = int.parse(parts[4].split('=')[1]);
  return Valve(parts[1], rate, parts.sublist(9));
}


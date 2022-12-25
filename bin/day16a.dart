import 'dart:collection';
import 'dart:math';

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

  int evaluateOrder(Iterable<String> order) {
    var totalRate = 0;
    var score = 0;
    var cur = 'AA';
    var time = 0;

    for (final target in order) {
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

    // Wait out remaining time
    score += (30 - time) * totalRate;
    return score;
  }

  // Select valve IDs that have any flow
  var useValves = valves.values.where((v) => v.rate > 0).map((e) => e.id).toSet();
  var remainingValves = useValves.toSet();

  // Select each next step by shuffling the rest of the solution many times and take the highest scores. Ugly.
  List<String> solution = [];
  const steps = 100000;
  
  for (var i = 0; i < useValves.length - 1; i ++) {
    var winner = "";
    var bestScore = 0;

    for (var candidate in remainingValves) {
      var remainingAfter = remainingValves.where((v) => v != candidate).toList();

      var maximum = 0;
      for (var i = 0; i < steps; i ++) {
        remainingAfter.shuffle();
        maximum = max(maximum, evaluateOrder([...solution, candidate, ...remainingAfter]));
      }
      if (maximum > bestScore) {
        bestScore = maximum;
        winner = candidate;
      }
    }

    solution.add(winner);
    remainingValves.remove(winner);
  }
  solution.addAll(remainingValves);

  print(solution);
  print(evaluateOrder(solution));
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


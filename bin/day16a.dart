import 'dart:collection';
import 'dart:math';

import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

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

  // BFS
  final start = SearchNode({}, 'AA');
  final queue = Queue<SearchNode>()..add(start);
  final potentialFlow = valves.values.map((e) => e.rate).sum();
  final states = {start: State(0, 0, 0, potentialFlow)};
  var highScore = 0;

  void includeCandidate(SearchNode node, State state) {
    if (state.time == 30) {
      // Time is up, register the result and stop here
      highScore = max(highScore, state.realScore);
      return;
    }
    if (!states.containsKey(node) || states[node]!.potentialScore < state.potentialScore) {
      // Never saw this state, or the new version has a higher potential score, so we use it
      states[node] = state;
      queue.add(node);
    }
  }

  while (queue.isNotEmpty) {
    final next = queue.removeFirst();
    final state = states[next]!;

    // Find neighbor states
    final valve = valves[next.loc]!;
    final targets = valve.targets;

    // Consider moving to connected valves
    for (final target in targets) {
      final neighbor = SearchNode(next.opened, target);
      final neighborState =
          State(state.time + 1, state.realFlow, state.realScore + state.realFlow, state.potentialFlow);
      includeCandidate(neighbor, neighborState);
    }

    // Consider opening the current valve (if it has any rate at all)
    if (!next.opened.contains(next.loc) && valve.rate > 0) {
      final neighbor = SearchNode(next.opened.toSet()..add(next.loc), next.loc);
      final neighborState = State(state.time + 1, state.realFlow + valve.rate, state.realScore + state.realFlow,
          state.potentialFlow - valve.rate);
      includeCandidate(neighbor, neighborState);
    }
  }

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

class SearchNode {
  final Set<String> opened;
  final String loc;

  const SearchNode(this.opened, this.loc);

  @override
  int get hashCode {
    return Object.hash(loc, Object.hashAllUnordered(opened));
  }

  @override
  bool operator ==(Object other) {
    return other is SearchNode && loc == other.loc && opened.setEquals(other.opened);
  }
}

class State {
  final int time, realFlow, realScore, potentialFlow;

  const State(this.time, this.realFlow, this.realScore, this.potentialFlow);

  int get potentialScore => realScore + (30 - time) * potentialFlow;
}

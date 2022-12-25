import 'dart:collection';
import 'dart:math';

import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

Future<void> main() async {
  final input = await loadDataLines(16);
  final valves = Map.fromEntries(input.map(parse).map((e) => MapEntry(e.id, e)));

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

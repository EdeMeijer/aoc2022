import 'dart:collection';
import 'dart:math';

import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

const timeout = 26;

Future<void> main() async {
  final input = await loadDataLines(16);
  final valves = Map.fromEntries(input.map(parse).map((e) => MapEntry(e.id, e)));

  final relevantValves = valves.values.where((v) => v.rate > 0).map((v) => v.id).toSet();

  // BFS
  final start = SearchNode({}, 'AA', 'AA');
  final queue = Queue<SearchNode>()..add(start);
  final potentialFlow = valves.values.map((e) => e.rate).sum();
  final states = {start: State(0, 0, 0, potentialFlow)};
  State? bestState;
  var maxLowerBound = 0;

  void includeCandidate(SearchNode node, State state) {
    if (state.time == timeout || node.opened.length == relevantValves.length) {
      // Time is up or we are done, register the result and stop here
      if (bestState == null || state.upperBound > bestState!.upperBound) {
        bestState = state;
      }
      return;
    }

    if (state.upperBound <= maxLowerBound) {
      // This state can never become the best result, stop here
      return;
    }

    maxLowerBound = max(maxLowerBound, state.lowerBound);

    if (!states.containsKey(node) || states[node]!.upperBound < state.upperBound) {
      // Never saw this state, or the new version has a higher potential score, so we use it
      states[node] = state;
      queue.add(node);
    }
  }

  Iterable<Action> computeActions(SearchNode node, String loc) sync* {
    final valve = valves[loc]!;

    for (final target in valve.targets) {
      yield Goto(target);
    }

    // Consider opening the current valve (if it has any rate at all)
    if (!node.opened.contains(loc) && relevantValves.contains(loc)) {
      yield OpenValve(valve);
    }
  }

  while (queue.isNotEmpty) {
    final next = queue.removeFirst();
    final state = states[next]!;

    final actions1 = computeActions(next, next.loc1).toList();
    var actions2 = computeActions(next, next.loc2).toList();

    if (next.loc1 == next.loc2) {
      // If we are on the same spot, the elephant should not open valves
      actions2 = actions2.where((a) => a is! OpenValve).toList();
    }

    for (final action1 in actions1) {
      for (final action2 in actions2) {
        includeCandidate(next.applyActions(action1, action2), state.applyActions(action1, action2));
      }
    }
  }

  print(bestState!.upperBound);
}

abstract class Action {}

class OpenValve implements Action {
  final Valve valve;

  OpenValve(this.valve);
}

class Goto implements Action {
  final String target;

  const Goto(this.target);
}

class Valve {
  final String id;
  final int rate;
  final List<String> targets;

  const Valve(this.id, this.rate, this.targets);

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is Valve && id == other.id;
  }
}

Valve parse(String input) {
  final parts = input.replaceAll(';', '').replaceAll(',', '').split(' ');
  final rate = int.parse(parts[4].split('=')[1]);
  return Valve(parts[1], rate, parts.sublist(9));
}

class SearchNode {
  final Set<String> opened;
  final String loc1, loc2;

  const SearchNode(this.opened, this.loc1, this.loc2);

  SearchNode applyActions(Action a1, Action a2) {
    final newOpened = opened.toSet();

    final newLoc1 = a1 is Goto ? a1.target : loc1;
    final newLoc2 = a2 is Goto ? a2.target : loc2;

    if (a1 is OpenValve) {
      newOpened.add(loc1);
    }
    if (a2 is OpenValve) {
      newOpened.add(loc2);
    }
    return SearchNode(newOpened, newLoc1, newLoc2);
  }

  @override
  int get hashCode {
    return Object.hash(Object.hashAllUnordered([loc1, loc2]), Object.hashAllUnordered(opened));
  }

  @override
  bool operator ==(Object other) {
    return other is SearchNode && {loc1, loc2}.setEquals({other.loc1, other.loc2}) && opened.setEquals(other.opened);
  }

  @override
  String toString() => '$opened / $loc1 / $loc2';
}

class State {
  final int time, realFlow, realScore, potentialFlow;

  State(this.time, this.realFlow, this.realScore, this.potentialFlow);

  int get upperBound => realScore + (timeout - time) * (realFlow + potentialFlow);

  int get lowerBound => realScore + (timeout - time) * realFlow;

  State applyActions(Action a1, Action a2) {
    final openedValves = <Valve>{};
    if (a1 is OpenValve) {
      openedValves.add(a1.valve);
    }
    if (a2 is OpenValve) {
      openedValves.add(a2.valve);
    }

    final extraFlow = openedValves.map((e) => e.rate).sum();
    return State(time + 1, realFlow + extraFlow, realScore + realFlow, potentialFlow - extraFlow);
  }
}

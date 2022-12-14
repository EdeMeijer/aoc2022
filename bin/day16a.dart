import 'dart:collection';

import 'package:aoc2022/data.dart';
import 'package:aoc2022/utils.dart';

const timeout = 30;

Future<void> main() async {
  final input = await loadDataLines(16);
  final valves = Map.fromEntries(input.map(parse).map((e) => MapEntry(e.id, e)));

  final relevantValves = valves.values.where((v) => v.rate > 0).map((v) => v.id).toSet();

  // BFS
  final start = SearchNode({}, 'AA');
  final queue = Queue<SearchNode>()..add(start);
  final potentialFlow = valves.values.map((e) => e.rate).sum();
  final states = {start: State(0, 0, 0, potentialFlow, [])};
  State? bestState;

  void includeCandidate(SearchNode node, State state) {
    if (state.time == timeout || node.opened.length == relevantValves.length) {
      // Time is up or we are done, register the result and stop here
      if (bestState == null || state.potentialScore > bestState!.potentialScore) {
        bestState = state;
      }
      return;
    }
    if (!states.containsKey(node) || states[node]!.potentialScore < state.potentialScore) {
      // Never saw this state, or the new version has a higher potential score, so we use it
      states[node] = state;
      queue.add(node);
    }
  }

  Iterable<Action> computeActions(SearchNode node) sync* {
    final valve = valves[node.loc]!;

    for (final target in valve.targets) {
      yield Goto(target);
    }
    // Consider opening the current valve (if it has any rate at all)
    if (!node.opened.contains(node.loc) && relevantValves.contains(node.loc)) {
      yield OpenValve(valve);
    }

    yield Wait();
  }

  while (queue.isNotEmpty) {
    final next = queue.removeFirst();
    final state = states[next]!;

    for (final action in computeActions(next)) {
      includeCandidate(next.applyAction(action), state.applyAction(action));
    }
  }

  print(bestState!.actions);
  print(bestState!.potentialScore);
}

abstract class Action {}

class OpenValve implements Action {
  final Valve valve;

  OpenValve(this.valve);

  @override
  String toString() => 'open valve';
}

class Goto implements Action {
  final String target;

  const Goto(this.target);

  @override
  String toString() => 'goto $target';
}

class Wait implements Action {
  @override
  String toString() => 'wait';
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

  SearchNode applyAction(Action action) {
    final newLoc = action is Goto ? action.target : loc;
    final newOpened = action is OpenValve ? (opened.toSet()..add(loc)) : opened;
    return SearchNode(newOpened, newLoc);
  }

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
  final List<String> actions;

  State(this.time, this.realFlow, this.realScore, this.potentialFlow, this.actions);

  int get potentialScore => realScore + (timeout - time) * (realFlow + potentialFlow);

  State applyAction(Action action) {
    final extraFlow = action is OpenValve ? action.valve.rate : 0;

    return State(time + 1, realFlow + extraFlow, realScore + realFlow, potentialFlow - extraFlow,
        [...actions, action.toString()]);
  }
}

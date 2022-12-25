import 'dart:collection';

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

  Iterable<Action> computeActions(SearchNode node, String loc) sync* {
    final valve = valves[loc]!;

    for (final target in valve.targets) {
      yield Goto(target);
    }
    // Consider opening the current valve (if it has any rate at all)
    if (!node.opened.contains(loc) && relevantValves.contains(loc)) {
      yield OpenValve(valve);
    }

    yield Wait();
  }

  while (queue.isNotEmpty) {
    final next = queue.removeFirst();
    final state = states[next]!;

    final actions1 = computeActions(next, next.loc1).toList();
    final actions2 = computeActions(next, next.loc2).toList();

    for (final action1 in actions1) {
      for (final action2 in actions2) {
        includeCandidate(next.applyActions(action1, action2), state.applyActions(action1, action2));
      }
    }
  }

  print(bestState!.actions.join('\n'));
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
}

class State {
  final int time, realFlow, realScore, potentialFlow;
  final List<String> actions;

  State(this.time, this.realFlow, this.realScore, this.potentialFlow, this.actions);

  int get potentialScore => realScore + (timeout - time) * (realFlow + potentialFlow);

  State applyActions(Action a1, Action a2) {
    final openedValves = <Valve>{};
    if (a1 is OpenValve) {
      openedValves.add(a1.valve);
    }
    if (a2 is OpenValve) {
      openedValves.add(a2.valve);
    }

    final extraFlow = openedValves.map((e) => e.rate).sum();

    return State(time + 1, realFlow + extraFlow, realScore + realFlow, potentialFlow - extraFlow,
        [...actions, 'Me: $a1, Elephant: $a2']);
  }
}

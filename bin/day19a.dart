import 'dart:collection';

import 'package:aoc2022/data.dart';

Future<void> main() async {
  final input = await loadDataLines(19);

  final blueprints = input.map(parseLine).toList();

  var result = 0;
  for (var i = 0; i < blueprints.length; i ++) {
    final blueprint = blueprints[i];
    final score = solve(blueprint);
    result += (i + 1) * score;
  }

  print(result);
}

class RobotType {
  final Material produces;
  final Map<Material, int> cost;

  const RobotType(this.produces, this.cost);
}

enum Material { ore, clay, obsidian, geode }

typedef Blueprint = Map<Material, RobotType>;

final robotPattern = RegExp('\\d+');

Blueprint parseLine(String input) {
  return Map.fromEntries(input
      .split(':')[1]
      .split('.')
      .map((s) => s.trim())
      .where((s) => s != '')
      .map(parseRobot)
      .map((t) => MapEntry(t.produces, t)));
}

RobotType parseRobot(String input) {
  final parts = input.split(' ');
  final cost = <Material, int>{};
  for (var i = 4; i < parts.length; i += 3) {
    cost[Material.values.byName(parts[i + 1])] = int.parse(parts[i]);
  }
  return RobotType(Material.values.byName(parts[1]), cost);
}

class State {
  final Map<Material, int> materials, robots;

  const State(this.materials, this.robots);

  State copy() => State({...materials}, {...robots});

  @override
  String toString() => Material.values.map((m) => '${materials[m]!}/${robots[m]!}').join(',');
}

class Step {
  final Material? built;
  final State startState, endState;

  const Step(this.built, this.startState, this.endState);
}

int solve(Blueprint blueprint) {
  var state = State({Material.ore: 0, Material.clay: 0, Material.obsidian: 0, Material.geode: 0},
      {Material.ore: 1, Material.clay: 0, Material.obsidian: 0, Material.geode: 0});

  var highScore = 0;
  final solution = Queue<Step>();
  final uniqueStates = {state.toString()};

  bool reverted = false;
  Material? after;

  for (var step = 1;; step++) {
    // If we are trying to find a consecutive step, but the last time we already couldn't build any robot
    // (after == null), then there is nothing we can do
    var tookStep = false;
    if (solution.length < 24 && !(reverted && after == null)) {
      // Potentially take another step. Decide what kind of robot to make, if any.
      Material? makeRobot;

      final startIndex = reverted ? Material.values.indexOf(after!) + 1 : 0;
      for (final material in Material.values.sublist(startIndex)) {
        final robotType = blueprint[material]!;
        final canMake = !robotType.cost.entries.any((e) => state.materials[e.key]! < e.value);

        if (canMake) {
          makeRobot = material;
          break;
        }
      }

      tookStep = true;

      final nextState = state.copy();

      // Simulate robots gathering materials
      for (final entry in state.robots.entries) {
        nextState.materials[entry.key] = nextState.materials[entry.key]! + entry.value;
      }

      if (makeRobot != null) {
        // Take required materials from stock
        for (final entry in blueprint[makeRobot]!.cost.entries) {
          nextState.materials[entry.key] = nextState.materials[entry.key]! - entry.value;
        }
        // The factory has now produced a robot
        nextState.robots[makeRobot] = nextState.robots[makeRobot]! + 1;
      }

      if (uniqueStates.add(nextState.toString())) {
        solution.addLast(Step(makeRobot, state, nextState));
        state = nextState;
        reverted = false;
      } else {
        // Oh, we saw this exact state before, so this can never result in the best result anyway. Abort
        tookStep = false;
      }
    }

    if (!tookStep) {
      // Could not take another step, need to revert a step
      if (solution.isEmpty) {
        // Done
        break;
      }
      final removedStep = solution.removeLast();
      after = removedStep.built;
      state = removedStep.startState;
      reverted = true;
    }

    if (solution.length == 24) {
      final geodes = state.materials[Material.geode]!;
      if (geodes > highScore) {
        highScore = geodes;
      }
    }
  }

  return highScore;
}

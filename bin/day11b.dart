import 'dart:collection';

import 'package:aoc2022/data.dart';

Future<void> main() async {
  var input = await loadDataString(11);
  var troop = input.split('\n\n').map(parseMonkey).toList();

  for (var i = 0; i < 10000; i ++) {
    runRound(troop);
  }

  final activity = troop.map((e) => e.inspections).toList();
  activity.sort((a, b) => -a.compareTo(b));
  final result = activity[0] * activity[1];

  print(result);
}

class Monkey {
  final Queue<Item> items = Queue<Item>();
  final String operator;
  final int operand, divisor, trueTarget, falseTarget;
  int inspections = 0;

  Monkey(Iterable<Item> items, this.operator, this.operand, this.divisor,
      this.trueTarget, this.falseTarget) {
    this.items.addAll(items);
  }
}

class Item {
  final int base;
  final List<Operation> ops = [];

  Item(this.base);

  bool divisible(int divisor) {
    var x = base % divisor;

    for (var op in ops) {
      var operand = op.operand == -1 ? x : op.operand;
      x = (op.operator == '*' ? x * operand : x + operand) % divisor;
    }

    return x == 0;
  }
}

class Operation {
  final String operator;
  final int operand;

  const Operation(this.operator, this.operand);
}

Monkey parseMonkey(String input) {
  final lines = input.split('\n');
  var parts = lines[1].split(':');
  var items = parts[1].split(',').map((e) => Item(int.parse(e.trim())));

  parts = lines[2].split(' ');
  final operator = parts[parts.length - 2];
  final operand = parts.last == 'old' ? -1 : int.parse(parts.last);
  final divisor = int.parse(lines[3].split(' ').last);
  final trueTarget = int.parse(lines[4].split(' ').last);
  final falseTarget = int.parse(lines[5].split(' ').last);

  return Monkey(items, operator, operand, divisor, trueTarget, falseTarget);
}

void runMonkey(List<Monkey> troop, Monkey monkey) {
  while (monkey.items.isNotEmpty) {
    monkey.inspections++;

    var item = monkey.items.removeFirst();
    var op = Operation(monkey.operator, monkey.operand);
    item.ops.add(op);


    var target = item.divisible(monkey.divisor) ? monkey.trueTarget : monkey.falseTarget;
    troop[target].items.addLast(item);
  }
}

void runRound(List<Monkey> troop) {
  for (var monkey in troop) {
    runMonkey(troop, monkey);
  }
}

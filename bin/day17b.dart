import 'dart:io';
import 'dart:math';

import 'package:aoc2022/data.dart';
import 'package:aoc2022/spatial.dart';
import 'package:aoc2022/utils.dart';

final shapes = [
  Shape([Coord(0, 0), Coord(1, 0), Coord(2, 0), Coord(3, 0)]),
  Shape([Coord(1, 0), Coord(0, 1), Coord(1, 1), Coord(2, 1), Coord(1, 2)]),
  Shape([Coord(2, 0), Coord(2, 1), Coord(2, 2), Coord(1, 0), Coord(0, 0)]),
  Shape([Coord(0, 0), Coord(0, 1), Coord(0, 2), Coord(0, 3)]),
  Shape([Coord(0, 0), Coord(1, 0), Coord(0, 1), Coord(1, 1)])
];

Future<void> main() async {
  final pattern = await loadDataString(17);

  var s = 0; // Shape index
  var p = 0; // Pattern index

  // Left wall = -1. Possible values are 0, 1, 2, 3, 4, 5, 6.
  // Floor = -1, so lowest possible y value = 0
  var maxY = -1;

  final occupied = <Coord>{};

  bool validate(Shape block) =>
      block.pixels.where((p) => p.x < 0 || p.x > 6 || p.y < 0 || occupied.contains(p)).isEmpty;

  final down = Coord(0, -1);
  final left = Coord(-1, 0);
  final right = Coord(1, 0);

  var profile = [0, 0, 0, 0, 0, 0, 0];
  var normProfile = [...profile];
  final lookupTable = <String, LookupInfo>{};
  var useLoopDetection = true;
  var extraHeight = 0;

  const target = 1000000000000;
  for (var i = 0; i < target; i++) {
    // So basically... we can cache the relative 'floor' profile + pattern index + block index. Or at least, we can
    // just save when we saw it last. If we can find a match, than that means we found a loop. We then know how many
    // blocks were in that loop, and also how much height we gained. We can then just artificially increase the counter
    // until almost reaching the target number of iterations and finish the simulation.
    if (useLoopDetection) {
      final lookupKey = '${normProfile.join(',')}/$s/$p';

      if (lookupTable.containsKey(lookupKey)) {
        // Loop detected!
        final loopInfo = lookupTable[lookupKey]!;
        final dIter = i - loopInfo.iteration;
        final dY = maxY - loopInfo.maxY;
        final skipLoops = (target - i) ~/ dIter;
        i += skipLoops * dIter;
        extraHeight = skipLoops * dY;
        useLoopDetection = false;
      } else {
        // Store loop info
        lookupTable[lookupKey] = LookupInfo(i, maxY);
      }
    }

    // Spawn new block
    final blockBtmY = maxY + 4;

    var block = shapes[s].translate(Coord(2, blockBtmY));
    s = (s + 1) % shapes.length;

    for (;;) {
      // Move block left or right
      final dir = pattern[p];
      p = (p + 1) % pattern.length;
      final moved = block.translate(dir == '>' ? right : left);
      if (validate(moved)) {
        block = moved;
      }

      // Move block down
      final oneDown = block.translate(down);
      if (validate(oneDown)) {
        block = oneDown;
      } else {
        // Stopped the block
        occupied.addAll(block.pixels);

        for (var px in block.pixels) {
          if (px.y > profile[px.x]) {
            profile[px.x] = px.y;
          }
        }

        final maxProfile = profile.max();
        normProfile = profile.map((v) => v - maxProfile).toList();

        maxY = max(maxY, block.pixels.map((p) => p.y).max());
        break;
      }
    }
  }

  print(maxY + extraHeight + 1);
}

class Shape {
  final List<Coord> pixels;

  Shape(this.pixels);

  Shape translate(Coord offset) => Shape(pixels.map((e) => e + offset).toList());
}

class LookupInfo {
  int iteration, maxY;

  LookupInfo(this.iteration, this.maxY);
}

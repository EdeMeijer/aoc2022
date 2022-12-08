import 'dart:io';

Future<String> loadDataString(int day) async {
  final current = Directory.current;
  final dataFile = File('${current.path}/data/day$day');
  return (await dataFile.readAsString()).trimRight();
}

Future<List<String>> loadDataLines(int day) async {
  return (await loadDataString(day)).split('\n');
}

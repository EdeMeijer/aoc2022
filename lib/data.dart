import 'dart:io';

Future<String> loadDataString(int day) async {
  final current = Directory.current;
  final dataFile = File('${current.path}/data/day$day');
  return (await dataFile.readAsString()).trim();
}

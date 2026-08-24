import 'dart:io';

void main(List<String> arguments) {
  if (arguments.length != 2) {
    stderr.writeln(
      'Usage: dart run tool/check_coverage.dart <lcov-file> <minimum-percent>',
    );
    exitCode = 64;
    return;
  }

  final coverageFile = File(arguments[0]);
  final minimum = double.tryParse(arguments[1]);
  if (!coverageFile.existsSync() || minimum == null) {
    stderr.writeln('Invalid coverage file or minimum percentage.');
    exitCode = 64;
    return;
  }

  var foundLines = 0;
  var hitLines = 0;
  for (final line in coverageFile.readAsLinesSync()) {
    if (line.startsWith('LF:')) {
      foundLines += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hitLines += int.parse(line.substring(3));
    }
  }

  if (foundLines == 0) {
    stderr.writeln('No coverable lines found in ${coverageFile.path}.');
    exitCode = 1;
    return;
  }

  final percentage = hitLines * 100 / foundLines;
  stdout.writeln(
    'Coverage: $hitLines/$foundLines '
    '(${percentage.toStringAsFixed(1)}%, minimum ${minimum.toStringAsFixed(1)}%)',
  );
  if (percentage < minimum) exitCode = 1;
}

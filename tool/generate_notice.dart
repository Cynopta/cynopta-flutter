// Writes NOTICE from pubspec.yaml and android/build.gradle.
//
//   dart run tool/generate_notice.dart          write NOTICE
//   dart run tool/generate_notice.dart --check  exit 1 if NOTICE is out of date
//
// Run it whenever the version or a dependency changes, for example in each
// release commit. test/notice_test.dart fails while NOTICE is out of date.

import 'dart:io';

import 'notice.dart';

void main(List<String> args) {
  final String expected;
  try {
    expected = buildNotice('.');
  } on NoticeException catch (e) {
    stderr.writeln(e);
    exit(1);
  }
  final File file = File('NOTICE');
  if (args.contains('--check')) {
    final bool current = file.existsSync() && file.readAsStringSync() == expected;
    stdout.writeln(current ? 'NOTICE is up to date.' : 'NOTICE is out of date. Run: dart run tool/generate_notice.dart');
    exit(current ? 0 : 1);
  }
  file.writeAsStringSync(expected);
  stdout.writeln('Wrote NOTICE.');
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/notice.dart';

void main() {
  test('NOTICE matches pubspec.yaml and android/build.gradle', () {
    expect(
      File('NOTICE').readAsStringSync(),
      buildNotice('.'),
      reason: 'NOTICE is out of date. Run: dart run tool/generate_notice.dart',
    );
  });
}

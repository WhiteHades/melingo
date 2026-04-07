import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/platform/window_size.dart';

void main() {
  test('resolve window size returns compact for phone', () {
    expect(resolveWindowSize(const Size(390, 844)), AppWindowSize.compact);
  });

  test('resolve window size returns medium for tablet', () {
    expect(resolveWindowSize(const Size(800, 1200)), AppWindowSize.medium);
  });

  test('resolve window size returns expanded for desktop', () {
    expect(resolveWindowSize(const Size(1280, 900)), AppWindowSize.expanded);
  });
}

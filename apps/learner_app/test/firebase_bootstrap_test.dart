import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/firebase/firebase_bootstrap.dart';

void main() {
  test('optionsForCurrentPlatform matches configured host support', () {
    final options = FirebaseBootstrap.optionsForCurrentPlatform();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        expect(options, isNotNull);
      case TargetPlatform.linux:
        expect(options, isNull);
      default:
        expect(options, isNull);
    }
  });
}

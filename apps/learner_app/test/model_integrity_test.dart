import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/model_manager/model_integrity.dart';

void main() {
  test('sha256Hex hashes deterministic model bytes', () async {
    final List<int> bytes = 'melangua-lite-model-v1'.codeUnits;

    final String hash = await ModelIntegrity.sha256Hex(bytes);

    expect(
      hash,
      'f5b352d2446e3d1c97b64b2cbce65d0dc0e3c024f9482954be846762a97f6477',
    );
  });
}

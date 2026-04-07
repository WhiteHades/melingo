import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/model_manager/model_artifact_repository.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  test('readOrDownload returns deterministic artifact and caches it', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final ModelArtifactRepository repository = ModelArtifactRepository(store: store);

    final List<int> first = await repository.readOrDownload('lite');
    final List<int> second = await repository.readOrDownload('lite');

    expect(String.fromCharCodes(first), 'melingo-lite-model-v1');
    expect(String.fromCharCodes(second), 'melingo-lite-model-v1');
  });
}

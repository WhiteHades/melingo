import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/model_manager/model_install_repository.dart';
import 'package:learner_app/src/models/model_install_state.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  test('upsert updates same bundle and keeps one row', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final ModelInstallRepository repository = ModelInstallRepository(store: store);

    await repository.upsert(
      const ModelInstallState(bundleId: 'lite', status: 'downloading', progress: 0.2),
    );
    await repository.upsert(
      const ModelInstallState(bundleId: 'lite', status: 'ready', progress: 1),
    );

    final rows = await repository.readAll();
    expect(rows.length, 1);
    expect(rows.first.status, 'ready');
    expect(rows.first.progress, 1);
  });
}

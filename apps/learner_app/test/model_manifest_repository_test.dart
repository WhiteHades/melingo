import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learner_app/src/model_manager/model_manifest_repository.dart';
import 'package:learner_app/src/network/model_manifest_client.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  test('fetchAndCache stores normalized manifest in local store', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final MockClient mockClient = MockClient((http.Request request) async {
      return http.Response('{"version":"2026.04.01","bundles":["lite"]}', 200);
    });

    final ModelManifestRepository repository = ModelManifestRepository(
      client: ModelManifestClient(client: mockClient),
      store: store,
    );

    final manifest = await repository.fetchAndCache();
    final cached = await repository.readCached();

    expect(manifest.bundles.first.id, 'lite');
    expect(cached, isNotNull);
    expect(cached!.bundles.first.sizeMb, 1400);
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learner_app/src/models/model_manifest.dart';
import 'package:learner_app/src/network/model_manifest_client.dart';

void main() {
  test('fetch manifest parses version and bundles', () async {
    final MockClient mockClient = MockClient((http.Request request) async {
      expect(request.url.scheme, 'https');
      expect(request.url.host, 'api.melingo.app');
      expect(request.url.path, '/v1/models/manifest');

      return http.Response(
        jsonEncode(<String, dynamic>{
          'version': '2026.04.01',
          'bundles': <String>['lite', 'balanced', 'quality'],
        }),
        200,
      );
    });

    final ModelManifestClient client = ModelManifestClient(client: mockClient);
    final ModelManifest manifest = await client.fetchManifest();

    expect(manifest.version, '2026.04.01');
    expect(manifest.bundles.length, 3);
    expect(manifest.bundles.first.id, 'lite');
    expect(manifest.bundles.first.offlineCapable, true);
    expect(
      manifest.bundles.first.artifactSha256,
      '9e3fdf35883bcc2410a05188960b71240696d9c5424cdd79f93d904d8aec3272',
    );
  });

  test('fetch manifest throws on non-200 status', () async {
    final MockClient mockClient = MockClient((http.Request request) async {
      return http.Response('error', 500);
    });
    final ModelManifestClient client = ModelManifestClient(client: mockClient);

    expect(client.fetchManifest(), throwsException);
  });
}

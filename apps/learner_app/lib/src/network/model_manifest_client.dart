import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/model_manifest.dart' as manifest_model;

class ModelManifestClient {
  ModelManifestClient({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<manifest_model.ModelManifest> fetchManifest() async {
    final Uri uri = Uri.https('api.melingo.app', '/v1/models/manifest');
    final http.Response response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('failed to load model manifest');
    }

    final Map<String, dynamic> map =
        jsonDecode(response.body) as Map<String, dynamic>;
    return manifest_model.ModelManifest.fromMap(_normalizeManifest(map));
  }

  Map<String, dynamic> _normalizeManifest(Map<String, dynamic> map) {
    final List<dynamic> ids = map['bundles'] as List<dynamic>? ?? <dynamic>[];
    final List<Map<String, dynamic>> normalized = ids
        .map(
          (dynamic id) => _defaultsForBundle(id.toString()),
        )
        .toList(growable: false);
    return <String, dynamic>{
      'version': map['version'] as String? ?? 'unknown',
      'bundles': normalized,
    };
  }

  Map<String, dynamic> _defaultsForBundle(String id) {
    if (id == 'lite') {
      return const <String, dynamic>{
        'id': 'lite',
        'sizeMb': 1400,
        'minRamMb': 3000,
        'languages': <String>['de', 'ar'],
        'offlineCapable': true,
        'artifactSha256':
            '9e3fdf35883bcc2410a05188960b71240696d9c5424cdd79f93d904d8aec3272',
      };
    }
    if (id == 'quality') {
      return const <String, dynamic>{
        'id': 'quality',
        'sizeMb': 6200,
        'minRamMb': 10000,
        'languages': <String>['de', 'ar'],
        'offlineCapable': true,
        'artifactSha256':
            '6e1e12eb6127db8a08191aee77c622527d97f22279b62db185095130ac7560c6',
      };
    }
    return const <String, dynamic>{
      'id': 'balanced',
      'sizeMb': 3400,
      'minRamMb': 6000,
      'languages': <String>['de', 'ar'],
      'offlineCapable': true,
      'artifactSha256':
          '64c54e9c1222a38e902558aaca2c4da085d39f3b5cbb099a3d31367a614f26d4',
    };
  }
}

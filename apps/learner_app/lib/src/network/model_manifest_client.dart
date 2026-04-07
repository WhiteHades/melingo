import 'dart:convert';

import 'package:http/http.dart' as http;

class ModelManifestClient {
  ModelManifestClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ModelManifest> fetchManifest() async {
    final Uri uri = Uri.https('api.melingo.app', '/v1/models/manifest');
    final http.Response response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('failed to load model manifest');
    }

    final Map<String, dynamic> map =
        jsonDecode(response.body) as Map<String, dynamic>;
    return ModelManifest.fromJson(map);
  }
}

class ModelManifest {
  const ModelManifest({required this.version, required this.bundles});

  final String version;
  final List<String> bundles;

  factory ModelManifest.fromJson(Map<String, dynamic> json) {
    return ModelManifest(
      version: json['version'] as String,
      bundles: (json['bundles'] as List<dynamic>)
          .map((dynamic item) => item as String)
          .toList(growable: false),
    );
  }
}

import 'model_bundle.dart';

class ModelManifest {
  const ModelManifest({
    required this.version,
    required this.bundles,
  });

  final String version;
  final List<ModelBundle> bundles;

  static ModelManifest fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawBundles =
        map['bundles'] as List<dynamic>? ?? <dynamic>[];
    return ModelManifest(
      version: map['version'] as String? ?? 'unknown',
      bundles: rawBundles
          .map((dynamic e) => ModelBundle.fromMap(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

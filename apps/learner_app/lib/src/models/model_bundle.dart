class ModelBundle {
  const ModelBundle({
    required this.id,
    required this.sizeMb,
    required this.minRamMb,
    required this.languages,
    required this.offlineCapable,
    required this.artifactSha256,
  });

  final String id;
  final int sizeMb;
  final int minRamMb;
  final List<String> languages;
  final bool offlineCapable;
  final String artifactSha256;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sizeMb': sizeMb,
      'minRamMb': minRamMb,
      'languages': languages,
      'offlineCapable': offlineCapable,
      'artifactSha256': artifactSha256,
    };
  }

  static ModelBundle fromMap(Map<String, dynamic> map) {
    return ModelBundle(
      id: map['id'] as String,
      sizeMb: map['sizeMb'] as int,
      minRamMb: map['minRamMb'] as int,
      languages:
          (map['languages'] as List<dynamic>).map((dynamic e) => e as String).toList(growable: false),
      offlineCapable: map['offlineCapable'] as bool,
      artifactSha256: map['artifactSha256'] as String,
    );
  }
}

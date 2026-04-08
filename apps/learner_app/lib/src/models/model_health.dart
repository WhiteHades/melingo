class ModelHealth {
  const ModelHealth({
    required this.ready,
    required this.installedBundles,
    required this.lastCheckedIso,
  });

  final bool ready;
  final List<String> installedBundles;
  final String lastCheckedIso;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ready': ready,
      'installedBundles': installedBundles,
      'lastCheckedIso': lastCheckedIso,
    };
  }

  static ModelHealth fromMap(Map<String, dynamic> map) {
    return ModelHealth(
      ready: map['ready'] as bool? ?? false,
      installedBundles:
          (map['installedBundles'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic e) => e as String)
              .toList(growable: false),
      lastCheckedIso: map['lastCheckedIso'] as String? ?? '',
    );
  }
}

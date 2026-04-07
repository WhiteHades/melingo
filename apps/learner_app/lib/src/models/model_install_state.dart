class ModelInstallState {
  const ModelInstallState({
    required this.bundleId,
    required this.status,
    required this.progress,
  });

  final String bundleId;
  final String status;
  final double progress;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bundleId': bundleId,
      'status': status,
      'progress': progress,
    };
  }

  static ModelInstallState fromMap(Map<String, dynamic> map) {
    return ModelInstallState(
      bundleId: map['bundleId'] as String,
      status: map['status'] as String,
      progress: (map['progress'] as num).toDouble(),
    );
  }
}

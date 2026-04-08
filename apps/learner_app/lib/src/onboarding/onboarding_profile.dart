class OnboardingProfile {
  const OnboardingProfile({
    required this.displayName,
    required this.languageCode,
    required this.level,
    required this.weeklyGoalMinutes,
    this.updatedAtIso = '',
  });

  final String displayName;
  final String languageCode;
  final String level;
  final int weeklyGoalMinutes;
  final String updatedAtIso;

  OnboardingProfile copyWith({
    String? displayName,
    String? languageCode,
    String? level,
    int? weeklyGoalMinutes,
    String? updatedAtIso,
  }) {
    return OnboardingProfile(
      displayName: displayName ?? this.displayName,
      languageCode: languageCode ?? this.languageCode,
      level: level ?? this.level,
      weeklyGoalMinutes: weeklyGoalMinutes ?? this.weeklyGoalMinutes,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayName': displayName,
      'languageCode': languageCode,
      'level': level,
      'weeklyGoalMinutes': weeklyGoalMinutes,
      'updatedAtIso': updatedAtIso,
    };
  }

  static OnboardingProfile fromMap(Map<String, dynamic> map) {
    return OnboardingProfile(
      displayName: map['displayName'] as String? ?? '',
      languageCode: map['languageCode'] as String? ?? 'de',
      level: map['level'] as String? ?? 'a1',
      weeklyGoalMinutes: map['weeklyGoalMinutes'] as int? ?? 60,
      updatedAtIso: map['updatedAtIso'] as String? ?? '',
    );
  }
}

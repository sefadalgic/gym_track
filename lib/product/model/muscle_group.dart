/// Enum representing different muscle groups targeted by exercises
enum MuscleGroup {
  abdominals('Abdominals'),
  abductors('Abductors'),
  adductors('Adductors'),
  chest('Chest'),
  back('Back'),
  legs('Legs'),
  shoulders('Shoulders'),
  biceps('Biceps'),
  triceps('Triceps'),
  forearms('Forearms'),
  glutes('Glutes'),
  hamstrings('Hamstrings'),
  quadriceps('Quadriceps'),
  calves('Calves'),
  lats('Lats'),
  traps('Traps'),
  lowerBack('Lower Back'),
  middleBack('Middle Back'),
  neck('Neck'),
  cardio('Cardio'),
  fullBody('Full Body');

  final String displayName;

  const MuscleGroup(this.displayName);

  /// Convert from JSON string to enum
  static MuscleGroup fromJson(String value) {
    return MuscleGroup.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => MuscleGroup.fullBody,
    );
  }

  /// Convert enum to JSON string
  String toJson() => name;
}

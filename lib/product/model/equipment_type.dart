/// Enum representing different types of equipment used in exercises
enum EquipmentType {
  barbell('Barbell'),
  dumbbell('Dumbbell'),
  machine('Machine'),
  bodyweight('Bodyweight'),
  cable('Cable'),
  kettlebell('Kettlebell'),
  bands('Resistance Bands'),
  ezBar('EZ Bar'),
  trapBar('Trap Bar'),
  medicineBall('Medicine Ball'),
  foamRoll('Foam Roll'),
  other('Other'),
  none('None');

  final String displayName;

  const EquipmentType(this.displayName);

  /// Convert from JSON string to enum
  static EquipmentType fromJson(String value) {
    return EquipmentType.values.firstWhere(
      (e) =>
          e.name.toLowerCase() ==
          value
              .toLowerCase()
              .replaceAll('-', '')
              .replaceAll('_', '')
              .replaceAll(' ', ''),
      orElse: () => EquipmentType.other,
    );
  }

  /// Convert enum to JSON string
  String toJson() => name;
}

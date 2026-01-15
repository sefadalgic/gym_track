/// Enum representing the type of force applied during an exercise
enum ForceType {
  push('Push'),
  pull('Pull'),
  staticType('Static'),
  dynamic('Dynamic');

  final String displayName;

  const ForceType(this.displayName);

  /// Convert from JSON string to enum
  static ForceType fromJson(String value) {
    // Handle 'static' keyword conflict
    if (value.toLowerCase() == 'static') {
      return ForceType.staticType;
    }
    return ForceType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ForceType.dynamic,
    );
  }

  /// Convert enum to JSON string
  String toJson() => name == 'staticType' ? 'static' : name;
}

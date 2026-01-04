/// Base model for all data models in the application.
///
/// Each model extending this class must implement:
/// - [toJson]: Convert model to JSON map
/// - Static factory method `fromJson` for deserialization
///
/// Example:
/// ```dart
/// class User extends BaseModel {
///   final String name;
///
///   User({required this.name});
///
///   static User fromJson(Map<String, dynamic> json) => User(name: json['name']);
///
///   @override
///   Map<String, dynamic> toJson() => {'name': name};
/// }
/// ```
abstract class BaseModel {
  /// Convert model to JSON map
  Map<String, dynamic> toJson();
}

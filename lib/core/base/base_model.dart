/// Base model for all data models in the application.
///
/// Each model extending this class must implement:
/// - [toJson]: Convert model to JSON map
/// ```
abstract class BaseModel {
  /// Convert model to JSON map
  Map<String, dynamic> toJson();
}

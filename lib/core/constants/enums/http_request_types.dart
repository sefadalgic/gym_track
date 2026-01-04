/// HTTP request method types
enum HttpRequestTypes {
  get,
  post,
  put,
  delete,
  patch,
}

/// Extension for HttpRequestTypes enum
extension HttpRequestTypesExtension on HttpRequestTypes {
  /// Convert enum to string value for Dio
  String get value {
    switch (this) {
      case HttpRequestTypes.get:
        return 'GET';
      case HttpRequestTypes.post:
        return 'POST';
      case HttpRequestTypes.put:
        return 'PUT';
      case HttpRequestTypes.delete:
        return 'DELETE';
      case HttpRequestTypes.patch:
        return 'PATCH';
    }
  }
}

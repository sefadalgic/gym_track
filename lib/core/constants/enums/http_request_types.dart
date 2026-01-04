/// HTTP request method types
enum HttpRequestTypes {
  GET,
  POST,
  PUT,
  DELETE,
  PATCH,
}

/// Extension for HttpRequestTypes enum
extension HttpRequestTypesExtension on HttpRequestTypes {
  /// Convert enum to string value for Dio
  String get value {
    switch (this) {
      case HttpRequestTypes.GET:
        return 'GET';
      case HttpRequestTypes.POST:
        return 'POST';
      case HttpRequestTypes.PUT:
        return 'PUT';
      case HttpRequestTypes.DELETE:
        return 'DELETE';
      case HttpRequestTypes.PATCH:
        return 'PATCH';
    }
  }
}

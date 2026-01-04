/// Interface for response models
abstract class IResponseModel<T> {
  T? get data;
  ErrorModel? get error;
  int? get statusCode;
}

/// Interface for error models
abstract class IErrorModel {
  String get message;
  int? get statusCode;
  String? get errorCode;
}

/// Standard response wrapper for all network requests
///
/// Contains either [data] on success or [error] on failure
class ResponseModel<T> implements IResponseModel<T> {
  @override
  final T? data;

  @override
  final ErrorModel? error;

  @override
  final int? statusCode;

  ResponseModel({
    this.data,
    this.error,
    this.statusCode,
  });

  /// Check if the response was successful
  bool get isSuccess => error == null && data != null;

  /// Check if the response has an error
  bool get hasError => error != null;

  /// Create a success response
  factory ResponseModel.success(T data, {int? statusCode}) {
    return ResponseModel(
      data: data,
      statusCode: statusCode,
    );
  }

  /// Create an error response
  factory ResponseModel.error(ErrorModel error, {int? statusCode}) {
    return ResponseModel(
      error: error,
      statusCode: statusCode,
    );
  }
}

/// Error model for network and application errors
class ErrorModel implements IErrorModel {
  @override
  final String message;

  @override
  final int? statusCode;

  @override
  final String? errorCode;

  /// Optional detailed error description
  final String? details;

  ErrorModel({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
  });

  /// Create error from exception
  factory ErrorModel.fromException(Exception exception, {int? statusCode}) {
    return ErrorModel(
      message: exception.toString(),
      statusCode: statusCode,
    );
  }

  /// Create error from Dio error
  factory ErrorModel.fromDioError(dynamic dioError) {
    return ErrorModel(
      message: dioError.message ?? 'Unknown error occurred',
      statusCode: dioError.response?.statusCode,
      errorCode: dioError.type.toString(),
      details: dioError.response?.data?.toString(),
    );
  }

  @override
  String toString() =>
      'ErrorModel(message: $message, statusCode: $statusCode, errorCode: $errorCode)';
}

import 'package:gym_track/core/constants/enums/http_request_types.dart';
import 'package:gym_track/core/network/response_model.dart';

/// Network service interface for making HTTP requests
///
/// This interface defines the contract for network operations.
/// Implementations should handle:
/// - HTTP requests (GET, POST, PUT, DELETE, PATCH)
/// - Response parsing
/// - Error handling
/// - Progress tracking
abstract class INetworkService {
  /// Make an HTTP request
  ///
  /// [T] is the expected response data type
  ///
  /// Parameters:
  /// - [path]: API endpoint path (will be appended to base URL)
  /// - [method]: HTTP method (GET, POST, PUT, DELETE, PATCH)
  /// - [parser]: Optional function to parse response data to type [T]
  ///   If null, response data will be returned as-is
  /// - [data]: Request body data (for POST, PUT, PATCH)
  /// - [queryParameters]: URL query parameters
  /// - [onReceiveProgress]: Callback for download progress
  /// - [onSendProgress]: Callback for upload progress
  ///
  /// Returns [ResponseModel<T>] containing either data or error
  ///
  /// Example:
  /// ```dart
  /// final response = await networkService.request<User>(
  ///   path: '/users/1',
  ///   method: HttpRequestTypes.GET,
  ///   parser: (json) => User.fromJson(json),
  /// );
  ///
  /// if (response.isSuccess) {
  ///   print(response.data?.name);
  /// } else {
  ///   print(response.error?.message);
  /// }
  /// ```
  Future<ResponseModel<T>> request<T>({
    required String path,
    required HttpRequestTypes method,
    T Function(Map<String, dynamic> json)? parser,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onReceiveProgress,
    void Function(int sent, int total)? onSendProgress,
  });

  /// Make a GET request
  Future<ResponseModel<T>> get<T>({
    required String path,
    T Function(Map<String, dynamic> json)? parser,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onReceiveProgress,
  });

  /// Make a POST request
  Future<ResponseModel<T>> post<T>({
    required String path,
    T Function(Map<String, dynamic> json)? parser,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    void Function(int sent, int total)? onSendProgress,
  });

  /// Make a PUT request
  Future<ResponseModel<T>> put<T>({
    required String path,
    T Function(Map<String, dynamic> json)? parser,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  /// Make a DELETE request
  Future<ResponseModel<T>> delete<T>({
    required String path,
    T Function(Map<String, dynamic> json)? parser,
    Map<String, dynamic>? queryParameters,
  });
}

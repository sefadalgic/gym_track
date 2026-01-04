import 'package:dio/dio.dart';
import 'package:gym_track/core/constants/enums/http_request_types.dart';
import 'package:gym_track/core/network/i_network_service.dart';
import 'package:gym_track/core/network/response_model.dart';

/// Concrete implementation of [INetworkService] using Dio
class NetworkService implements INetworkService {
  final Dio _dio;

  NetworkService(this._dio);

  @override
  Future<ResponseModel<T>> request<T>({
    required String path,
    required HttpRequestTypes method,
    T Function(Map<String, dynamic> json)? parser,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onReceiveProgress,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method.value),
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      );

      // Parse response data if parser is provided
      T? parsedData;
      if (parser != null && response.data != null) {
        try {
          parsedData = parser(response.data as Map<String, dynamic>);
        } catch (e) {
          return ResponseModel.error(
            ErrorModel(
              message: 'Failed to parse response data',
              statusCode: response.statusCode,
              details: e.toString(),
            ),
            statusCode: response.statusCode,
          );
        }
      } else {
        // If no parser, return data as-is (cast to T)
        parsedData = response.data as T?;
      }

      return ResponseModel.success(
        parsedData as T,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ResponseModel.error(
        ErrorModel.fromDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ResponseModel.error(
        ErrorModel(
          message: 'Unexpected error occurred',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<ResponseModel<T>> get<T>({
    required String path,
    T Function(Map<String, dynamic> json)? parser,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onReceiveProgress,
  }) {
    return request<T>(
      path: path,
      method: HttpRequestTypes.get,
      parser: parser,
      queryParameters: queryParameters,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<ResponseModel<T>> post<T>({
    required String path,
    T Function(Map<String, dynamic> json)? parser,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    void Function(int sent, int total)? onSendProgress,
  }) {
    return request<T>(
      path: path,
      method: HttpRequestTypes.post,
      parser: parser,
      data: data,
      queryParameters: queryParameters,
      onSendProgress: onSendProgress,
    );
  }

  @override
  Future<ResponseModel<T>> put<T>({
    required String path,
    T Function(Map<String, dynamic> json)? parser,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return request<T>(
      path: path,
      method: HttpRequestTypes.put,
      parser: parser,
      data: data,
      queryParameters: queryParameters,
    );
  }

  @override
  Future<ResponseModel<T>> delete<T>({
    required String path,
    T Function(Map<String, dynamic> json)? parser,
    Map<String, dynamic>? queryParameters,
  }) {
    return request<T>(
      path: path,
      method: HttpRequestTypes.delete,
      parser: parser,
      queryParameters: queryParameters,
    );
  }
}

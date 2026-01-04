import 'package:dio/dio.dart';
import 'package:gym_track/core/network/i_network_service.dart';
import 'package:gym_track/core/network/network_service.dart';

/// Singleton network manager for the application
///
/// Provides configured Dio instance and NetworkService
///
/// Usage:
/// ```dart
/// final response = await NetworkManager.instance.networkService.get<User>(
///   path: '/users/1',
///   parser: User.fromJson,
/// );
/// ```
class NetworkManager {
  // Singleton instance
  static NetworkManager? _instance;

  // Dio instance
  late final Dio _dio;

  // Network service
  late final INetworkService networkService;

  // Private constructor
  NetworkManager._init({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    // Configure Dio
    final baseOptions = BaseOptions(
      baseUrl: baseUrl ??
          'https://api.example.com/', // TODO: Update with your API base URL
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(baseOptions);

    // Add interceptors
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) {
          // TODO: Replace with proper logging solution
          print(obj);
        },
      ),
    );

    // You can add more interceptors here
    // Example: Authentication interceptor
    // _dio.interceptors.add(AuthInterceptor());

    // Initialize network service
    networkService = NetworkService(_dio);
  }

  /// Get singleton instance
  static NetworkManager get instance {
    _instance ??= NetworkManager._init();
    return _instance!;
  }

  /// Initialize with custom configuration
  ///
  /// Call this method once at app startup if you need custom configuration
  static void initialize({
    required String baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    _instance = NetworkManager._init(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
  }

  /// Get Dio instance for advanced usage
  Dio get dio => _dio;
}

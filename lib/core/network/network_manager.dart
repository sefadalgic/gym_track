import 'package:dio/dio.dart';
import 'package:gym_track/core/network/ICoreDio.dart';
import 'package:gym_track/core/network/core_dio.dart' hide ICoreDioNullSafety;

class NetworkManager {
  NetworkManager._init() {
    final baseOptions = BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com/',
    );
    // _dio = Dio(baseOptions);

    // coreDio = CoreDio(baseOptions);

    // _dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (options) {1
    //     options.path += "veli";
    //   },
    //   onError: (e) {
    //     return BaseError(e.message);
    //   },
    // ));
  }
  static NetworkManager? _instance;
  static NetworkManager? get instance {
    _instance ??= NetworkManager._init();
    return _instance;
  }

  ICoreDioNullSafety? coreDio;
}

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  final String baseUrl = dotenv.get('BASE_URL');
  DioClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options); // Continue the request
      },
      onError: (error, handler) {
        // Handle global errors like token expiration
        if (error.response?.statusCode == 401) {
          // Add logout logic or token refresh
        }
        return handler.next(error); // Continue error
      },
    ));
  }

  Dio get client => _dio;
}

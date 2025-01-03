import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  final String baseUrl = dotenv.get('BASE_URL');

  DioClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30); // Increased for file uploads
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwtToken');
        print("Retrieved token: $token"); 
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add default headers for multipart requests
        if (options.data is FormData) {
          options.headers['Content-Type'] = 'multipart/form-data';
        }
        
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized access
          await _storage.delete(key: 'jwtToken');
          // Add navigation to login or token refresh logic
        }
        return handler.next(error);
      },
      onResponse: (response, handler) {
        // You can add global response handling here
        return handler.next(response);
      },
    ));
  }

  Dio get client => _dio;
}
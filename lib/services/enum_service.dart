import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled2/utils/dio_client.dart';

class EnumService {
  final Dio _dio = DioClient().client;
  final _storage = const FlutterSecureStorage();

  Future<List<String>> getConditions() async {
    try {
      final response = await _dio.get('/enums/conditions');

      if (response.statusCode == 200) {
        List<String> conditions = List<String>.from(response.data.map((condition) => condition.toString()));
        return conditions;
      } else {
        throw Exception("Failed to load conditions");
      }
    } catch (e) {
      print("Error fetching conditions: $e");
      throw e;
    }
  }

  Future<List<String>> getStatuses() async {
    try {
      final response = await _dio.get('/enums/statuses');

      if (response.statusCode == 200) {
        List<String> statuses = List<String>.from(response.data.map((status) => status.toString()));
        return statuses;
      } else {
        throw Exception("Failed to load statuses");
      }
    } catch (e) {
      print("Error fetching statuses: $e");
      throw e;
    }
  }
}
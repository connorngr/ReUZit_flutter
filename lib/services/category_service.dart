import 'package:dio/dio.dart';
import 'package:untitled2/utils/dio_client.dart';
import 'package:untitled2/models/category.dart';

class CategoryService {
  final Dio _dio = DioClient().client;

  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        return (response.data as List).map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Error fetching categories');
    }
  }

  // Add this new method
  Future<Category> getCategoryByName(String name) async {
    try {
      final response = await _dio.get('/categories/name/$name');
      
      print('Category response: ${response.data}'); // Debug log
      
      if (response.statusCode == 200) {
        return Category.fromJson(response.data);
      } else {
        throw Exception('Category not found');
      }
    } catch (e) {
      print('Error fetching category by name: $e');
      throw Exception('Error fetching category');
    }
  }
}
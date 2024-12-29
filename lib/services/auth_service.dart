import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled2/models/user.dart';
import 'package:untitled2/utils/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().client;
  final _storage = const FlutterSecureStorage();

  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/authenticate', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        final token = response.data['token'];
        print("\n Retrieved token: $token"); 
      if (token != null) {
        // Save token for future use
        await _storage.write(key: 'jwtToken', value: token);

        // Fetch and store user data
        // await getCurrentUser();

        return token;
      }
      }
      // Handle unexpected response
      print("Unexpected response: ${response.data}");
      return null;
    } catch (e) {
      // Log and return null on error
      print("Login error: $e");
      return null;
    }
  }
  Future<User?> getUserFromStorage() async {
    try {
      final userDataString = await _storage.read(key: 'userData');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print("Error retrieving user from storage: $e");
      return null;
    }
  }
  Future<String?> register(Map<String, dynamic> userData, File? imageFile) async {
    try {
      // Convert user data to JSON string
      final userJson = jsonEncode(userData);

      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'user': userJson,
        if (imageFile != null) // Include file if provided
          'imageUrl': await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last),
      });

      // Send POST request
      final response = await _dio.post(
        '/auth/register',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      final token = response.data['token'];
      if (token != null) {
        // Save JWT token to secure storage
        await _storage.write(key: 'jwt_token', value: token);
        return token;
      } else {
        throw Exception("Failed to register");
      }
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }
  Future<User?> getCurrentUser() async {
    try {
      print('Attempting to fetch current user...');
      Response response = await _dio.get('/users/current');
      print('Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('User data: $data');
        final user = User.fromJson(data);

        // Store user data in secure storage
        await _storage.write(key: 'userData', value: jsonEncode(data));

        return user;
      } else {
        throw Exception("Failed to fetch user info");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Dio error response: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch user info');
      } else {
        print('Dio error message: ${e.message}');
        throw Exception(e.message);
      }
    }
  }
  Future<void> logout() async {
    try {
      // Remove the JWT token from secure storage
      await _storage.delete(key: 'jwt_token');
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
import 'package:dio/dio.dart';
import 'package:untitled2/models/user.dart';
import 'package:untitled2/utils/dio_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final Dio _dio = DioClient().client;
  
  
  Future<void> updateUserData(User user) async {
    try {
      final response = await _dio.put(
        '/users/update',
        data: user.toJson(),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  Future<User> updateUserImage(dynamic image) async {
    try {
      FormData formData;
      if (!kIsWeb && image is String) {
        // Mobile platform
        formData = await User.toForm(image);
      } else if (kIsWeb && image is XFile) {
        // Web platform
        final bytes = await image.readAsBytes();
        formData = FormData.fromMap({
          'image': MultipartFile.fromBytes(
            bytes,
            filename: image.name,
            contentType: MediaType("image", "jpeg"),
          ),
        });
      } else {
        throw Exception('Unsupported image type');
      }

      final response = await _dio.put(
        '/users/image',
        data: formData,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to update user image');
      }
    } catch (e) {
      throw Exception('Error updating user image: $e');
    }
  }
}
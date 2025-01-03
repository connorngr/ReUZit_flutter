import 'package:dio/dio.dart';
import 'package:untitled2/models/Image.dart';
import 'package:untitled2/utils/dio_client.dart';

class ImageService {
  final Dio _dio = DioClient().client;

  // Get all images by listing ID
  Future<List<ImageModel>> getAllImagesByListingId(int listingId) async {
    try {
      final response = await _dio.get('/images/list/$listingId');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => ImageModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      throw Exception('Error fetching images');
    }
  }

  // Add multiple images
  Future<List<ImageModel>> addImages(int listingId, List<dynamic> images) async {
    try {
      final formData = await ImageModel.toForm(
        listingId: listingId,
        images: images,
      );

      final response = await _dio.post(
        '/images/add',
        data: formData,
      options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 500, // Accept 2xx and 4xx responses
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        try {
          final List<ImageModel> uploadedImages = (response.data as List)
              .map((json) => ImageModel.fromJson(json))
              .toList();
          return uploadedImages;
        } catch (parseError) {
          throw Exception('Error parsing server response');
        }
      } else {
        throw Exception(
          'Upload failed with status ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      print('Error in addImages: $e');
      throw Exception('Failed to upload images: ${e.toString()}');
    }
  }

  Future<void> deleteImages(List<int> imageIds) async {
    try {
      final response = await _dio.delete(
        '/images/delete',
        data: imageIds, // Send as raw array, not as an object
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete images: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error deleting images: $e');
    }
  }
}

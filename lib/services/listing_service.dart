import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/utils/dio_client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ListingService {
  final Dio _dio = DioClient().client;
  final _storage = const FlutterSecureStorage();
  final String baseUrl = dotenv.get('BASE_URL');

  Future<List<Listing>> fetchListings() async {
    try {
      final response = await _dio.get('/listings/active/not-useremail');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((listing) => Listing.fromJson(listing)).toList();
      } else {
        throw Exception('Failed to load listings');
      }
    } catch (error) {
      throw Exception('Error fetching listings: $error');
    }
  }

  Future<List<Listing>> fetchListingsOfMe() async {
    try {
      final response = await _dio.get('/listings/me');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((listing) => Listing.fromJson(listing)).toList();
      } else {
        throw Exception('Failed to load listings');
      }
    } catch (error) {
      throw Exception('Error fetching listings: $error');
    }
  }

Future<void> addListing(Listing listing) async {
    try {
      // Validate images before proceeding
      if (!_validateImages(listing.images)) {
        throw Exception('Please select at least one image');
      }

      final formData = await listing.toForm();
      
      final response = await _dio.post(
        '/listings',
        data: formData,
        options: Options(
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 201) {
        return;
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to add listing';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      String errorMessage;
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please check your internet connection.';
          break;
          
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 413) {
            errorMessage = 'File size too large. Please reduce image size.';
          } else {
            errorMessage = e.response?.data?['message'] ?? 'Server error occurred';
          }
          break;
          
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
          
        default:
          errorMessage = 'Something went wrong. Please try again.';
      }
      
      throw Exception(errorMessage);
    } catch (error) {
      throw Exception('Error adding listing: $error');
    }
  }

  bool _validateImages(List<dynamic> images) {
    if (images.isEmpty) {
      return false;
    }
    
    // Add additional image validation if needed
    // For example, check file size, format, etc.
    return true;
  }

  Future<void> updateListing(int id, Listing listing) async {
    try {
      final formData = await listing.toForm();

      print('Form data fields:');
      final response = await _dio.put(
        '/listings/$id',
        data: formData,
        options: Options(
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to add listing';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      String errorMessage;
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timeout. Please check your internet connection.';
          break;
          
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 413) {
            errorMessage = 'File size too large. Please reduce image size.';
          } else {
            errorMessage = e.response?.data?['message'] ?? 'Server error occurred';
          }
          break;
          
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
          
        default:
          errorMessage = 'Something went wrong. Please try again.';
      }
      
      throw Exception(errorMessage);
    } catch (error) {
      throw Exception('Error adding listing: $error');
    }
  }

Future<void> deleteListings(List<int> ids) async {
    try {
      // Convert the list of IDs to a comma-separated string
      final String idsString = ids.join(',');

      final response = await _dio.delete(
        '/listings',
        queryParameters: {'ids': idsString},
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept any status code less than 500
          },
        ),
      );

      if (response.statusCode == 204) {
        // No content, all listings deleted successfully
        print('All listings deleted successfully');
      } else if (response.statusCode == 206) {
        // Partial content, some listings failed to delete
        print('Some listings failed to delete: ${response.data}');
      } else {
        throw Exception('Failed to delete listings');
      }
    } catch (error) {
      throw Exception('Error deleting listings: $error');
    }
  }
}

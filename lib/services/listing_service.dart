import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/utils/dio_client.dart';

class ListingService {
  final Dio _dio = DioClient().client;
  final _storage = const FlutterSecureStorage();

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
      final jwtToken = await _storage.read(key: 'jwtToken');
      final response = await _dio.post(
        '/listings',
        data: listing.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add listing');
      }
    } catch (error) {
      throw Exception('Error adding listing: $error');
    }
  }

  Future<void> updateListing(int id, FormData listing) async {
    try {
      final jwtToken = await _storage.read(key: 'jwtToken'); // Read the token
      final response = await _dio.put(
        '/listings/$id',
        data: listing,
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update listing');
      }
    } catch (error) {
      throw Exception('Error updating listing: $error');
    }
  }

  Future<void> deleteListing(int id) async {
    try {
      final jwtToken = await _storage.read(key: 'jwtToken'); // Read the token
      final response = await _dio.delete(
        '/listings/$id',
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete listing');
      }
    } catch (error) {
      throw Exception('Error deleting listing: $error');
    }
  }
}

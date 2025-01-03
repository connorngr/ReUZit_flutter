import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class Listing {
  final int? id;
  final String title;
  final String description;
  final int price;
  final String category;
  final String condition;
  final String status;
  final List<dynamic> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.status,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      price: json['price'],
      category: json['category']['name'],
      condition: json['condition'],
      status: json['status'],
      images: List<String>.from(json['images'].map((image) => image['url'])),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'condition': condition,
      'images': images,
    };
  }

  Future<FormData> toForm() async {
    final formData = FormData();

    // Add basic fields
    formData.fields.addAll([
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('price', price.toString()),
      MapEntry('categoryId', category), // Change 'category' to 'categoryId'
      MapEntry('condition', condition),
    ]);

    // Handle image uploads
    if (images.isNotEmpty) {
      if (!kIsWeb) {
        // Mobile platform
        for (var imagePath in images) {
          if (imagePath is String) {
            final file = io.File(imagePath);
            if (await file.exists()) {
              formData.files.add(MapEntry(
                'images',
                await MultipartFile.fromFile(
                  imagePath,
                  filename: imagePath.split('/').last,
                  contentType: MediaType("image", "jpeg"),
                ),
              ));
            }
          }
        }
      } else {
        // Web platform
        for (var image in images) {
          if (image is XFile) {
            final bytes = await image.readAsBytes();
            formData.files.add(MapEntry(
              'images',
              MultipartFile.fromBytes(
                bytes,
                filename: image.name,
                contentType: MediaType("image", "jpeg"),
              ),
            ));
          } else if (image is html.File) {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(image);
            await reader.onLoadEnd.first;
            
            formData.files.add(MapEntry(
              'images',
              MultipartFile.fromBytes(
                List.from(reader.result as List<int>),
                filename: image.name,
                contentType: MediaType("image", "jpeg"),
              ),
            ));
          }
        }
      }
    }

    return formData;
  }
}
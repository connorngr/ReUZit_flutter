import 'package:dio/dio.dart';

class Listing {
  final int? id;
  final String title;
  final String description;
  final int price;
  final String category;
  final String condition;
  final String status;
  final List<String> images;
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

  FormData toForm() {
    return FormData.fromMap({
      if (id != null) 'id': id.toString(), // Include id if it's not null (for updates)
      'title': title,
      'description': description,
      'price': price.toString(),
      'category': category,
      'condition': condition,
      
      // Example: Add files if required for images
      'images': images.map((imagePath) async {
        return await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last);
      }).toList(),
    });
  }
}

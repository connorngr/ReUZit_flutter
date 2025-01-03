import 'dart:io' as io;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String imageUrl;
  final String role;
  final bool locked;
  final int money;
  final String bio;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl = '',
    required this.role,
    required this.locked,
    required this.money,
    this.bio = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      imageUrl: json['imageUrl'] ?? '',
      role: json['role'],
      locked: json['locked'],
      money: json['money'],
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'imageUrl': imageUrl,
      'role': role,
      'locked': locked,
      'money': money,
      'bio': bio,
    };
  }

  static Future<FormData> toForm(dynamic image) async {
    final formData = FormData();

    if (image != null) {
      if (!kIsWeb) {
        // Mobile platform
        if (image is String) {
          final file = io.File(image);
          if (await file.exists()) {
            formData.files.add(MapEntry(
              'image',
              await MultipartFile.fromFile(
                image,
                filename: image.split('/').last,
                contentType: MediaType("image", "jpeg"),
              ),
            ));
          }
        }
      } else {
        // Web platform
        if (image is XFile) {
          final bytes = await image.readAsBytes();
          formData.files.add(MapEntry(
            'image',
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
            'image',
            MultipartFile.fromBytes(
              reader.result as List<int>,
              filename: image.name,
              contentType: MediaType("image", "jpeg"),
            ),
          ));
        }
      }
    }

    return formData;
  }
}
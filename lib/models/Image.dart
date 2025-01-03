import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class ImageModel {
  final int? id;
  final String url;

  ImageModel({
    this.id,
    required this.url,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] as int?,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }

  static Future<FormData> toForm({
    required int listingId,
    required List<dynamic> images,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('listingId', listingId.toString()));

    if (images.isEmpty) return formData;

    if (!kIsWeb) {
      // Mobile Platform
      for (var image in images) {
        if (image is String) {
          final file = io.File(image);
          if (await file.exists()) {
            formData.files.add(
              MapEntry(
                'files',
                await MultipartFile.fromFile(
                  image,
                  filename: image.split('/').last,
                  contentType: MediaType('image', 'jpeg'),
                ),
              ),
            );
          }
        } else if (image is XFile) {
          formData.files.add(
            MapEntry(
              'files',
              await MultipartFile.fromFile(
                image.path,
                filename: image.name,
                contentType: MediaType('image', 'jpeg'),
              ),
            ),
          );
        }
      }
    } else {
      // Web Platform
      for (var image in images) {
        if (image is XFile) {
          final bytes = await image.readAsBytes();
          formData.files.add(
            MapEntry(
              'files',
              MultipartFile.fromBytes(
                bytes,
                filename: image.name,
                contentType: MediaType('image', 'jpeg'),
              ),
            ),
          );
        } else if (image is html.File) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(image);
          await reader.onLoadEnd.first;

          formData.files.add(
            MapEntry(
              'files',
              MultipartFile.fromBytes(
                List.from(reader.result as List<int>),
                filename: image.name,
                contentType: MediaType('image', 'jpeg'),
              ),
            ),
          );
        }
      }
    }

    return formData;
  }
}
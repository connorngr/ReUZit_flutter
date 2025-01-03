// image_state_provider.dart (renamed from image_provider.dart)
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2/models/Image.dart';
import '../services/image_service.dart';

class ImageStateProvider extends ChangeNotifier {  // Renamed from ImageProvider
  final ImageService _imageService = ImageService();
  Map<int, List<ImageModel>> _listingImages = {};

  List<ImageModel> getImagesForListing(int listingId) {
    return _listingImages[listingId] ?? [];
  }

  Future<void> fetchImages(int listingId) async {
    try {
      final images = await _imageService.getAllImagesByListingId(listingId);
      _listingImages[listingId] = images;
      notifyListeners();
    } catch (e) {
      print('Error fetching images: $e');
      throw Exception('Error fetching images');
    }
  }

  Future<void> addImages(int listingId, List<XFile> newImages) async {
    try {
      final uploadedImages = await _imageService.addImages(listingId, newImages);
      
      if (_listingImages.containsKey(listingId)) {
        _listingImages[listingId]!.addAll(uploadedImages);
      } else {
        _listingImages[listingId] = uploadedImages;
      }
      
      notifyListeners();
    } catch (e) {
      throw Exception('Error adding images');
    }
  }

  Future<void> deleteImage(int listingId, ImageModel image) async {
    try {
      // Pass as single-item list to match backend requirement
      await _imageService.deleteImages([image.id!]);
      
      if (_listingImages.containsKey(listingId)) {
        _listingImages[listingId]!.removeWhere((img) => img.id == image.id);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting image: $e');
      throw Exception('Error deleting image');
    }
  }
}
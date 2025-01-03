import 'package:flutter/material.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/services/listing_service.dart';

class ListingProvider with ChangeNotifier {
  final ListingService _listingService = ListingService();
  List<Listing> _listings = [];
  List<Listing> _listingsOfMe = [];
  bool _isLoading = false;
  String? _error;

  List<Listing> get listings => _listings;
  List<Listing> get listingsOfMe => _listingsOfMe;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> fetchListings() async {
    try {
      _listings = await _listingService.fetchListings();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
  Future<void> fetchListingsOfMe() async {
    try {
      _listingsOfMe = await _listingService.fetchListingsOfMe();
      notifyListeners();  
    } catch (error) {
      throw error;
    }
  }

  Future<void> addListing(Listing listing) async {
    try {
      _setLoading(true);
      _setError(null);

      await _listingService.addListing(listing);
      
      // Refresh listings after successful addition
      await fetchListingsOfMe();
      await fetchListings();
      
      notifyListeners();
    } catch (error) {
      _setError(error.toString());
      throw error;
    } finally {
      _setLoading(false);
    }
  }

Future<void> updateListing(Listing listing) async {
  try {
    _setLoading(true);
    _setError(null);
    
    if (listing.id == null) {
      throw Exception('Listing ID is required for update');
    }

    final response = await _listingService.updateListing(listing.id!, listing);
    
      await fetchListingsOfMe();
      await fetchListings();
      notifyListeners();
  } catch (error) {
    _setError(error.toString());
    throw error;
  } finally {
    _setLoading(false);
  }
}

  Future<void> deleteListing(int id) async {
    try {
      await _listingService.deleteListings([id]);
      await fetchListingsOfMe();
      await fetchListings();
      
      notifyListeners();
    } catch (error) {
      _setError(error.toString());
      throw error;
    } finally {
      _setLoading(false);
    }
    // Add method to clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  }
}
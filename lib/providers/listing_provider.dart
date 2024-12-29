import 'package:flutter/material.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/services/listing_service.dart';

class ListingProvider with ChangeNotifier {
  final ListingService _listingService = ListingService();
  List<Listing> _listings = [];
  List<Listing> _listingsOfMe = [];
  List<Listing> get listings => _listings;
  List<Listing> get listingsOfMe => _listingsOfMe;

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
      await _listingService.addListing(listing);
      _listings.add(listing);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateListing(Listing listing) async {
    try {
      await _listingService.updateListing(listing.id!, listing.toForm());
      final index = _listings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _listings[index] = listing;
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteListing(int id) async {
    try {
      await _listingService.deleteListing(id);
      _listings.removeWhere((listing) => listing.id == id);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
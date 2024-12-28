
import 'package:flutter/material.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/screens/listing/add_listing_screen.dart';

class EditListingScreen extends StatelessWidget {
  const EditListingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the listing passed through navigation arguments
    final listing = ModalRoute.of(context)!.settings.arguments as Listing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
      ),
      body: AddOrEditListingScreen(
        listing: listing, // Pass listing to pre-fill form for editing
      ),
    );
  }
}
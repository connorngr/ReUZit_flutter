import 'package:flutter/material.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/services/listing_service.dart';
import 'add_listing_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  static const routeName = '/detailListing';

  const ListingDetailScreen({Key? key, required this.listing}) : super(key: key);

  void _deleteListing(BuildContext context) async {
    final listingService = ListingService();

    try {
      await listingService.deleteListing(listing.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing deleted successfully')),
      );
      Navigator.pop(context, true); // Return to the previous screen
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete listing: $error')),
      );
    }
  }

  void _editListing(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrEditListingScreen(listing: listing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listing.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(listing.description),
            const SizedBox(height: 10),
            Text('Price: \$${listing.price}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _editListing(context),
              child: const Text('Edit Listing'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _deleteListing(context),
              child: const Text('Delete Listing'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/screens/listing/listing_card.dart';
import 'package:untitled2/providers/listing_provider.dart';
import 'package:untitled2/screens/listing/add_listing_screen.dart';

class MyListing extends StatefulWidget {
  @override
  _MyListingState createState() => _MyListingState();
}

class _MyListingState extends State<MyListing> {
  @override
  void initState() {
    super.initState();
    Provider.of<ListingProvider>(context, listen: false).fetchListingsOfMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Listings"),
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, child) {
          if (listingProvider.listingsOfMe.isEmpty) {
            return Center(child: Text("No listings found"));
          } else {
            return GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 3 / 4,
              ),
              itemCount: listingProvider.listingsOfMe.length,
              itemBuilder: (context, index) {
                return ListingCard(listing: listingProvider.listingsOfMe[index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddOrEditListingScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Listing',
      ),
    );
  }
}
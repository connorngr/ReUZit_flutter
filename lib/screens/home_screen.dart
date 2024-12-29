import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/screens/listing/listing_card.dart';
import 'package:untitled2/providers/listing_provider.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    Provider.of<ListingProvider>(context, listen: false).fetchListings();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingProvider>(
      builder: (context, listingProvider, child) {
        if (listingProvider.listings.isEmpty) {
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
            itemCount: listingProvider.listings.length,
            itemBuilder: (context, index) {
              return ListingCard(listing: listingProvider.listings[index]);
            },
          );
        }
      },
    );
  }
}
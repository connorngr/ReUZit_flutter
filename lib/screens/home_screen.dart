import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/screens/listing/listing_card.dart';
import 'package:untitled2/providers/listing_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Listing> _filteredListings = [];

  @override
  void initState() {
    super.initState();
    Provider.of<ListingProvider>(context, listen: false).fetchListings();
    _searchController.addListener(_filterListings);
  }

  void _filterListings() {
    final query = _searchController.text.toLowerCase();
    final allListings =
        Provider.of<ListingProvider>(context, listen: false).listings;

    setState(() {
      _filteredListings = allListings.where((listing) {
        return listing.title.toLowerCase().contains(query) ||
            listing.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Listings',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: Consumer<ListingProvider>(
            builder: (context, listingProvider, child) {
              final listingsToShow = _searchController.text.isEmpty
                  ? listingProvider.listings
                  : _filteredListings;

              if (listingsToShow.isEmpty) {
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
                  itemCount: listingsToShow.length,
                  itemBuilder: (context, index) {
                    return ListingCard(listing: listingsToShow[index]);
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

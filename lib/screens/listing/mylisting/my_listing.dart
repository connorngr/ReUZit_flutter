import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/screens/listing/edit_listing_screen.dart';
import 'package:untitled2/screens/listing/listing_card.dart';
import 'package:untitled2/providers/listing_provider.dart';
import 'package:untitled2/screens/listing/add_listing_screen.dart';
import 'package:untitled2/models/listing.dart'; // Make sure to import your Listing model
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyListing extends StatefulWidget {
  @override
  _MyListingState createState() => _MyListingState();
}

class _MyListingState extends State<MyListing> {
  static final String image_url = dotenv.get('IMAGE_URL');
  TextEditingController _searchController = TextEditingController();
  List<Listing> _filteredListings = [];

  @override
  void initState() {
    super.initState();
    Provider.of<ListingProvider>(context, listen: false).fetchListingsOfMe();
    _searchController.addListener(_filterListings);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterListings() {
    final query = _searchController.text.toLowerCase();
    final allListings =
        Provider.of<ListingProvider>(context, listen: false).listingsOfMe;

    setState(() {
      _filteredListings = allListings.where((listing) {
        return listing.title.toLowerCase().contains(query) ||
            listing.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Function to handle editing a listing
  void _editListing(BuildContext context, Listing listing) {
    Navigator.push(
      context,
      EditListingScreen.route(listing: listing),
    ).then((_) {
      // Refresh the listings after editing
      Provider.of<ListingProvider>(context, listen: false).fetchListingsOfMe();
    });
  }

  // Function to handle deleting a listing
  void _deleteListing(BuildContext context, Listing listing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Listing'),
          content: Text('Are you sure you want to delete this listing?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                try {
                  await Provider.of<ListingProvider>(context, listen: false)
                      .deleteListing(listing.id!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Listing deleted successfully')),
                  );
                } catch (error) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.toString())),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                final listingsToShow =
                    _searchController.text.isEmpty ? listingProvider.listingsOfMe : _filteredListings;

                if (listingProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (listingProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(listingProvider.error!),
                        ElevatedButton(
                          onPressed: listingProvider.fetchListingsOfMe,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (listingsToShow.isEmpty) {
                  return Center(child: Text("No listings found"));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3 / 5,
                  ),
                  itemCount: listingsToShow.length,
                  itemBuilder: (context, index) {
                    final listing = listingsToShow[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                  child: Image.network(
                                    listing.images.isNotEmpty
                                        ? '$image_url${listing.images.first}'
                                        : 'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.image, size: 40, color: Colors.grey);
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: PopupMenuButton(
                                    icon: Icon(Icons.more_vert, color: Colors.white, size: 20),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _editListing(context, listing);
                                      } else if (value == 'delete') {
                                        _deleteListing(context, listing);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listing.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${listing.price} VND",
                                  style: TextStyle(color: Colors.green),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  listing.category,
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _editListing(context, listing),
                                        icon: Icon(Icons.edit, size: 16),
                                        label: Text('Edit', style: TextStyle(fontSize: 12)),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _deleteListing(context, listing),
                                        icon: Icon(Icons.delete, size: 16),
                                        label: Text('Delete', style: TextStyle(fontSize: 12)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddListingScreen()),
          ).then((_) {
            Provider.of<ListingProvider>(context, listen: false).fetchListingsOfMe();
          });
        },
        child: Icon(Icons.add),
        tooltip: 'Add Listing',
      ),
    );
  }
}

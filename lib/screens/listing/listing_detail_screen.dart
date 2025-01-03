import 'package:flutter/material.dart';
import 'package:untitled2/models/listing.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_html/flutter_html.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  static const routeName = '/detailListing';

  const ListingDetailScreen({Key? key, required this.listing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND').format(listing.price);
    final String imageUrl = dotenv.get('IMAGE_URL');

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(listing.images, imageUrl),
            const SizedBox(height: 20),
            Text(
              listing.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Price: $formattedPrice',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              'Category: ${listing.category}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Condition: ${listing.condition}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              'Description${listing.description}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Html(
            //   data: listing.description,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<dynamic> images, String baseUrl) {
    if (images.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Center(child: Text('No images available')),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Image.network(
              '$baseUrl${images[index]}',
              fit: BoxFit.cover,
              width: 300,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 300,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, size: 50)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
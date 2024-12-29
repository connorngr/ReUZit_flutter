import 'package:flutter/material.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/services/listing_service.dart';
import 'package:image_picker/image_picker.dart';

class AddOrEditListingScreen extends StatefulWidget {
  final Listing? listing; // Pass this for editing

  const AddOrEditListingScreen({Key? key, this.listing}) : super(key: key);

  @override
  _AddOrEditListingScreenState createState() => _AddOrEditListingScreenState();
}

class _AddOrEditListingScreenState extends State<AddOrEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _listingService = ListingService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryIdController;
  late TextEditingController _conditionController;
  late TextEditingController _statusController;

  List<XFile>? _images;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listing?.title ?? '');
    _descriptionController = TextEditingController(text: widget.listing?.description ?? '');
    _priceController = TextEditingController(text: widget.listing?.price?.toString() ?? '');
    _categoryIdController = TextEditingController(text: widget.listing?.category ?? '');
    _conditionController = TextEditingController(text: widget.listing?.condition ?? 'New');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryIdController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    setState(() {
      _images = selectedImages;
    });
  }

  void _saveListing() async {
    if (_formKey.currentState!.validate()) {
      final listing = Listing(
        id: widget.listing?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        price: int.parse(_priceController.text),
        category: _categoryIdController.text,
        condition: _conditionController.text,
        status: widget.listing?.status ?? 'Available', 
        images: _images?.map((image) => image.path).toList() ?? [],
        createdAt: widget.listing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      print(listing.toJson());
      try {
        if (widget.listing == null) {
          await _listingService.addListing(listing);
        } else {
          await _listingService.updateListing(listing.id!, listing.toForm());
        }
        Navigator.pop(context, true); // Return to the previous screen
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save listing: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing == null ? 'Add Listing' : 'Edit Listing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Price is required' : null,
              ),
              TextFormField(
                controller: _categoryIdController,
                decoration: const InputDecoration(labelText: 'Category ID'),
                validator: (value) => value == null || value.isEmpty ? 'Category ID is required' : null,
              ),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(labelText: 'Condition'),
                validator: (value) => value == null || value.isEmpty ? 'Condition is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Pick Images'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveListing,
                child: Text(widget.listing == null ? 'Add Listing' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

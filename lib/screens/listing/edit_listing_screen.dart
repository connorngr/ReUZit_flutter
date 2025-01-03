import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/models/Image.dart';
import 'package:untitled2/models/category.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/providers/image_provider.dart';
import 'package:untitled2/providers/listing_provider.dart';
import 'package:untitled2/services/enum_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2/services/category_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:untitled2/services/image_service.dart';

class EditListingScreen extends StatefulWidget {
  static const routeName = '/editListing';
  final Listing listing;

  static Route<dynamic> route({required Listing listing}) {
    return MaterialPageRoute(
      builder: (context) => EditListingScreen(listing: listing),
      settings: RouteSettings(
        name: routeName,
        arguments: listing,
      ),
    );
  }

  const EditListingScreen({Key? key, required this.listing}) : super(key: key);

  @override
  _EditListingScreenState createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  // Form and Services
  final _formKey = GlobalKey<FormState>();
  final _categoryService = CategoryService();
  final EnumService _enumService = EnumService();
  static final String image_url = dotenv.get('IMAGE_URL');
  final ImageService _imageService = ImageService();

  // State variables
  List<String> _conditions = [];
  List<Category> _categories = [];
  String? _selectedCategoryName;
  int? _selectedCategoryId;
  List<ImageModel> _images = [];

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _conditionController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeCategory();
    fetchEnumData();
    fetchCategories();
    _fetchImages();
  }

  // Initialization methods
  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.listing.title);
    _descriptionController =
        TextEditingController(text: widget.listing.description);
    _priceController =
        TextEditingController(text: widget.listing.price.toString());
    _conditionController =
        TextEditingController(text: widget.listing.condition);
    // _existingImages = List<String>.from(widget.listing.images);
  }

  Future<void> _initializeCategory() async {
    if (widget.listing.category != null) {
      try {
        final category =
            await _categoryService.getCategoryByName(widget.listing.category);
        setState(() {
          _selectedCategoryId = category.id;
          _selectedCategoryName = category.name;
        });
      } catch (e) {
        _showErrorSnackBar('Error loading category: $e');
      }
    }
  }

  Future<void> _fetchImages() async {
    try {
      final images =
          await _imageService.getAllImagesByListingId(widget.listing.id!);
      setState(() {
        _images = images;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading images');
    }
  }

  // Data fetching methods
  void fetchEnumData() async {
    _conditions = await _enumService.getConditions();
    setState(() {});
  }

  void fetchCategories() async {
    _categories = await _categoryService.getAllCategories();
    setState(() {});
  }

  // UI Helper methods
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final List<XFile>? selectedImages = await _picker.pickMultiImage();

      if (selectedImages != null && selectedImages.isNotEmpty) {
        _showLoadingDialog();

        await context.read<ImageStateProvider>().addImages(
              // Updated name
              widget.listing.id!,
              selectedImages,
            );

        await _fetchImages();

        Navigator.pop(context); // Hide loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Images uploaded successfully')),
        );
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
      _showErrorSnackBar('Failed to upload images');
    }
  }

  // Category handling
  Future<void> _onCategoryChanged(String? newValue) async {
    if (newValue != null) {
      try {
        final category = await _categoryService.getCategoryByName(newValue);
        setState(() {
          _selectedCategoryId = category.id;
          _selectedCategoryName = category.name;
        });
      } catch (e) {
        _showErrorSnackBar('Error selecting category: $e');
      }
    }
  }

  // Main update method
  void _updateListing() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      _showLoadingDialog();

      final updatedListing = Listing(
        id: widget.listing.id,
        title: _titleController.text,
        description: _descriptionController.text,
        price: int.parse(_priceController.text),
        category: _selectedCategoryId!.toString(),
        condition: _conditionController.text,
        status: widget.listing.status,
        images: [],
        createdAt: widget.listing.createdAt,
        updatedAt: DateTime.now(),
      );

      await context.read<ListingProvider>().updateListing(updatedListing);

      Navigator.pop(context); // Hide loading
      Navigator.pop(context, true); // Return to previous screen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Make sure we're popping the loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to update listing: ${error.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _removeExistingImage(int index) async {
    try {
      final image = _images[index];

      _showLoadingDialog();

      // Send the image's unique ID in a list
      await _imageService.deleteImages([image.id!]);

      setState(() {
        _images.removeAt(index);
      });

      Navigator.pop(context); // Hide loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }

      String errorMessage = 'Failed to delete image';
      if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      _showErrorSnackBar(
          '$errorMessage\nPlease try again or contact support if the problem persists.');
    }
  }

  // UI Building methods
  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Images:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        if (_images.isEmpty)
          Center(child: Text('No images available'))
        else
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) => _buildImageItem(index),
            ),
          ),
      ],
    );
  }

  void _verifyImageData(ImageModel image) {
    if (image.id == null) {
      throw Exception('Image ID is null');
    }

    if (image.id! <= 0) {
      throw Exception('Invalid image ID: ${image.id}');
    }
  }

  Widget _buildImageItem(int index) {
    try {
      final image = _images[index];
      _verifyImageData(image); // Verify image data before building UI

      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.network(
              '$image_url${image.url}',
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 80,
                  width: 80,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error),
                      Text('ID: ${image.id}', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                _removeExistingImage(index);
              },
            ),
          ),
        ],
      );
    } catch (e) {
      return Container(); // Return empty container on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Description is required'
                    : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Price is required' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _selectedCategoryName,
                items: _categories.map((Category category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
                onChanged: _onCategoryChanged,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Condition'),
                value: _conditions.contains(_conditionController.text)
                    ? _conditionController.text
                    : null,
                items: _conditions.map((String condition) {
                  return DropdownMenuItem<String>(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                validator: (value) => value == null || value.isEmpty
                    ? 'Condition is required'
                    : null,
                onChanged: (value) {
                  setState(() {
                    _conditionController.text = value ?? 'New';
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildImagePreview(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Add More Images'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateListing,
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _conditionController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/models/category.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/providers/listing_provider.dart';
import 'package:untitled2/services/enum_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2/services/category_service.dart';

class AddListingScreen extends StatefulWidget {
  final Listing? listing; // Pass this for editing

  const AddListingScreen({Key? key, this.listing}) : super(key: key);

  @override
  _AddOrEditListingScreenState createState() => _AddOrEditListingScreenState();
}

class _AddOrEditListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryService = CategoryService();
  final EnumService _enumService = EnumService();
  List<String> _conditions = [];
  List<Category> _categories = [];
  String? _selectedCategory;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _conditionController;

  List<XFile>? _images;

  @override
  void initState() {
    super.initState();
    // _titleController = TextEditingController(text: widget.listing?.title ?? '');
    // _descriptionController =
    //     TextEditingController(text: widget.listing?.description ?? '');
    // _priceController =
    //     TextEditingController(text: widget.listing?.price?.toString() ?? '');
    // _conditionController =
    //     TextEditingController(text: widget.listing?.condition ?? 'New');
    fetchEnumData();
    fetchCategories();
  }

  void fetchEnumData() async {
    _conditions = await _enumService.getConditions();
    setState(() {});
  }

  void fetchCategories() async {
    _categories = await _categoryService.getAllCategories();
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
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
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_images == null || _images!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
        final listing = Listing(
          id: widget.listing?.id,
          title: _titleController.text,
          description: _descriptionController.text,
          price: int.parse(_priceController.text),
          category: _selectedCategory!,
          condition: _conditionController.text,
          status: 'Available',
          images: _images!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await context.read<ListingProvider>().addListing(listing);

        // Hide loading indicator
        Navigator.pop(context);
        Navigator.pop(context, true); // Return to the previous screen

        // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save listing: $error'),
            backgroundColor: Colors.red,
          ),
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
              // DropdownButtonFormField<String>(
              //   decoration: const InputDecoration(labelText: 'Category'),
              //   value: _selectedCategory,
              //   items: _categories.map((Category category) {
              //     return DropdownMenuItem<String>(
              //       value: category.id.toString(), // Make sure this is the ID
              //       child: Text(category.name),
              //     );
              //   }).toList(),
              //   validator: (value) =>
              //       value == null ? 'Please select a category' : null,
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       _selectedCategory = newValue;
              //     });
              //   },
              // ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Condition'),
                items: _conditions.map((String condition) {
                  return DropdownMenuItem<String>(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _conditionController.text = value ?? 'New';
                  });
                },
                value: _conditions.contains(_conditionController.text)
                    ? _conditionController.text
                    : null,
                validator: (value) => value == null || value.isEmpty
                    ? 'Condition is required'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Pick Images'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveListing,
                child: Text('Add Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

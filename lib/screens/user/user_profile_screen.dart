import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2/providers/user_provider.dart';
import 'package:untitled2/services/auth_service.dart';
import 'package:untitled2/services/user_service.dart';
import 'package:untitled2/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static final String image_url = dotenv.get('IMAGE_URL');
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    await Provider.of<UserProvider>(context, listen: false).fetchUser();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: '${user?.firstName} ${user?.lastName}');
    _bioController = TextEditingController(text: user?.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) return;

    // Split the name into first and last name
    final nameParts = _nameController.text.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final updatedUser = User(
      id: user.id,
      firstName: firstName,
      lastName: lastName,
      email: user.email,
      imageUrl: user.imageUrl,
      role: user.role,
      locked: user.locked,
      money: user.money,
      bio: _bioController.text,
    );

    try {
      await userProvider.updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

Future<void> _changeProfileImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    try {
      if (!kIsWeb) {
        // Mobile platform
        final file = io.File(pickedFile.path);
        if (!await file.exists()) {
          throw Exception('File does not exist');
        }
        final fileSize = await file.length();

        // Proceed with the image upload
        final updatedUser = await _userService.updateUserImage(pickedFile.path);
        Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated successfully')),
        );
      } else {
        // Web platform
        final updatedUser = await _userService.updateUserImage(pickedFile);
        Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated successfully')),
        );
      }
    } catch (e) {
      print('Error before sending request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile image: $e')),
      );
    }
  } else {
    print('No image selected');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) {
            return Center(child: CircularProgressIndicator());
          } else {
            final formattedMoney = NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(user.money);
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 300,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _changeProfileImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.yellow,
                                backgroundImage: user.imageUrl.isNotEmpty
                                    ? NetworkImage('$image_url${user.imageUrl}')
                                    : NetworkImage("https://picsum.photos/200/200"),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              initialValue: user.email,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                enabled: false, // Make email non-editable
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _bioController,
                              decoration: InputDecoration(
                                labelText: 'Bio',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text('Save Changes'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
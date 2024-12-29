import 'package:flutter/material.dart';
import 'package:untitled2/models/user.dart';
import 'package:untitled2/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  Future<void> fetchUser() async {
    try {
      print('Fetching user...');
      _user = await _authService.getCurrentUser();
      print('User fetched: ${_user?.firstName}');
      notifyListeners();
    } catch (e) {
      print('Error fetching user: $e');
    }
  }
}
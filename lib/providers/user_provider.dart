import 'package:flutter/material.dart';
import 'package:untitled2/models/user.dart';
import 'package:untitled2/services/auth_service.dart';
import 'package:untitled2/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
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

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      await _userService.updateUserData(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Error updating user: $e');
      throw e; // Re-throw the error to handle it in the UI
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
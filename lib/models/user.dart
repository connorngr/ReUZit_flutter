import 'dart:convert';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String imageUrl;
  final String role;
  final bool locked;
  final int money;
  final String bio;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl = '',
    required this.role,
    required this.locked,
    required this.money,
    this.bio = '',
  });
//What is factory?
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      imageUrl: json['imageUrl'] ?? '',
      role: json['role'],
      locked: json['locked'],
      money: json['money'],
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'imageUrl': imageUrl,
      'role': role,
      'locked': locked,
      'money': money,
      'bio': bio,
    };
  }
}

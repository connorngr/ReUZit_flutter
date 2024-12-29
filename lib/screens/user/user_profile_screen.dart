import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/providers/user_provider.dart';
import 'package:untitled2/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserProfileScreen extends StatelessWidget {
  static final String image_url = dotenv.get('IMAGE_URL');
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // Fetch user data when the screen is built
    Provider.of<UserProvider>(context, listen: false).fetchUser();

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
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
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.yellow,
                              backgroundImage: user.imageUrl.isNotEmpty
                                  ? NetworkImage('$image_url${user.imageUrl}')
                                  : NetworkImage("https://picsum.photos/200/200"),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.email),
                                SizedBox(width: 8),
                                Text('Email: ${user.email}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.money),
                                SizedBox(width: 8),
                                Text('Money: $formattedMoney'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
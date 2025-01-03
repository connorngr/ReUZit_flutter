import 'package:flutter/material.dart';
import 'package:untitled2/services/auth_service.dart';
import 'package:untitled2/services/google_auth_service.dart';
import 'package:untitled2/utils/helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'arty15@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '123456');
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      print(email);
      Helpers.showSnackBar(context, "Please enter email and password");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _authService.login(email, password);
      if (token != null) {
        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Helpers.showSnackBar(context, "Invalid email or password");
      }
    } catch (e) {
      Helpers.showSnackBar(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final token = await _googleAuthService.googleLogin();
                if (token != null) {
                  // Successfully logged in, navigate to the home screen
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  // Failed to log in
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Google login failed')));
                }
              },
              child: Text('Sign in with Google'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _navigateToRegister,
              child: Text('Don’t have an account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
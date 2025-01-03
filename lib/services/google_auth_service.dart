import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled2/utils/dio_client.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.get('GOOGLE_CLIENT_ID'),
      scopes: ["profile", "email"],
      forceCodeForRefreshToken: true,);
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Dio _dio = DioClient().client;
  // Google SignIn function
  Future<String?> googleLogin() async {
    try {
      // Trigger the Google SignIn process
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the login
        return null;
      }

      // Obtain the authentication code (authorization code)
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      String? authCode = googleAuth.accessToken;
      if (authCode != null) {
        // Send the authorization code to the backend for processing
        final response = await _dio.post(
            '/auth/google?authCode=$authCode'
        );

        // Handle the response, which should include the JWT token
        if (response.statusCode == 200) {
          final token = response.data['token'];
          // Save the JWT token to secure storage
          await _storage.write(key: 'jwt_token', value: token);
          return token;
        } else {
          // Handle failure
          print('Google login failed');
          return null;
        }
      }
    } catch (e) {
      print('Error during Google login: $e');
      return null;
    }
    return null;
  }

}

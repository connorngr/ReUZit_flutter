import 'package:flutter/material.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/screens/auth/login_screen.dart';
import 'package:untitled2/screens/auth/register_screen.dart';
import 'package:untitled2/screens/listing/add_listing_screen.dart';
import 'package:untitled2/screens/listing/edit_listing_screen.dart';
import 'package:untitled2/screens/listing/listing_detail_screen.dart';
import 'package:untitled2/screens/splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/providers/image_provider.dart';
import 'package:untitled2/providers/listing_provider.dart';
import 'package:untitled2/providers/user_provider.dart';
import 'package:untitled2/screens/user/user_profile_screen.dart';
import './navbar/main_screen.dart';
Future main() async {
  await dotenv.load(fileName: "dotenv");
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListingProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ImageStateProvider()),
      ],
      child: MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReUZit App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => MainScreen(),
        '/register': (context) => RegisterScreen(),
        '/addListing': (context) => const AddListingScreen(),
        '/settings': (context) => UserProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ListingDetailScreen.routeName) {
          final listing = settings.arguments as Listing;
          return MaterialPageRoute(
            builder: (context) => ListingDetailScreen(listing: listing),
          );
        }
        // Handle edit listing route
        if (settings.name == '/editListing') {
          final listing = settings.arguments as Listing;
          return MaterialPageRoute(
            builder: (context) => EditListingScreen(listing: listing),
          );
        }
        return null;
      },
    );
  }
}

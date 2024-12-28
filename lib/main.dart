import 'package:flutter/material.dart';
import 'package:untitled2/models/listing.dart';
import 'package:untitled2/screens/auth/login_screen.dart';
import 'package:untitled2/screens/auth/register_screen.dart';
import 'package:untitled2/screens/home_screen.dart';
import 'package:untitled2/screens/listing/add_listing_screen.dart';
import 'package:untitled2/screens/listing/edit_listing_screen.dart';
import 'package:untitled2/screens/listing/listing_detail_screen.dart';
import 'package:untitled2/screens/splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future main() async {
  await dotenv.load(fileName: "dotenv");
  runApp(MyApp());
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
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegisterScreen(),
        '/addListing': (context) => const AddOrEditListingScreen(),
        '/editListing': (context) => const EditListingScreen(), // New route
      },
      onGenerateRoute: (settings) {
        if (settings.name == ListingDetailScreen.routeName) {
          final listing = settings.arguments as Listing; // Get the argument
          return MaterialPageRoute(
            builder: (context) => ListingDetailScreen(listing: listing),
          );
        }
        return null; // Return null if no matching route
      },
      // home: SplashScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart'; // Import the new landing screen
import 'screens/login_screen.dart'; // Import the new login screen
import 'screens/signup_screen.dart'; // Import the new signup screen
import 'screens/confirm_details.dart'; //Import the confirm details, a.k.a Signup 2 page
import 'screens/main.dart'; // Import the main screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the shared preferences and http client
  final sharedPreferences = await SharedPreferences.getInstance();
  final httpClient = http.Client();

  runApp(CulinaryCompanionApp(
    sharedPreferences: sharedPreferences,
    httpClient: httpClient,
  ));
}

class CulinaryCompanionApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final http.Client httpClient;

  CulinaryCompanionApp({
    required this.sharedPreferences,
    required this.httpClient,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Culinary Companion',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF20493C),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white12,
        ),
      ),
      initialRoute: '/landing', // Set the initial route to the landing screen
      routes: {
        '/landing': (context) =>
            LandingScreen(), // Add the landing screen route
        '/login': (context) => LoginScreen(), // Add the login screen route
        '/signup': (context) => SignupScreen(
              httpClient: httpClient,
              sharedPreferences: sharedPreferences,
            ), // Add the signup screen route
        '/home': (context) => MainScreen(), // Rename the home route
        '/confirm': (context) => ConfirmDetailsScreen(),
      },
    );
  }
}

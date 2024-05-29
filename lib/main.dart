import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart'; // Import the new landing screen
import 'screens/login_screen.dart'; // Import the new login screen
import 'screens/signup_screen.dart'; // Import the new signup screen
import 'screens/main.dart'; // Import the new signup screen

void main() {
  runApp(CulinaryCompanionApp());
}

class CulinaryCompanionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Culinary Companion',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0B3D36),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white12,
        ),
      ),
      initialRoute: '/landing', // Set the initial route to the landing screen
      routes: {
        '/landing': (context) => LandingScreen(), // Add the landing screen route
        '/login': (context) => LoginScreen(), // Add the login screen route
        '/signup': (context) => SignupScreen(), // Add the signup screen route
        '/home': (context) => MainScreen(), // Rename the home route
      },
    );
  }
}
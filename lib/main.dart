import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/scan_recipe_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/saved_recipes_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_recipe_screen.dart';
import './widgets/navbar.dart';
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
        scaffoldBackgroundColor: Color(0xFF0B3D36), // Dark green background
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white12,
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String currentRoute = '/';

  void changeRoute(String newRoute) {
    setState(() {
      currentRoute = newRoute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(currentRoute: currentRoute, onChange: changeRoute),
      body: _buildScreen(currentRoute),
    );
  }

  Widget _buildScreen(String route) {
    switch (route) {
      case '/':
        return HomeScreen();
      case '/scan-recipe':
        return AddRecipeScreen();
      case '/shopping-list':
        return ScanRecipeScreen();
      case '/saved-recipes':
        return SavedRecipesScreen();
      case '/profile':
        return ProfileScreen();
      default:
        return Container(); // Add any default behavior here
    }
  }
}
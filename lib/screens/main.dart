import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'scan_recipe_screen.dart';
import 'shopping_list_screen.dart';
import 'saved_recipes_screen.dart';
import 'profile_screen.dart';
import 'add_recipe_screen.dart';
import '../widgets/navbar.dart';
void main() {
  runApp(CulinaryCompanionApp());
}

class CulinaryCompanionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
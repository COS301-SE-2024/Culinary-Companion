import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'shopping_pantry_screen.dart';
//import 'shopping_list_screen.dart';
import 'saved_recipes_screen.dart';
import 'profile_screen.dart';
import 'add_recipe_screen.dart';
import '../widgets/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://gsnhwvqprmdticzglwdf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzbmh3dnFwcm1kdGljemdsd2RmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTY2MzAwNzgsImV4cCI6MjAzMjIwNjA3OH0.1VIuJzuMHBLFC6EduaGCOk0IPoIBdkOJsF2FwrqcP7Y',
  );
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
        return ShoppingPantryScreen();
      case '/saved-recipes':
        return SavedRecipesScreen();
      case '/profile':
        return ProfileScreen();
      default:
        return Container(); // Add any default behavior here
    }
  }
}

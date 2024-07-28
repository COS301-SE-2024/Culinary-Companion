//main2.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
// import '../widgets/shopping_list_screen.dart';
// import '../widgets/pantry_screen.dart';
// import '../widgets/appliances_screen.dart';
import 'saved_recipes_screen.dart';
import 'profile_screen.dart';
import 'add_recipe_screen.dart';
import 'inventory_screen.dart';
import '../widgets/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://gsnhwvqprmdticzglwdf.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
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
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 1360) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  80.0, // Adjust 56.0 as needed based on your AppBar height
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildScreen(currentRoute),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Adjust padding as needed
                child: ExpandableNavbar(
                  currentRoute: currentRoute,
                  onChange: changeRoute,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: Navbar(currentRoute: currentRoute, onChange: changeRoute),
        body: _buildScreen(currentRoute),
      );
    }
  }

  Widget _buildScreen(String route) {
    switch (route) {
      case '/':
        return HomeScreen();
      case '/scan-recipe':
        return AddRecipeScreen();
      case '/inventory-screen':
        return InventoryScreen();
      case '/saved-recipes':
        return SavedRecipesScreen();
      case '/profile':
        return ProfileScreen();
      default:
        return Container();
    }
  }
}

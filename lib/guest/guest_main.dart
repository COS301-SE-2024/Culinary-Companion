import 'package:flutter/material.dart';
import 'package:flutter_application_1/guest/guest_navbar.dart';
import 'package:flutter_application_1/guest/guest_search_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'guest_home_screen.dart';
//import 'guest_search_screen.dart';

class MainScreen2 extends StatefulWidget {
  final bool isGuest; // Add a flag for guest users
  
  MainScreen2({this.isGuest = false}); // Default to false for regular users
  
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen2> {
  String currentRoute = '/';

  void changeRoute(String newRoute) {
    if (mounted) {
      setState(() {
        currentRoute = newRoute;
      });
    }
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
                  isGuest: widget.isGuest, // Pass guest flag
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: GuestNavbar(
          currentRoute: currentRoute,
          onChange: changeRoute,
          isGuest: widget.isGuest, // Pass guest flag
        ),
        body: _buildScreen(currentRoute),
      );
    }
  }

  Widget _buildScreen(String route) {
    switch (route) {
      case '/':
        return GuestHomeScreen();
      case '/search':
        return GuestSearchScreen();
      case '/login':
        return LoginScreen();
      default:
        return Container(); // Guests have limited access, no extra screens
    }
  }
}

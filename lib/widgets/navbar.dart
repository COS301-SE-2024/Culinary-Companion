import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final Function(String)? onChange; // Make onChange optional

  Navbar({required this.currentRoute, this.onChange});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Culinary Companion',
        style: TextStyle(color: Colors.orange),
      ),
      actions: [
        _buildNavItem(context, 'Home', '/'),
        _buildNavItem(context, 'Scan Recipe', '/scan-recipe'),
        _buildNavItem(context, 'Shopping List', '/shopping-list'),
        _buildNavItem(context, 'Saved Recipes', '/saved-recipes'),
        _buildNavItem(context, 'Profile', '/profile'),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String title, String route) {
    bool isSelected = currentRoute == route;
    return TextButton(
      onPressed: () {
        if (!isSelected && onChange != null) { // Check if onChange is not null
          onChange!(route); // Call onChange if it's not null
        }
      },
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.orange : Colors.white,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final Function(String)? onChange;

  const Navbar({required this.currentRoute, this.onChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0), // Adjust padding as needed
      child: AppBar(
        automaticallyImplyLeading: false, // Disable the back button
        title: Padding(
          padding: const EdgeInsets.only(
              left: 16.0), // Adjust left padding as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Culinary',
                style: TextStyle(color: Color(0xFFD9D9D9)),
              ),
              Text(
                'Companion',
                style: TextStyle(color: Color(0xFFDC945F)),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        toolbarHeight: 80, // Set a custom height for the AppBar
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavItem(context, 'Home', '/', currentRoute == '/'),
              _buildNavItem(context, 'Scan Recipe', '/scan-recipe',
                  currentRoute == '/scan-recipe'),
              _buildNavItem(context, 'Shopping List', '/shopping-list',
                  currentRoute == '/shopping-list'),
              _buildNavItem(context, 'Saved Recipes', '/saved-recipes',
                  currentRoute == '/saved-recipes'),
              _buildNavItem(
                  context, 'Profile', '/profile', currentRoute == '/profile'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, String title, String route, bool isSelected) {
    return TextButton(
      onPressed: () {
        if (!isSelected && onChange != null) {
          onChange!(route);
        }
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 2.0), // Add padding to the bottom side
        decoration: isSelected
            ? BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Color(0xFFDC945F),
                        width: 2.0)), // Add a bottom border
              )
            : null,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Color(0xFFDC945F) : Color(0xFFD9D9D9),
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(80); // Update the preferredSize height
}

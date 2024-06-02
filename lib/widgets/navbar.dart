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
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        toolbarHeight: 80, // Set a custom height for the AppBar
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Image.asset(
              'logo_2.png',
              height: 80, // Adjust the height as needed
            ),
            // Centered tabs
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavItem(context, 'Home', '/', currentRoute == '/'),
                  _buildNavItem(context, 'Scan Recipe', '/scan-recipe',
                      currentRoute == '/scan-recipe'),
                  _buildNavItem(context, 'Shopping List', '/shopping-list',
                      currentRoute == '/shopping-list'),
                  _buildNavItem(context, 'Saved Recipes', '/saved-recipes',
                      currentRoute == '/saved-recipes'),
                  _buildNavItem(context, 'Profile', '/profile',
                      currentRoute == '/profile'),
                ],
              ),
            ),
            // Search bar on the right
            Container(
              width: 269,
              height: 36,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Color(0xFFD9D9D9)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Color(0xFFD9D9D9),
                  ),
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, String title, String route, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8.0), // Adjust horizontal padding as needed
      child: TextButton(
        onPressed: () {
          if (!isSelected && onChange != null) {
            onChange!(route);
          }
        },
        child: Container(
          padding:
              EdgeInsets.only(bottom: 2.0), // Add padding to the bottom side
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
              fontSize: 18, // Set the font size to 20
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(120); // Update the preferredSize height
}

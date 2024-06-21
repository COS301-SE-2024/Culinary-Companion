import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final Function(String)? onChange;

  const Navbar({required this.currentRoute, this.onChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isLightTheme = theme.brightness == Brightness.light;

    return Padding(
      padding:
          EdgeInsets.only(top: screenHeight * 0.03), // Adjust padding as needed
      child: AppBar(
        automaticallyImplyLeading: false, // Disable the back button
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        toolbarHeight: screenHeight * 0.1, // Set a custom height for the AppBar
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Image.asset(
              isLightTheme ? 'logo_1.png' : 'logo_2.png',
              height: screenHeight * 0.1, // Adjust the height as needed
            ),
            // Centered tabs
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavItem(context, 'Home', '/', currentRoute == '/'),
                    _buildNavItem(context, 'Add Recipe', '/scan-recipe',
                        currentRoute == '/scan-recipe'),
                    _buildNavItem(context, 'Shopping List', '/shopping-list',
                        currentRoute == '/shopping-list'),
                    _buildNavItem(context, 'Pantry', '/pantry-list',
                        currentRoute == '/pantry-list'),
                    _buildNavItem(context, 'Appliances', '/appliances',
                        currentRoute == '/appliances'),
                    _buildNavItem(context, 'Saved Recipes', '/saved-recipes',
                        currentRoute == '/saved-recipes'),
                    _buildNavItem(context, 'Profile', '/profile',
                        currentRoute == '/profile'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, String title, String route, bool isSelected) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.light
        ? Color(0xFF1E1E1E)
        : Color(0xFFD9D9D9);
    final activeColor = Color(0xFFDC945F);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.005), // Reduce horizontal padding
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
                      color: activeColor,
                      width: 2.0,
                    ), // Add a bottom border
                  ),
                )
              : null,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? activeColor : textColor,
              fontSize: 18,
              // fontSize: screenWidth *
              //     0.01,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120); // Provide a default value
}

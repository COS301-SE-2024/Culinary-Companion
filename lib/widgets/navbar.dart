import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final Function(String)? onChange;

  const Navbar({required this.currentRoute, this.onChange});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.03), // Adjust padding as needed
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
              'logo_2.png',
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
            // // Conditionally render the search bar
            // if (screenWidth >= 1135)
            //   Container(
            //     width: screenWidth * 0.2,
            //     height: screenHeight * 0.04,
            //     child: TextField(
            //       decoration: InputDecoration(
            //         hintText: 'Search...',
            //         hintStyle: TextStyle(color: Color(0xFFD9D9D9)),
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(screenHeight * 0.02),
            //           borderSide: BorderSide(color: Colors.white),
            //         ),
            //         suffixIcon: Icon(
            //           Icons.search,
            //           color: Color(0xFFD9D9D9),
            //         ),
            //         filled: false,
            //         contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
            //       ),
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, String route, bool isSelected) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.03; // Adjust the font size based on screen width

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.005), // Reduce horizontal padding
      child: TextButton(
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
                      width: 2.0,
                    ), // Add a bottom border
                  ),
                )
              : null,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Color(0xFFDC945F) : Color(0xFFD9D9D9),
              fontSize: fontSize.clamp(12.0, 18.0), // Clamp font size between 12 and 18
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

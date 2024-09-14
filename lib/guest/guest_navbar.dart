import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/landing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final Function(String)? onChange;
  final bool isGuest; // Flag to identify guest users

  const GuestNavbar(
      {required this.currentRoute, this.onChange, this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;

    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.03),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        toolbarHeight: screenHeight * 0.1,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                isLightTheme ? 'assets/logo_1.png' : 'assets/logo_2.png',
                height: screenHeight * 0.1,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNavItem(context, 'Home', '/', currentRoute == '/'),
                      _buildNavItem(context, 'Search Recipes', '/search',
                          currentRoute == '/search'),
                      OutlinedButton(
                        onPressed: () async {
                          // Clear shared preferences
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();

                          // Navigate to LandingScreen
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LandingScreen()),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          foregroundColor: const Color(0xFFDC945F),
                        ),
                        child: Text(
                          'Sign Up',
                          
                        ),
                      ),
                    ],
                  ),
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
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
      child: TextButton(
        key: Key('$title'),
        onPressed: () {
          if (!isSelected && onChange != null) {
            onChange!(route);
          }
        },
        child: Container(
          padding: EdgeInsets.only(bottom: 2.0),
          decoration: isSelected
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: activeColor,
                      width: 2.0,
                    ),
                  ),
                )
              : null,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? activeColor : textColor,
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120);
}


class ExpandableNavbar extends StatefulWidget implements PreferredSizeWidget {
  final String currentRoute;
  final Function(String)? onChange;
  final bool isGuest; // Add the guest flag here to manage guest logic

  const ExpandableNavbar({required this.currentRoute, this.onChange, this.isGuest = false});

  @override
  _ExpandableNavbarState createState() => _ExpandableNavbarState();

  @override
  Size get preferredSize => Size.fromHeight(120);
}

class _ExpandableNavbarState extends State<ExpandableNavbar> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    if (mounted) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double expandedWidth = screenWidth * 0.2; // Adjust the width as needed
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;

    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: screenHeight * 0.1,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  isLightTheme ? 'assets/logo_1.png' : 'assets/logo_2.png',
                  height: screenHeight * 0.1,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: _toggleExpanded,
                ),
              ),
            ],
          ),
        ),
        if (_isExpanded)
          Align(
            alignment: FractionalOffset.topRight,
            child: Container(
              height: screenHeight,
              width: expandedWidth,
              color: const Color.fromARGB(143, 2, 20, 14),
              child: Column(
                children: [
                  ListTile(
                    key: const Key('Home'),
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      if (widget.onChange != null) {
                        widget.onChange!('/');
                      }
                      _toggleExpanded();
                    },
                  ),
                  ListTile(
                    key: const Key('SearchRecipe'),
                    leading: const Icon(Icons.search),
                    title: const Text('Search Recipes'),
                    onTap: () {
                      if (widget.onChange != null) {
                        widget.onChange!('/search');
                      }
                      _toggleExpanded();
                    },
                  ),
                  ],
              ),
            ),
          ),
      ],
    );
  }
}

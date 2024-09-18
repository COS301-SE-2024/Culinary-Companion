import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './theme_notifier.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final Function(String)? onChange;

  const Navbar({required this.currentRoute, this.onChange});

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
                      _buildNavItem(context, 'Add Recipe', '/scan-recipe',
                          currentRoute == '/scan-recipe'),
                      _buildNavItem(context, 'Inventory', '/inventory-screen',
                          currentRoute == '/inventory-screen'),
                      _buildNavItem(context, 'Meal Planner', '/meal-planner',
                          currentRoute == '/meal-planner'),
                      _buildNavItem(context, 'Favorite Recipes',
                          '/saved-recipes', currentRoute == '/saved-recipes'),
                      _buildNavItem(context, 'Profile', '/profile',
                          currentRoute == '/profile'),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(isLightTheme ? Icons.dark_mode : Icons.light_mode),
                onPressed: () {
                  Provider.of<ThemeNotifier>(context, listen: false)
                      .toggleTheme();
                },
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
    // final fontSize =
    //     screenWidth * 0.03; // Adjust the font size based on screen width
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.light
        ? Color(0xFF1E1E1E)
        : Color(0xFFD9D9D9);
    final activeColor = Color(0xFFDC945F);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.005), // Reduce horizontal padding
      child: TextButton(
        key: Key('$title'),
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
  Size get preferredSize => Size.fromHeight(120);
}

class ExpandableNavbar extends StatefulWidget implements PreferredSizeWidget {
  final String currentRoute;
  final Function(String)? onChange;

  const ExpandableNavbar({required this.currentRoute, this.onChange});

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
    double expandedWidth = screenWidth * 0.2; // 20% of screen width
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;

    // Define the icon colors for light and dark modes
    Color iconColor = isLightTheme ? const Color(0xFF283330) : Color(0xFFEDEDED);

    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: screenHeight * 0.1,
          backgroundColor: Colors.transparent, // Make AppBar transparent
          elevation: 0, // Remove AppBar shadow
          title: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  isLightTheme ? 'assets/logo_1.png' : 'assets/logo_2.png',
                  height: screenHeight * 0.07,
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
              height: screenHeight, // Take up the full height of the screen
              width: expandedWidth, // Take up 20% of the screen width
              color: isLightTheme? Color.fromARGB(193, 237, 237, 237) : Color.fromARGB(159, 2, 20, 14) ,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isCompact = screenWidth <
                      760; // Check if screen width is less than 760

                  return Column(
                    children: [
                      ListTile(
                        key: Key('Home'),
                        leading: Icon(Icons.home, color: iconColor,),
                        title: isCompact
                            ? null
                            : const Text('Home'), // Conditionally show title
                        onTap: () {
                          if (widget.onChange != null) {
                            widget.onChange!('/');
                          }
                          _toggleExpanded();
                        },
                      ),
                      ListTile(
                        key: ValueKey('SearchRecipe'),
                        leading: Icon(Icons.search, color: iconColor,),
                        title: isCompact
                            ? null
                            : const Text(
                                'Search Recipes'), // Conditionally show title
                        onTap: () {
                          if (widget.onChange != null) {
                            widget.onChange!('/search');
                          }
                          _toggleExpanded();
                        },
                      ),
                      ListTile(
                        key: ValueKey('AddRecipe'),
                        leading: Icon(Icons.add, color: iconColor,),
                        title: isCompact
                            ? null
                            : const Text(
                                'Add Recipe'), // Conditionally show title
                        onTap: () {
                          if (widget.onChange != null) {
                            widget.onChange!('/scan-recipe');
                          }
                          _toggleExpanded();
                        },
                      ),
                      ListTile(
                        key: Key('Inventory'),
                        leading: Icon(Icons.inventory, color: iconColor,),
                        title: isCompact
                            ? null
                            : const Text(
                                'Inventory'), // Conditionally show title
                        onTap: () {
                          if (widget.onChange != null) {
                            widget.onChange!('/inventory-screen');
                          }
                          _toggleExpanded();
                        },
                      ),
                      ListTile(
                        key: ValueKey('MealPlanner'),
                        leading: Icon(Icons.calendar_month_rounded, color: iconColor,),
                        title: isCompact
                            ? null
                            : const Text(
                                'Meal Planner'), // Conditionally show title
                        onTap: () {
                          if (widget.onChange != null) {
                            widget.onChange!('/meal-planner');
                          }
                          _toggleExpanded();
                        },
                      ),
                      ListTile(
                        key: ValueKey('Favourites'),
                        leading: Icon(Icons.favorite, color: iconColor,),
                        title: isCompact
                            ? null
                            : const Text(
                                'Favorite Recipes'), // Conditionally show title
                        onTap: () {
                          if (widget.onChange != null) {
                            widget.onChange!('/saved-recipes');
                          }
                          _toggleExpanded();
                        },
                      ),
                      ListTile(
                        key: ValueKey('Profile'),
                        leading: Icon(Icons.person, color: iconColor,),
                        title: isCompact
                            ? null
                            : const Text('Profile'), // Conditionally show title
                        onTap: () {
                          if (widget.onChange != null) {
                            widget.onChange!('/profile');
                          }
                          _toggleExpanded();
                        },
                      ),
                      const Divider(), // Divider to separate theme toggle from other items
                      ListTile(
                        key: const ValueKey('ThemeToggle'),
                        leading: Icon(
                            isLightTheme ? Icons.dark_mode : Icons.light_mode, color: iconColor,),
                        title: isCompact
                            ? null
                            : Text(isLightTheme ? 'Dark Mode' : 'Light Mode'),
                        onTap: () {
                          Provider.of<ThemeNotifier>(context, listen: false)
                              .toggleTheme();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final Function(String)? onChange;

  const Navbar({required this.currentRoute, this.onChange});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Culinary Companion',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.5),

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
    final bool isSelected = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0B3D36) : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!isSelected && onChange != null) {
                onChange!(route);
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color.fromARGB(255, 255, 255, 255),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20493C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Reduced padding to handle smaller screens
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Small screen layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(context),
                      const SizedBox(height: 20),
                      buildProfileInfo(),
                      const SizedBox(height: 20),
                      buildPreferences(),
                      const SizedBox(height: 20),
                      buildMyRecipes(),
                    ],
                  );
                } else {
                  // Large screen layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(context),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildProfileInfo(),
                          const SizedBox(width: 32),
                          Expanded(child: buildPreferences()), // Wrap preferences and dietary constraints in Expanded
                        ],
                      ),
                      const SizedBox(height: 20),
                      buildMyRecipes(),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileEditScreen(),
              ),
            );
          },
          icon: Icon(
            Icons.settings,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/pfp.jpg',
            width: 150, // Adjusted width to handle smaller screens
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Jane Doe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'jane.doe@gmail.com',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            // Handle sign out
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'Sign Out',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spice Level
        Text(
          'Spice Level',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            Chip(
              label: const Text('Mild'),
              backgroundColor: Colors.grey[700],
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Preferred Cuisine
        Text(
          'Preferred Cuisine',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            Chip(
              label: const Text('Mexican'),
              backgroundColor: Colors.grey[700],
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Dietary Constraints
        Text(
          'Dietary Constraints',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            Chip(
              label: const Text('Dairy'),
              backgroundColor: Colors.grey[700],
              labelStyle: const TextStyle(color: Colors.white),
            ),
            Chip(
              label: const Text('Vegan'),
              backgroundColor: Colors.grey[700],
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMyRecipes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Recipes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              recipeCard('assets/food1.jpeg'),
              recipeCard('assets/food2.jpeg'),
              recipeCard('assets/food3.jpeg'),
              recipeCard('assets/food8.jpg'),
              recipeCard('assets/food9.jpg'),
            ],
          ),
        ),
      ],
    );
  }

  Widget recipeCard(String imagePath) {
    return Container(
      width: 200, // Adjusted width to handle smaller screens
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

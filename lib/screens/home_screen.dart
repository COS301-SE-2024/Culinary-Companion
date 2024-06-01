import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('Categories',
            //     style: TextStyle(fontSize: 24, color: Colors.white)),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                _buildCategoryChip('Breakfast'),
                _buildCategoryChip('Lunch'),
                _buildCategoryChip('Dinner'),
                _buildCategoryChip('Pasta'),
                _buildCategoryChip('Seafood'),
                _buildCategoryChip('Pizza'),
                _buildCategoryChip('Soups'),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildRecipeCard('assets/food1.jpeg'),
                  _buildRecipeCard('assets/food2.jpeg'),
                  _buildRecipeCard('assets/food3.jpeg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white12,
      labelStyle: TextStyle(color: Colors.white),
    );
  }

  Widget _buildRecipeCard(String imagePath) {
    return Card(
      color: Colors.white10,
      child: Column(
        children: [
          Image.asset(imagePath,
              fit: BoxFit.cover, height: 150, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Recipe Name',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

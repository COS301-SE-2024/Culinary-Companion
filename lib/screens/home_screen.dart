import 'package:flutter/material.dart';
import '../widgets/recipe_card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recipes = [
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food1.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Grilled Salmon',
      'description':
          'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food2.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Chicken Soup',
      'description':
          'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food3.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food1.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Grilled Salmon',
      'description':
          'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food2.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Chicken Soup',
      'description':
          'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food3.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food1.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Grilled Salmon',
      'description':
          'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food2.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Chicken Soup',
      'description':
          'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food3.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food1.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Grilled Salmon',
      'description':
          'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food2.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Chicken Soup',
      'description':
          'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food3.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food1.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Grilled Salmon',
      'description':
          'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food2.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Chicken Soup',
      'description':
          'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food3.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food1.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Grilled Salmon',
      'description':
          'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food2.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    {
      'name': 'Chicken Soup',
      'description':
          'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food3.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
    
    // Additional recipes...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
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
              ),
              SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  double itemWidth = 276;
                  double itemHeight = 320;
                  double aspectRatio = itemWidth / itemHeight;

                  // Calculate relative spacing based on screen width
                  double crossAxisSpacing = width * 0.01; // 5% of screen width
                  double mainAxisSpacing = width * 0.02; // 6% of screen width

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recipes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Set the number of columns to 3
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: aspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      return RecipeCard(
                        name: recipes[index]['name'],
                        description: recipes[index]['description'],
                        imagePath: recipes[index]['imagePath'],
                        prepTime: recipes[index]['prepTime'],
                        cookTime: recipes[index]['cookTime'],
                        cuisine: recipes[index]['cuisine'],
                        spiceLevel: recipes[index]['spiceLevel'],
                        course: recipes[index]['course'],
                        servings: recipes[index]['servings'],
                        keyWords: List<String>.from(recipes[index]['keyWords']),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Color(0xFF2A4940).withOpacity(0.7),
      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.transparent, // Change to desired border color
        ),
      ),
    );
  }
}

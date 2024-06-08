import 'package:flutter/material.dart';
import '../widgets/recipe_card.dart';

class SavedRecipesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recipes = [
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/spaghetti_carbonara.webp',
      'prepTime': 15,
      'cookTime': 20,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'Italian', 'dinner']
    },
    {
      'name': 'Chicken Curry',
      'description':
          'A flavorful and spicy chicken curry made with a blend of spices and coconut milk.',
      'imagePath': 'assets/chicken_curry.jpg',
      'prepTime': 20,
      'cookTime': 40,
      'cuisine': 'Indian',
      'spiceLevel': 5,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['chicken', 'spicy', 'Indian']
    },
    {
      'name': 'Beef Tacos',
      'description':
          'Delicious beef tacos with fresh vegetables and homemade taco seasoning.',
      'imagePath': 'assets/beef_tacos.jpg',
      'prepTime': 10,
      'cookTime': 15,
      'cuisine': 'Mexican',
      'spiceLevel': 3,
      'course': 'Main',
      'servings': 6,
      'keyWords': ['beef', 'Mexican', 'tacos']
    },
    {
      'name': 'Caesar Salad',
      'description':
          'Crisp romaine lettuce with Caesar dressing, croutons, and Parmesan cheese.',
      'imagePath': 'assets/caesar_salad.webp',
      'prepTime': 10,
      'cookTime': 0,
      'cuisine': 'American',
      'spiceLevel': 1,
      'course': 'Salad',
      'servings': 2,
      'keyWords': ['salad', 'Caesar', 'appetizer']
    },
    {
      'name': 'Sushi Rolls',
      'description':
          'Homemade sushi rolls with fresh fish, avocado, and sushi rice.',
      'imagePath': 'assets/sushi_rolls.jpg',
      'prepTime': 30,
      'cookTime': 10,
      'cuisine': 'Japanese',
      'spiceLevel': 2,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['sushi', 'Japanese', 'seafood']
    },
    {
      'name': 'Pancakes',
      'description':
          'Fluffy pancakes served with maple syrup and fresh berries.',
      'imagePath': 'assets/pancakes.jpg',
      'prepTime': 10,
      'cookTime': 15,
      'cuisine': 'American',
      'spiceLevel': 1,
      'course': 'Breakfast',
      'servings': 4,
      'keyWords': ['breakfast', 'pancakes', 'sweet']
    },
    {
      'name': 'Lemon Tart',
      'description':
          'A tangy lemon tart with a buttery crust and smooth lemon filling.',
      'imagePath': 'assets/lemon_tart.jpg',
      'prepTime': 20,
      'cookTime': 25,
      'cuisine': 'French',
      'spiceLevel': 1,
      'course': 'Dessert',
      'servings': 8,
      'keyWords': ['dessert', 'lemon', 'French']
    },
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/spaghetti_carbonara.webp',
      'prepTime': 15,
      'cookTime': 20,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'Italian', 'dinner']
    },
    {
      'name': 'Chicken Curry',
      'description':
          'A flavorful and spicy chicken curry made with a blend of spices and coconut milk.',
      'imagePath': 'assets/chicken_curry.jpg',
      'prepTime': 20,
      'cookTime': 40,
      'cuisine': 'Indian',
      'spiceLevel': 5,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['chicken', 'spicy', 'Indian']
    },
    {
      'name': 'Beef Tacos',
      'description':
          'Delicious beef tacos with fresh vegetables and homemade taco seasoning.',
      'imagePath': 'assets/beef_tacos.jpg',
      'prepTime': 10,
      'cookTime': 15,
      'cuisine': 'Mexican',
      'spiceLevel': 3,
      'course': 'Main',
      'servings': 6,
      'keyWords': ['beef', 'Mexican', 'tacos']
    },
    {
      'name': 'Caesar Salad',
      'description':
          'Crisp romaine lettuce with Caesar dressing, croutons, and Parmesan cheese.',
      'imagePath': 'assets/caesar_salad.webp',
      'prepTime': 10,
      'cookTime': 0,
      'cuisine': 'American',
      'spiceLevel': 1,
      'course': 'Salad',
      'servings': 2,
      'keyWords': ['salad', 'Caesar', 'appetizer']
    },
    {
      'name': 'Sushi Rolls',
      'description':
          'Homemade sushi rolls with fresh fish, avocado, and sushi rice.',
      'imagePath': 'assets/sushi_rolls.jpg',
      'prepTime': 30,
      'cookTime': 10,
      'cuisine': 'Japanese',
      'spiceLevel': 2,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['sushi', 'Japanese', 'seafood']
    },
    {
      'name': 'Pancakes',
      'description':
          'Fluffy pancakes served with maple syrup and fresh berries.',
      'imagePath': 'assets/pancakes.jpg',
      'prepTime': 10,
      'cookTime': 15,
      'cuisine': 'American',
      'spiceLevel': 1,
      'course': 'Breakfast',
      'servings': 4,
      'keyWords': ['breakfast', 'pancakes', 'sweet']
    },
    {
      'name': 'Lemon Tart',
      'description':
          'A tangy lemon tart with a buttery crust and smooth lemon filling.',
      'imagePath': 'assets/lemon_tart.jpg',
      'prepTime': 20,
      'cookTime': 25,
      'cuisine': 'French',
      'spiceLevel': 1,
      'course': 'Dessert',
      'servings': 8,
      'keyWords': ['dessert', 'lemon', 'French']
    },
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/spaghetti_carbonara.webp',
      'prepTime': 15,
      'cookTime': 20,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'Italian', 'dinner']
    },
    {
      'name': 'Chicken Curry',
      'description':
          'A flavorful and spicy chicken curry made with a blend of spices and coconut milk.',
      'imagePath': 'assets/chicken_curry.jpg',
      'prepTime': 20,
      'cookTime': 40,
      'cuisine': 'Indian',
      'spiceLevel': 5,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['chicken', 'spicy', 'Indian']
    },
    {
      'name': 'Beef Tacos',
      'description':
          'Delicious beef tacos with fresh vegetables and homemade taco seasoning.',
      'imagePath': 'assets/beef_tacos.jpg',
      'prepTime': 10,
      'cookTime': 15,
      'cuisine': 'Mexican',
      'spiceLevel': 3,
      'course': 'Main',
      'servings': 6,
      'keyWords': ['beef', 'Mexican', 'tacos']
    },
    {
      'name': 'Caesar Salad',
      'description':
          'Crisp romaine lettuce with Caesar dressing, croutons, and Parmesan cheese.',
      'imagePath': 'assets/caesar_salad.webp',
      'prepTime': 10,
      'cookTime': 0,
      'cuisine': 'American',
      'spiceLevel': 1,
      'course': 'Salad',
      'servings': 2,
      'keyWords': ['salad', 'Caesar', 'appetizer']
    },
    {
      'name': 'Sushi Rolls',
      'description':
          'Homemade sushi rolls with fresh fish, avocado, and sushi rice.',
      'imagePath': 'assets/sushi_rolls.jpg',
      'prepTime': 30,
      'cookTime': 10,
      'cuisine': 'Japanese',
      'spiceLevel': 2,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['sushi', 'Japanese', 'seafood']
    },
    {
      'name': 'Pancakes',
      'description':
          'Fluffy pancakes served with maple syrup and fresh berries.',
      'imagePath': 'assets/pancakes.jpg',
      'prepTime': 10,
      'cookTime': 15,
      'cuisine': 'American',
      'spiceLevel': 1,
      'course': 'Breakfast',
      'servings': 4,
      'keyWords': ['breakfast', 'pancakes', 'sweet']
    },
    {
      'name': 'Lemon Tart',
      'description':
          'A tangy lemon tart with a buttery crust and smooth lemon filling.',
      'imagePath': 'assets/lemon_tart.jpg',
      'prepTime': 20,
      'cookTime': 25,
      'cuisine': 'French',
      'spiceLevel': 1,
      'course': 'Dessert',
      'servings': 8,
      'keyWords': ['dessert', 'lemon', 'French']
    },
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/spaghetti_carbonara.webp',
      'prepTime': 15,
      'cookTime': 20,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'Italian', 'dinner']
    },
    {
      'name': 'Chicken Curry',
      'description':
          'A flavorful and spicy chicken curry made with a blend of spices and coconut milk.',
      'imagePath': 'assets/chicken_curry.jpg',
      'prepTime': 20,
      'cookTime': 40,
      'cuisine': 'Indian',
      'spiceLevel': 5,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['chicken', 'spicy', 'Indian']
    },
    {
      'name': 'Beef Tacos',
      'description':
          'Delicious beef tacos with fresh vegetables and homemade taco seasoning.',
      'imagePath': 'assets/beef_tacos.jpg',
      'prepTime': 10,
      'cookTime': 15,
      'cuisine': 'Mexican',
      'spiceLevel': 3,
      'course': 'Main',
      'servings': 6,
      'keyWords': ['beef', 'Mexican', 'tacos']
    },
    {
      'name': 'Caesar Salad',
      'description':
          'Crisp romaine lettuce with Caesar dressing, croutons, and Parmesan cheese.',
      'imagePath': 'assets/caesar_salad.webp',
      'prepTime': 10,
      'cookTime': 0,
      'cuisine': 'American',
      'spiceLevel': 1,
      'course': 'Salad',
      'servings': 2,
      'keyWords': ['salad', 'Caesar', 'appetizer']
    },
    {
      'name': 'Sushi Rolls',
      'description':
          'Homemade sushi rolls with fresh fish, avocado, and sushi rice.',
      'imagePath': 'assets/sushi_rolls.jpg',
      'prepTime': 30,
      'cookTime': 10,
      'cuisine': 'Japanese',
      'spiceLevel': 2,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['sushi', 'Japanese', 'seafood']
    },
    {
      'name': 'Pancakes',
      'description':
          'Fluffy pancakes served with maple syrup and fresh berries.',
      'imagePath': 'assets/pancakes.jpg',
      'prepTime': 10,
      'cookTime': 15,
      'cuisine': 'American',
      'spiceLevel': 1,
      'course': 'Breakfast',
      'servings': 4,
      'keyWords': ['breakfast', 'pancakes', 'sweet']
    },
    {
      'name': 'Lemon Tart',
      'description':
          'A tangy lemon tart with a buttery crust and smooth lemon filling.',
      'imagePath': 'assets/lemon_tart.jpg',
      'prepTime': 20,
      'cookTime': 25,
      'cuisine': 'French',
      'spiceLevel': 1,
      'course': 'Dessert',
      'servings': 8,
      'keyWords': ['dessert', 'lemon', 'French']
    },
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/spaghetti_carbonara.webp',
      'prepTime': 15,
      'cookTime': 20,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'Italian', 'dinner']
    },
    {
      'name': 'Chicken Curry',
      'description':
          'A flavorful and spicy chicken curry made with a blend of spices and coconut milk.',
      'imagePath': 'assets/chicken_curry.jpg',
      'prepTime': 20,
      'cookTime': 40,
      'cuisine': 'Indian',
      'spiceLevel': 5,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['chicken', 'spicy', 'Indian']
    },
    {
      'name': 'Beef Tacos',
      'description':
          'Delicious beef tacos with fresh vegetables and homemade taco seasoning.',
      'imagePath': 'assets/beef_tacos.jpg',
      'prepTime': 10,
      'cookTime': 15,
      'cuisine': 'Mexican',
      'spiceLevel': 3,
      'course': 'Main',
      'servings': 6,
      'keyWords': ['beef', 'Mexican', 'tacos']
    },
    {
      'name': 'Caesar Salad',
      'description':
          'Crisp romaine lettuce with Caesar dressing, croutons, and Parmesan cheese.',
      'imagePath': 'assets/caesar_salad.webp',
      'prepTime': 10,
      'cookTime': 0,
      'cuisine': 'American',
      'spiceLevel': 1,
      'course': 'Salad',
      'servings': 2,
      'keyWords': ['salad', 'Caesar', 'appetizer']
    },
    {
      'name': 'Sushi Rolls',
      'description':
          'Homemade sushi rolls with fresh fish, avocado, and sushi rice.',
      'imagePath': 'assets/sushi_rolls.jpg',
      'prepTime': 30,
      'cookTime': 10,
      'cuisine': 'Japanese',
      'spiceLevel': 2,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['sushi', 'Japanese', 'seafood']
    },
    {
      'name': 'Pancakes',
      'description':
          'Fluffy pancakes served with maple syrup and fresh berries.',
      'imagePath': 'assets/pancakes.jpg',
      'prepTime': 10,
      'cookTime': 15,
      'cuisine': 'American',
      'spiceLevel': 1,
      'course': 'Breakfast',
      'servings': 4,
      'keyWords': ['breakfast', 'pancakes', 'sweet']
    },
    {
      'name': 'Lemon Tart',
      'description':
          'A tangy lemon tart with a buttery crust and smooth lemon filling.',
      'imagePath': 'assets/lemon_tart.jpg',
      'prepTime': 20,
      'cookTime': 25,
      'cuisine': 'French',
      'spiceLevel': 1,
      'course': 'Dessert',
      'servings': 8,
      'keyWords': ['dessert', 'lemon', 'French']
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
                        steps: List<String>.from(recipes[index]['steps']),
                        appliances: List<String>.from(recipes[index]['appliances']),
                        ingredients: List<Map<String, dynamic>>.from(recipes[index]['ingredients']),
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
}

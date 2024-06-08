import 'package:flutter/material.dart';
import '../widgets/recipe_card.dart';

class SavedRecipesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<RecipeCard> recipes = [
      RecipeCard(
        name: 'Spaghetti Carbonara',
        description: 'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
        imagePath: 'assets/spaghetti_carbonara.webp',
        prepTime: 15,
        cookTime: 20,
        cuisine: 'Italian',
        spiceLevel: 1,
        course: 'Main',
        servings: 4,
        keyWords: ['pasta', 'Italian', 'dinner'],
      ),
      RecipeCard(
        name: 'Chicken Curry',
        description: 'A flavorful and spicy chicken curry made with a blend of spices and coconut milk.',
        imagePath: 'assets/chicken_curry.jpg',
        prepTime: 20,
        cookTime: 40,
        cuisine: 'Indian',
        spiceLevel: 5,
        course: 'Main',
        servings: 4,
        keyWords: ['chicken', 'spicy', 'Indian'],
      ),
      RecipeCard(
        name: 'Beef Tacos',
        description: 'Delicious beef tacos with fresh vegetables and homemade taco seasoning.',
        imagePath: 'assets/beef_tacos.jpg',
        prepTime: 10,
        cookTime: 15,
        cuisine: 'Mexican',
        spiceLevel: 3,
        course: 'Main',
        servings: 6,
        keyWords: ['beef', 'Mexican', 'tacos'],
      ),
      RecipeCard(
        name: 'Caesar Salad',
        description: 'Crisp romaine lettuce with Caesar dressing, croutons, and Parmesan cheese.',
        imagePath: 'assets/caesar_salad.webp',
        prepTime: 10,
        cookTime: 0,
        cuisine: 'American',
        spiceLevel: 1,
        course: 'Salad',
        servings: 2,
        keyWords: ['salad', 'Caesar', 'appetizer'],
      ),
      RecipeCard(
        name: 'Sushi Rolls',
        description: 'Homemade sushi rolls with fresh fish, avocado, and sushi rice.',
        imagePath: 'assets/sushi_rolls.jpg',
        prepTime: 30,
        cookTime: 10,
        cuisine: 'Japanese',
        spiceLevel: 2,
        course: 'Main',
        servings: 4,
        keyWords: ['sushi', 'Japanese', 'seafood'],
      ),
      RecipeCard(
        name: 'Pancakes',
        description: 'Fluffy pancakes served with maple syrup and fresh berries.',
        imagePath: 'assets/pancakes.jpg',
        prepTime: 10,
        cookTime: 15,
        cuisine: 'American',
        spiceLevel: 1,
        course: 'Breakfast',
        servings: 4,
        keyWords: ['breakfast', 'pancakes', 'sweet'],
      ),
      RecipeCard(
        name: 'Lemon Tart',
        description: 'A tangy lemon tart with a buttery crust and smooth lemon filling.',
        imagePath: 'assets/lemon_tart.jpg',
        prepTime: 20,
        cookTime: 25,
        cuisine: 'French',
        spiceLevel: 1,
        course: 'Dessert',
        servings: 8,
        keyWords: ['dessert', 'lemon', 'French'],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Recipes'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: recipes[index],
          );
        },
      ),
    );
  }
}

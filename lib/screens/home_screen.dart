import 'package:flutter/material.dart';
import 'dart:async'; // Import the async library for Timer

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recipes = [
    {
      'name': 'Spaghetti Carbonara',
      'description': 'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food7.jpeg',
      'steps': [
        'Boil pasta in salted water.',
        'Cook pancetta in a pan.',
        'Mix eggs and cheese.',
        'Combine all with pepper.'
      ],
    },
    {
      'name': 'Grilled Salmon',
      'description': 'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food6.jpeg',
      'steps': [
        'Season the salmon.',
        'Preheat the grill.',
        'Grill salmon fillets.',
        'Serve with lemon.'
      ],
    },
    {
      'name': 'Chicken Soup',
      'description': 'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food5.webp',
      'steps': [
        'Cook chicken until done.',
        'Add vegetables and broth.',
        'Simmer until vegetables are tender.',
        'Season and serve.'
      ],
    },
    {
      'name': 'Margherita Pizza',
      'description': 'A traditional Italian pizza topped with fresh tomatoes, mozzarella cheese, and basil.',
      'imagePath': 'assets/food4.cms',
      'steps': [
        'Prepare the dough.',
        'Add tomato sauce and toppings.',
        'Bake in a hot oven.',
        'Garnish with basil.'
      ],
    },
    {
      'name': 'Grilled Salmon',
      'description': 'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food6.jpeg',
      'steps': [
        'Season the salmon.',
        'Preheat the grill.',
        'Grill salmon fillets.',
        'Serve with lemon.'
      ],
    },
    {
      'name': 'Chicken Soup',
      'description': 'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food5.webp',
      'steps': [
        'Cook chicken until done.',
        'Add vegetables and broth.',
        'Simmer until vegetables are tender.',
        'Season and serve.'
      ],
    },
    {
      'name': 'Margherita Pizza',
      'description': 'A traditional Italian pizza topped with fresh tomatoes, mozzarella cheese, and basil.',
      'imagePath': 'assets/food4.cms',
      'steps': [
        'Prepare the dough.',
        'Add tomato sauce and toppings.',
        'Bake in a hot oven.',
        'Garnish with basil.'
      ],
    },
        {
      'name': 'Spaghetti Carbonara',
      'description': 'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food7.jpeg',
      'steps': [
        'Boil pasta in salted water.',
        'Cook pancetta in a pan.',
        'Mix eggs and cheese.',
        'Combine all with pepper.'
      ],
    },
    {
      'name': 'Grilled Salmon',
      'description': 'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food6.jpeg',
      'steps': [
        'Season the salmon.',
        'Preheat the grill.',
        'Grill salmon fillets.',
        'Serve with lemon.'
      ],
    },
    {
      'name': 'Chicken Soup',
      'description': 'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food5.webp',
      'steps': [
        'Cook chicken until done.',
        'Add vegetables and broth.',
        'Simmer until vegetables are tender.',
        'Season and serve.'
      ],
    },
    {
      'name': 'Margherita Pizza',
      'description': 'A traditional Italian pizza topped with fresh tomatoes, mozzarella cheese, and basil.',
      'imagePath': 'assets/food4.cms',
      'steps': [
        'Prepare the dough.',
        'Add tomato sauce and toppings.',
        'Bake in a hot oven.',
        'Garnish with basil.'
      ],
    },
    {
      'name': 'Grilled Salmon',
      'description': 'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food6.jpeg',
      'steps': [
        'Season the salmon.',
        'Preheat the grill.',
        'Grill salmon fillets.',
        'Serve with lemon.'
      ],
    },
    {
      'name': 'Chicken Soup',
      'description': 'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food5.webp',
      'steps': [
        'Cook chicken until done.',
        'Add vegetables and broth.',
        'Simmer until vegetables are tender.',
        'Season and serve.'
      ],
    },
    {
      'name': 'Margherita Pizza',
      'description': 'A traditional Italian pizza topped with fresh tomatoes, mozzarella cheese, and basil.',
      'imagePath': 'assets/food4.cms',
      'steps': [
        'Prepare the dough.',
        'Add tomato sauce and toppings.',
        'Bake in a hot oven.',
        'Garnish with basil.'
      ],
    },
        {
      'name': 'Spaghetti Carbonara',
      'description': 'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food7.jpeg',
      'steps': [
        'Boil pasta in salted water.',
        'Cook pancetta in a pan.',
        'Mix eggs and cheese.',
        'Combine all with pepper.'
      ],
    },
    {
      'name': 'Chicken Soup',
      'description': 'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food5.webp',
      'steps': [
        'Cook chicken until done.',
        'Add vegetables and broth.',
        'Simmer until vegetables are tender.',
        'Season and serve.'
      ],
    },
    {
      'name': 'Margherita Pizza',
      'description': 'A traditional Italian pizza topped with fresh tomatoes, mozzarella cheese, and basil.',
      'imagePath': 'assets/food4.cms',
      'steps': [
        'Prepare the dough.',
        'Add tomato sauce and toppings.',
        'Bake in a hot oven.',
        'Garnish with basil.'
      ],
    },
        {
      'name': 'Spaghetti Carbonara',
      'description': 'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food7.jpeg',
      'steps': [
        'Boil pasta in salted water.',
        'Cook pancetta in a pan.',
        'Mix eggs and cheese.',
        'Combine all with pepper.'
      ],
    },
    {
      'name': 'Grilled Salmon',
      'description': 'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food6.jpeg',
      'steps': [
        'Season the salmon.',
        'Preheat the grill.',
        'Grill salmon fillets.',
        'Serve with lemon.'
      ],
    },
    {
      'name': 'Chicken Soup',
      'description': 'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food5.webp',
      'steps': [
        'Cook chicken until done.',
        'Add vegetables and broth.',
        'Simmer until vegetables are tender.',
        'Season and serve.'
      ],
    },
        {
      'name': 'Spaghetti Carbonara',
      'description': 'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'assets/food7.jpeg',
      'steps': [
        'Boil pasta in salted water.',
        'Cook pancetta in a pan.',
        'Mix eggs and cheese.',
        'Combine all with pepper.'
      ],
    },
    {
      'name': 'Grilled Salmon',
      'description': 'A simple and delicious recipe for perfectly grilled salmon fillets.',
      'imagePath': 'assets/food6.jpeg',
      'steps': [
        'Season the salmon.',
        'Preheat the grill.',
        'Grill salmon fillets.',
        'Serve with lemon.'
      ],
    },
    {
      'name': 'Chicken Soup',
      'description': 'A hearty and comforting chicken soup made with vegetables and tender chicken pieces.',
      'imagePath': 'assets/food5.webp',
      'steps': [
        'Cook chicken until done.',
        'Add vegetables and broth.',
        'Simmer until vegetables are tender.',
        'Season and serve.'
      ],
    },
    {
      'name': 'Margherita Pizza',
      'description': 'A traditional Italian pizza topped with fresh tomatoes, mozzarella cheese, and basil.',
      'imagePath': 'assets/food4.cms',
      'steps': [
        'Prepare the dough.',
        'Add tomato sauce and toppings.',
        'Bake in a hot oven.',
        'Garnish with basil.'
      ],
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              child: GridView.builder(
                itemCount: recipes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  return _buildRecipeCard(recipes[index]);
                },
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
      backgroundColor: Colors.blue.shade100,
      labelStyle: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return RecipeCard(
      name: recipe['name']!,
      description: recipe['description']!,
      imagePath: recipe['imagePath']!,
      steps: List<String>.from(recipe['steps']!),
    );
  }
}

class RecipeCard extends StatefulWidget {
  final String name;
  final String description;
  final String imagePath;
  final List<String> steps;

  RecipeCard({required this.name, required this.description, required this.imagePath, required this.steps});

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _hovered = false;

  void _onHover(bool hovering) {
    setState(() {
      _hovered = hovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
            ),
          ),
          if (_hovered)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          if (_hovered)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Steps:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...widget.steps.map((step) => Text(
                          '- $step',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

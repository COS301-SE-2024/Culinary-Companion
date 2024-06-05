import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recipes = [
    {
      'name': 'Spaghetti Carbonara',
      'description':
          'A classic Italian pasta dish made with eggs, cheese, pancetta, and pepper.',
      'imagePath': 'food1.jpg',
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
      'imagePath': 'food2.jpg',
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
      'imagePath': 'food3.jpg',
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
      'imagePath': 'food1.jpg',
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
      'imagePath': 'food2.jpg',
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
      'imagePath': 'food3.jpg',
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
      'imagePath': 'food1.jpg',
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
      'imagePath': 'food2.jpg',
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
      'imagePath': 'food3.jpg',
      'prepTime': 10,
      'cookTime': 10,
      'cuisine': 'Italian',
      'spiceLevel': 1,
      'course': 'Main',
      'servings': 4,
      'keyWords': ['pasta', 'beef', 'tomato']
    },
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
                      crossAxisCount: 3, // Set the number of columns to 3
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: aspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      return _buildRecipeCard(recipes[index]);
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

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return RecipeCard(
      name: recipe['name'] ?? '',
      description: recipe['description'] ?? '',
      imagePath: recipe['imagePath'] ?? '',
      steps: List<String>.from(recipe['steps'] ?? []),
      prepTime: recipe['prepTime'] ?? 0,
      cookTime: recipe['cookTime'] ?? 0,
      cuisine: recipe['cuisine'] ?? '',
      spiceLevel: recipe['spiceLevel'] ?? 0,
      course: recipe['course'] ?? '',
      servings: recipe['servings'] ?? 0,
      keyWords: List<String>.from(recipe['keyWords'] ?? []),
    );
  }
}

class RecipeCard extends StatefulWidget {
  final String name;
  final String description;
  final String imagePath;
  final List<String> steps;
  final int prepTime;
  final int cookTime;
  final String cuisine;
  final int spiceLevel;
  final String course;
  final int servings;
  final List<String> keyWords;

  RecipeCard({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.steps,
    required this.prepTime,
    required this.cookTime,
    required this.cuisine,
    required this.spiceLevel,
    required this.course,
    required this.servings,
    required this.keyWords,
  });
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
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeTitle = screenWidth * 0.02;
    double fontSizeDescription = screenWidth * 0.01;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_hovered)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 103, 128, 96).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
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
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeDescription,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prep Time:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSizeDescription,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${widget.prepTime} mins',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSizeDescription,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10), // Add spacing between elements
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cook Time:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSizeDescription,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${widget.cookTime} mins',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSizeDescription,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10), // Add spacing between elements
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Time:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSizeDescription,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${widget.prepTime + widget.cookTime} mins',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSizeDescription,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Cuisine: ${widget.cuisine}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeDescription,
                      ),
                    ),
                    Text(
                      'Spice Level: ${widget.spiceLevel}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeDescription,
                      ),
                    ),
                    Text(
                      'Course: ${widget.course}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeDescription,
                      ),
                    ),
                    Text(
                      'Servings: ${widget.servings}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeDescription,
                      ),
                    ),
                    Text(
                      'Keywords: ${widget.keyWords}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSizeDescription,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

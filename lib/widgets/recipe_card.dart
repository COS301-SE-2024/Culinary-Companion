import 'package:flutter/material.dart';

class RecipeCard extends StatefulWidget {
  final String name;
  final String description;
  final String imagePath;
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
              child: Image.network(
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
                      'Keywords: ${widget.keyWords.join(', ')}',
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

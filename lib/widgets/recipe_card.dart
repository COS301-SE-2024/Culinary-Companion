import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecipeCard extends StatefulWidget {
  final String recipeID;
  final String name;
  final String description;
  final String imagePath;
  final int prepTime;
  final int cookTime;
  final String cuisine;
  final int spiceLevel;
  final String course;
  final int servings;
  final List<String> steps;
  final List<String> appliances;
  final List<Map<String, dynamic>> ingredients;

  RecipeCard({
    required this.recipeID,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.prepTime,
    required this.cookTime,
    required this.cuisine,
    required this.spiceLevel,
    required this.course,
    required this.servings,
    required this.steps,
    required this.appliances,
    required this.ingredients,
  });

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _hovered = false;
  Map<int, bool> _ingredientChecked = {};
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  void _onHover(bool hovering) {
    setState(() {
      _hovered = hovering;
    });
  }

  void _checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final String recipeId = widget.recipeID;

    final url = Uri.parse(
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({"action": "getUserFavourites", "userId": userId});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final List<dynamic> favoriteRecipes = jsonDecode(response.body);
        final isFavorite =
            favoriteRecipes.any((recipe) => recipe['recipeid'] == recipeId);
        setState(() {
          _isFavorite = isFavorite;
        });
      } else {
        //print('Failed to get favorite status: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final String recipeId = widget.recipeID;
    final String action =
        _isFavorite ? "addUserFavorite" : "removeUserFavorite";

    final url = Uri.parse(
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "action": action,
      "userId": userId,
      "recipeid": recipeId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        //print('Favorite status updated');
      } else {
        //print('Failed to update favorite status: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _showRecipeDetails() {
    final theme = Theme.of(context);

    final clickColor = theme.brightness == Brightness.light
        ? Colors.white
        : Color.fromARGB(255, 25, 58, 48);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool showImage =
            screenWidth > 1359; // Adjust the threshold as needed

        return Dialog(
          backgroundColor: clickColor, // Change background color to green
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.01),
          ),
          child: Container(
            width: screenWidth * 0.6, // Set width to 60% of screen width
            height: MediaQuery.of(context).size.height *
                0.8, // Set height to 80% of screen height
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height *
                  0.04, // Adjust top padding to 4% of screen height
              left: screenWidth *
                  0.05, // Adjust left padding to 5% of screen width
              right: screenWidth *
                  0.05, // Adjust right padding to 5% of screen width
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: screenWidth *
                              0.02, // Adjust font size to 2% of screen width
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          iconSize: screenWidth *
                              0.02, // Adjust icon size to 2% of screen width
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.01), // Adjust height to 1% of screen height
                Expanded(
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.description),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01), // Adjust height to 1% of screen height
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Prep Time:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('${widget.prepTime} mins'),
                                    ],
                                  ),
                                  SizedBox(
                                      width: screenWidth *
                                          0.02), // 2% of screen width
                                  VerticalDivider(
                                    color: Colors
                                        .black, // Customize the color as needed
                                    thickness:
                                        1, // Customize the thickness as needed
                                    width: 1,
                                  ),
                                  SizedBox(
                                      width: screenWidth *
                                          0.02), // 2% of screen width
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Cook Time:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('${widget.cookTime} mins'),
                                    ],
                                  ),
                                  SizedBox(
                                      width: screenWidth *
                                          0.02), // 2% of screen width
                                  VerticalDivider(
                                    color: Colors
                                        .black, // Customize the color as needed
                                    thickness:
                                        1, // Customize the thickness as needed
                                    width: 1,
                                  ),
                                  SizedBox(
                                      width: screenWidth *
                                          0.02), // 2% of screen width
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Total Time:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          '${widget.prepTime + widget.cookTime} mins'),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01), // Adjust height to 1% of screen height
                              Text('Cuisine: ${widget.cuisine}'),
                              Text('Spice Level: ${widget.spiceLevel}'),
                              Text('Course: ${widget.course}'),
                              Text('Servings: ${widget.servings}'),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02), // Adjust height to 2% of screen height
                              Text('Ingredients:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01), // Adjust height to 1% of screen height
                              ...widget.ingredients
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int idx = entry.key;
                                Map<String, dynamic> ingredient = entry.value;
                                return CheckableItem(
                                  title:
                                      '${ingredient['quantity']} ${ingredient['measurementunit']} ${ingredient['name']}',
                                  isChecked: _ingredientChecked[idx] ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _ingredientChecked[idx] = value ?? false;
                                    });
                                  },
                                );
                              }),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02), // Adjust height to 2% of screen height
                              Text('Appliances:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01), // Adjust height to 1% of screen height
                              ...widget.appliances
                                  .map((appliance) => Text(appliance)),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02), // Adjust height to 2% of screen height
                              Text('Instructions:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01), // Adjust height to 1% of screen height
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    widget.steps.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  String step = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.01), // Add some spacing between steps
                                    child: Text('${index + 1}. $step'),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        if (showImage) ...[
                          SizedBox(
                              width: screenWidth *
                                  0.05), // 5% of screen width for spacing
                          Container(
                            width: screenWidth *
                                0.2, // 20% of screen width for the image
                            height: MediaQuery.of(context).size.height *
                                0.5, // 50% of screen height for the image
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(screenWidth *
                                  0.005), // 0.5% of screen width for rounded corners
                              image: DecorationImage(
                                image: NetworkImage(widget.imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeTitle = screenWidth * 0.02;
    double fontSizeDescription = screenWidth * 0.01;

    final hoverColor = theme.brightness == Brightness.light
        ? Color(0xFF202920).withOpacity(0.8)
        : Color.fromARGB(255, 103, 128, 96).withOpacity(0.8);

    return GestureDetector(
      onTap: _showRecipeDetails,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (_hovered)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: hoverColor,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          widget.description,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeDescription,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: _toggleFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckableItem extends StatefulWidget {
  final String title;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  CheckableItem({
    required this.title,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  _CheckableItemState createState() => _CheckableItemState();
}

class _CheckableItemState extends State<CheckableItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.isChecked,
          onChanged: widget.onChanged,
          activeColor: Color(0XFFDC945F),
          checkColor: Colors.white,
        ),
        Flexible(
          child: Text(
            widget.title,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

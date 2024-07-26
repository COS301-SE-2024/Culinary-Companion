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
  //Map<String, bool> _pantryIngredients = {};
  Map<String, Map<String, dynamic>> _pantryIngredients = {};
  Map<String, Map<String, dynamic>> _shoppingList = {};

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _fetchShoppingList();
    _fetchPantryIngredients();
  }

  void _fetchShoppingList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    // final url = Uri.parse(
    //     'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint');
    // final headers = {"Content-Type": "application/json"};
    // final body = jsonEncode({"action": "getShoppingList", "userId": userId});

    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'getShoppingList',
          'userId': userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> shoppingList = data['shoppingList'];
        setState(() {
          for (var item in shoppingList) {
            _shoppingList[item['ingredientName']] = {
              'quantity': item['quantity'],
              'measurementUnit': item['measurmentunit']
            };
          }
        });
      } else {
        print('Failed to fetch shopping list: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _fetchPantryIngredients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    final url = Uri.parse(
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint');
    final headers = {"Content-Type": "application/json"};
    final body =
        jsonEncode({"action": "getAvailableIngredients", "userId": userId});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> pantryIngredients = data['availableIngredients'];
        setState(() {
          for (var ingredient in pantryIngredients) {
            _pantryIngredients[ingredient['name']] = {
              'quantity': ingredient['quantity'],
              'measurementUnit': ingredient['measurmentunit']
            };
          }
        });
      } else {
        //print('Failed to fetch pantry ingredients: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
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
                            _fetchShoppingList(); // Refresh shopping list when dialog is closed
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
                                bool isInPantry = _pantryIngredients
                                    .containsKey(ingredient['name']);
                                double availableQuantity = isInPantry
                                    ? (_pantryIngredients[ingredient['name']]
                                            ?['quantity'] ??
                                        0.0)
                                    : 0.0;
                                bool isInShoppingList = _shoppingList
                                    .containsKey(ingredient['name']);

                                return CheckableItem(
                                  title:
                                      '${ingredient['name']} (${ingredient['quantity']} ${ingredient['measurement_unit']})',
                                  requiredQuantity: ingredient['quantity'],
                                  requiredUnit: ingredient['measurement_unit'],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _ingredientChecked[idx] = value ?? false;
                                    });
                                  },
                                  isInPantry: isInPantry,
                                  availableQuantity: availableQuantity,
                                  isChecked: _ingredientChecked[idx] ?? true,
                                  isInShoppingList: isInShoppingList,
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
                                children: widget.steps.expand((step) {
                                  return step
                                      .split('<')
                                      .map((subStep) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01,
                                            ),
                                            child: Text(
                                                '${widget.steps.indexOf(step) + 1}. $subStep'),
                                          ));
                                }).toList(),
                              ),
                            ],
//>>>>>>> dev
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
    ).then((_) {
      // This will be called when the dialog is dismissed
      _fetchShoppingList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeTitle = screenWidth * 0.015;
    double fontSizeDescription = screenWidth * 0.01;
    double fontSizeTimes = screenWidth * 0.008;

    final hoverColor = theme.brightness == Brightness.light
        ? Color(0xFF202920).withOpacity(0.8)
        : Color.fromARGB(15, 0, 0, 0).withOpacity(0.5);

    bool enableHover = screenWidth >= 1029;
    return GestureDetector(
      onTap: _showRecipeDetails,
      child: MouseRegion(
        onEnter: enableHover ? (_) => _onHover(true) : null,
        onExit: enableHover ? (_) => _onHover(false) : null,
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
            if (!_hovered)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(0, 0, 0, 0),
                          Color.fromARGB(179, 0, 0, 0),
                        ]),
                    //color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            if (!_hovered)
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  width: MediaQuery.of(context).size.width /
                      8, // Half the width of the recipe card
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeTitle,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.013,
                    right: MediaQuery.of(context).size.width * 0.013,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.013,
                        ),
                        child: Text(
                          widget.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeTitle,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.008,
                      ),
                      Flexible(
                        child: Text(
                          widget.description,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                            fontSize: fontSizeDescription,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.008,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.013,
                          bottom: MediaQuery.of(context).size.width * 0.01,
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Prep Time:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: fontSizeTimes,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.006,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.006,
                                          ),
                                          child: Text(
                                            '${widget.prepTime} mins',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: fontSizeTimes,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.008,
                                    ), // Add spacing between elements
                                    Container(
                                      height: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.03, // Set a fixed height for the vertical divider
                                      child: const VerticalDivider(
                                        width: 20,
                                        thickness: 1.8,
                                        indent: 20,
                                        endIndent: 0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.008,
                                    ), // Add spacing between elements
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cook Time:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: fontSizeTimes,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.006,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.006,
                                          ),
                                          child: Text(
                                            '${widget.cookTime} mins',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: fontSizeTimes,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.008,
                            ), // Add spacing between elements
                            Container(
                              height: MediaQuery.of(context).size.width *
                                  0.03, // Set a fixed height for the vertical divider
                              child: const VerticalDivider(
                                width: 20,
                                thickness: 1.8,
                                indent: 20,
                                endIndent: 0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.008,
                            ), // Add spacing between elements
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Time:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSizeTimes,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width * 0.006,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.006,
                                  ),
                                  child: Text(
                                    '${widget.prepTime + widget.cookTime} mins',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontSizeTimes,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Cuisine: ${widget.cuisine}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeDescription,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.006,
                      ),
                      Text(
                        'Spice Level: ${widget.spiceLevel}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeDescription,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.006,
                      ),
                      Text(
                        'Course: ${widget.course}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeDescription,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.006,
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
              top: MediaQuery.of(context).size.width * 0.01,
              right: MediaQuery.of(context).size.width * 0.01,
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                  size: MediaQuery.of(context).size.width * 0.017,
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

// ignore: must_be_immutable
class CheckableItem extends StatefulWidget {
  final String title;
  final double requiredQuantity;
  final String requiredUnit;
  final ValueChanged<bool?> onChanged;
  final bool isInPantry;
  final double availableQuantity;
  final bool isChecked;
  bool isInShoppingList;

  CheckableItem({
    required this.title,
    required this.requiredQuantity,
    required this.requiredUnit,
    required this.onChanged,
    required this.isInPantry,
    required this.availableQuantity,
    required this.isChecked,
    required this.isInShoppingList,
  });

  @override
  _CheckableItemState createState() => _CheckableItemState();
}

class _CheckableItemState extends State<CheckableItem> {
  bool _isAdded = false;

  @override
  Widget build(BuildContext context) {
    bool isSufficient = widget.isInPantry &&
        widget.availableQuantity >= widget.requiredQuantity;
    return Row(
      children: [
        if (isSufficient)
          Checkbox(
            value: widget.isChecked,
            onChanged: widget.onChanged,
            activeColor: Color(0XFFDC945F),
            checkColor: Colors.white,
          )
        else if (widget.isInShoppingList || _isAdded)
          TextButton(
            onPressed: null,
            child: Text('In Shopping List'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          )
        else
          TextButton(
            onPressed: () => _addToShoppingList(
              widget.title,
              widget.requiredQuantity - widget.availableQuantity,
              widget.requiredUnit,
            ),
            child: Text('Add rest to shopping list'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
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

  void _addToShoppingList(
      String ingredientString, double remainingQuantity, String unit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    // Regular expression to extract the ingredient name
    final regex = RegExp(r'^(.*?)\s*\(.*?\)$');
    final match = regex.firstMatch(ingredientString);
    final ingredientName =
        match != null ? match.group(1) ?? ingredientString : ingredientString;

    final url = Uri.parse(
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "action": "addToShoppingList",
      "userId": userId,
      "ingredientName": ingredientName,
      "quantity": remainingQuantity,
      "measurementUnit": unit
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        setState(() {
          _isAdded = true;
          _updateShoppingList(ingredientName, remainingQuantity, unit);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added remaining $ingredientName to shopping list'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to add $ingredientName to shopping list: ${response.body}'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error adding $ingredientName to shopping list: $error'),
        ),
      );
    }
  }

  void _updateShoppingList(
      String ingredientName, double quantity, String measurementUnit) {
    setState(() {
      widget.isInShoppingList = true;
    });
  }
}

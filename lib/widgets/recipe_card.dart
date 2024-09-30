// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'chat_widget.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../gemini_service.dart'; // LLM
import 'checkable_item.dart';
//import 'package:lottie/lottie.dart';
import 'package:culinary_companion/widgets/timer_popup.dart';

// ignore: must_be_immutable
class RecipeCard extends StatefulWidget {
  String recipeID;
  String name;
  String description;
  String imagePath;
  int prepTime;
  int cookTime;
  String cuisine;
  int spiceLevel;
  String course;
  int servings;
  List<String> steps;
  List<String> appliances;
  List<Map<String, dynamic>> ingredients;

  double? customBoxWidth;
  double? customFontSizeTitle;
  double? customIconSize;

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
    this.customBoxWidth,
    this.customFontSizeTitle,
    this.customIconSize,
  });

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _hovered = false;
  Map<int, bool> _ingredientChecked = {};
  bool _isFavorite = false;
  Map<String, Map<String, dynamic>> _pantryIngredients = {};
  Map<String, Map<String, dynamic>> _shoppingList = {};
  String? userId;
  int _ingredientsInPantry = 0;
  Map<String, dynamic>? _originalRecipe;
  bool _isAlteredRecipe = false;

  @override
  void initState() {
    super.initState();

    _originalRecipe = {
      'name': widget.name,
      'description': widget.description,
      'imagePath': widget.imagePath,
      'prepTime': widget.prepTime,
      'cookTime': widget.cookTime,
      'cuisine': widget.cuisine,
      'spiceLevel': widget.spiceLevel,
      'course': widget.course,
      'servings': widget.servings,
      'steps': widget.steps,
      'appliances': widget.appliances,
      'ingredients': widget.ingredients,
    };

    _checkIfFavorite();
    _fetchShoppingList();
    _fetchPantryIngredients();
    _fetchUserId();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userId = prefs.getString('userId');
      });
    }
  }

  void _showTimerPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimerPopup(); // This will be your timer widget
      },
    );
  }

  void _updateRecipe(Map<String, dynamic> alteredRecipe) {
    if (mounted) {
      setState(() {
        //print('Altered Recipe: $alteredRecipe');
        // print('Altered Ingredients: ${alteredRecipe['ingredients']}');

        widget.name = alteredRecipe['title'];
        //print('gets here 1');
        widget.description = alteredRecipe['description'];
        //print('gets here 2');
        widget.imagePath = widget.imagePath;
        //print('gets here 3');
        widget.prepTime = widget.prepTime;
        //print('gets here 4');
        widget.cookTime = widget.cookTime;
        // print('gets here 5');
        widget.cuisine = alteredRecipe['cuisine'];
        //print('gets here 6');
        widget.spiceLevel = widget.spiceLevel;
        //print('gets here 7');
        widget.course = widget.course;
        widget.servings = widget.servings;
        //print('gets here 9');
        widget.steps = List<String>.from(alteredRecipe['steps']);
        //print('gets here 10');
        widget.appliances = widget.appliances;
        //print('gets here 11');

        // map ingredients
        // widget.ingredients = alteredRecipe['ingredients']
        //     .map<Map<String, dynamic>>((ingredient) {
        //   //print('Ingredient: $ingredient');
        //   var nameEndIndex = ingredient.lastIndexOf(' (');
        //   var name = ingredient.substring(0, nameEndIndex);
        //   var quantityAndUnit = ingredient
        //       .substring(nameEndIndex + 2, ingredient.length - 1)
        //       .split(' ');
        //   return {
        //     'name': name,
        //     'quantity': double.tryParse(quantityAndUnit[0]) ?? 0.0,
        //     'measurement_unit': quantityAndUnit[1],
        //   };
        // }).toList();

        widget.ingredients = alteredRecipe['ingredients']
            .map<Map<String, dynamic>>((ingredient) {
          return {
            'name': ingredient['name'],
            'quantity':
                double.tryParse(ingredient['quantity'].toString()) ?? 0.0,
            'measurement_unit': ingredient['unit'],
          };
        }).toList();

        //print('Parsed Ingredients: ${widget.ingredients}');
        //print('gets here 12');
        _isAlteredRecipe = true;
      });
      Navigator.of(context).pop();
      if (_isMobileView()) {
        _showMobileRecipeDetails();
      } else {
        _showRecipeDetails();
      }
      //_showRecipeDetails();
    }
  }

  bool _isMobileView() {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth <
        768; // Adjust the threshold for mobile view, 768px is a common breakpoint
  }

  void _revertToOriginalRecipe() {
    if (_originalRecipe != null) {
      if (mounted) {
        setState(() {
          widget.name = _originalRecipe!['name'];
          widget.description = _originalRecipe!['description'];
          widget.imagePath = _originalRecipe!['imagePath'];
          widget.prepTime = _originalRecipe!['prepTime'];
          widget.cookTime = _originalRecipe!['cookTime'];
          widget.cuisine = _originalRecipe!['cuisine'];
          widget.spiceLevel = _originalRecipe!['spiceLevel'];
          widget.course = _originalRecipe!['course'];
          widget.servings = _originalRecipe!['servings'];
          widget.steps = List<String>.from(_originalRecipe!['steps']);
          widget.appliances = List<String>.from(_originalRecipe!['appliances']);
          widget.ingredients =
              List<Map<String, dynamic>>.from(_originalRecipe!['ingredients']);
          _isAlteredRecipe = false;
          //_showRecipeDetails();
        });
      }
    }
  }

  void _updateIngredientCounts() {
    int inPantry = 0;
    //int needed = 0;

    for (var ingredient in widget.ingredients) {
      String name = ingredient['name'];
      double requiredQuantity = ingredient['quantity'];

      if (_pantryIngredients.containsKey(name)) {
        double availableQuantity = _pantryIngredients[name]!['quantity'];
        if (availableQuantity >= requiredQuantity) {
          inPantry++;
        } else {
          //needed++;
        }
      } else {
        //needed++;
      }
    }
    if (mounted) {
      setState(() {
        _ingredientsInPantry = inPantry;
        //_ingredientsNeeded = needed;
      });
    }
  }

  Future<void> _addAllToShoppingList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    for (var ingredient in widget.ingredients) {
      String name = ingredient['name'];
      double requiredQuantity = ingredient['quantity'];
      String unit = ingredient['measurement_unit'];

      if (_shoppingList.containsKey(name)) {
        continue; //skip add if the ingredient is already in the shopping list
      }

      if (_pantryIngredients.containsKey(name)) {
        double availableQuantity = _pantryIngredients[name]!['quantity'];
        if (availableQuantity < requiredQuantity) {
          double remainingQuantity = requiredQuantity - availableQuantity;

          final url = Uri.parse(
              'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint');
          final headers = {"Content-Type": "application/json"};
          final body = jsonEncode({
            "action": "addToShoppingList",
            "userId": userId,
            "ingredientName": name,
            "quantity": remainingQuantity,
            "measurementUnit": unit
          });

          try {
            final response = await http.post(url, headers: headers, body: body);
            if (response.statusCode == 200) {
              if (mounted) {
                setState(() {
                  _shoppingList[name] = {
                    'quantity': remainingQuantity,
                    'measurementUnit': unit
                  };

                  // ignore: duplicate_ignore
                  // ignore: avoid_function_literals_in_foreach_calls
                  widget.ingredients.forEach((ingredient) {
                    if (ingredient['name'] == name) {
                      widget.ingredients[widget.ingredients.indexOf(ingredient)]
                          ['isInShoppingList'] = true;
                    }
                  });
                });
              }
            } else {
              print('Failed to add $name to shopping list: ${response.body}');
            }
          } catch (error) {
            print('Error adding $name to shopping list: $error');
          }
        }
      } else {
        final url = Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint');
        final headers = {"Content-Type": "application/json"};
        final body = jsonEncode({
          "action": "addToShoppingList",
          "userId": userId,
          "ingredientName": name,
          "quantity": requiredQuantity,
          "measurementUnit": unit
        });

        try {
          final response = await http.post(url, headers: headers, body: body);
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                _shoppingList[name] = {
                  'quantity': requiredQuantity,
                  'measurementUnit': unit
                };
                //update state to show ingredients in the shopping list
                widget.ingredients.forEach((ingredient) {
                  if (ingredient['name'] == name) {
                    widget.ingredients[widget.ingredients.indexOf(ingredient)]
                        ['isInShoppingList'] = true;
                  }
                });
              });
            }
          } else {
            print('Failed to add $name to shopping list: ${response.body}');
          }
        } catch (error) {
          print('Error adding $name to shopping list: $error');
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added all needed ingredients to shopping list'),
      ),
    );
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
        if (mounted) {
          setState(() {
            for (var item in shoppingList) {
              _shoppingList[item['ingredientName']] = {
                'quantity': item['quantity'],
                'measurementUnit': item['measurmentunit']
              };
            }
          });
        }
      } else {
        print('Failed to fetch shopping list: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
    _updateIngredientCounts();
  }

  Future<void> _removeIngredientsFromPantry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    bool allIngredientsRemoved = true;

    for (var ingredient in widget.ingredients) {
      final String item = ingredient['name'];
      final double quantity = ingredient['quantity'];
      final String measurementUnit = ingredient['measurement_unit'];

      double currentQuantity = _pantryIngredients[item]!['quantity'];

      //calc new quantity
      double newQuantity = currentQuantity - quantity;

      //determine the action based on quantity
      String action =
          newQuantity <= 0 ? 'removeFromPantryList' : 'editPantryItem';
      double finalQuantity = newQuantity <= 0 ? 0 : newQuantity;

      try {
        final response = await http.post(
          Uri.parse(
              'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
          body: jsonEncode({
            'action': action,
            'userId': userId,
            'ingredientName': item,
            if (action == 'editPantryItem') 'quantity': finalQuantity,
            if (action == 'editPantryItem') 'measurementUnit': measurementUnit,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              if (newQuantity <= 0) {
                _pantryIngredients.remove(item);
              } else {
                _pantryIngredients[item]!['quantity'] = newQuantity;
              }
            });
          }
          print('Successfully updated $item in pantry');
        } else {
          allIngredientsRemoved = false;
          print('Failed to update $item in pantry: ${response.statusCode}');
        }
      } catch (error) {
        allIngredientsRemoved = false;
        print('Error updating $item in pantry: $error');
      }
    }

    if (allIngredientsRemoved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ingredients from pantry'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove some ingredients from pantry'),
          duration: Duration(seconds: 2),
        ),
      );
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
        if (mounted) {
          setState(() {
            for (var ingredient in pantryIngredients) {
              _pantryIngredients[ingredient['name']] = {
                'quantity': ingredient['quantity'],
                'measurementUnit': ingredient['measurmentunit']
              };
            }
          });
        }
      } else {
        //print('Failed to fetch pantry ingredients: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
    _updateIngredientCounts();
  }

  void _onHover(bool hovering) {
    if (mounted) {
      setState(() {
        _hovered = hovering;
      });
    }
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
        if (mounted) {
          setState(() {
            _isFavorite = isFavorite;
          });
        }
      } else {
        //print('Failed to get favorite status: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _toggleFavorite() async {
    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }

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

  void _showMobileRecipeDetails() {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool localfav = _isFavorite;

    double imageHeight = screenHeight *
        0.5; // 50% of screen height for the image// 50% of screen height for the content

    double fontSizeTitle = screenWidth * 0.05;

    final textColor =
        theme.brightness == Brightness.light ? Color(0xFF283330) : Colors.white;
    int selectedTab = 0;

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(body: StatefulBuilder(
              builder: (BuildContext context, StateSetter dialogSetState) {
            return SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                      height:
                          imageHeight, // Define a specific height for the container
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height:
                                imageHeight, // 50% of dialog height for the image
                            child: ClipRRect(
                              // borderRadius: BorderRadius.vertical(
                              //     top: Radius.circular(20)),
                              child: Image.network(
                                widget
                                    .imagePath, // Replace with your background image path
                                fit: BoxFit.cover, // Adjust fit as necessary
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: imageHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.fromARGB(0, 0, 0, 0),
                                    Color.fromARGB(179, 0, 0, 0),
                                  ],
                                ),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20.0, // Adjust position as necessary
                            left: 10.0, // Adjust position as necessary
                            child: Container(
                              width: screenWidth *
                                  0.1, // Adjust width of the circular background
                              height: screenWidth *
                                  0.1, // Adjust height of the circular background
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(
                                    0.5), // Background color of the circle
                              ),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back,
                                      color: Colors.white),
                                  iconSize:
                                      screenWidth * 0.05, // Adjust icon size
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _fetchShoppingList(); // Refresh shopping list when dialog is closed
                                  },
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20.0, // Adjust position as necessary
                            right: 60.0, // Adjust position as necessary
                            child: Container(
                              width: screenWidth *
                                  0.1, // Adjust width of the circular background
                              height: screenWidth *
                                  0.1, // Adjust height of the circular background
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(
                                    0.5), // Background color of the circle
                              ),
                              child: Center(
                                  child: IconButton(
                                icon: Icon(Icons.timer, color: Colors.white),
                                iconSize: screenWidth * 0.05,
                                onPressed: _showTimerPopup,
                              )),
                            ),
                          ),
                          Positioned(
                              top: 20.0, // Adjust position as necessary
                              right: 10.0, // Adjust position as necessary
                              child: Container(
                                  width: screenWidth *
                                      0.1, // Adjust width of the circular background
                                  height: screenWidth *
                                      0.1, // Adjust height of the circular background
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(
                                        0.5), // Background color of the circle
                                  ),
                                  child: Center(
                                    child: IconButton(
                                        icon: Icon(
                                          localfav
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: localfav
                                              ? Colors.red
                                              : Colors.white,
                                          size: screenWidth > 800 ? 25 : 18,
                                        ),
                                        onPressed: () {
                                          _toggleFavorite(); // Call the favorite toggle logic

                                          // Update localfav and UI after toggling
                                          dialogSetState(() {
                                            localfav =
                                                !localfav; // Flip the localfav state
                                          });
                                        }),
                                    //],
                                  ))),
                          Positioned(
                            bottom:
                                10, // Adjust position to be at the bottom of the image
                            left: 20.0,
                            child: Text(
                              widget.name,
                              style: TextStyle(
                                fontSize: fontSizeTitle,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .white, // Ensure the text is visible on the image
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),

                  SizedBox(height: 6.0),
                  buildTabRow(
                    selectedTab,
                    textColor,
                    (int newTab) {
                      dialogSetState(() {
                        selectedTab = newTab;
                      });
                    },
                  ),
                  // Content section that changes based on the selected tab
                  if (selectedTab == 0)
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Description:",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFDC945F),
                                fontWeight: FontWeight
                                    .bold, // Optionally set the thickness of the underline
                              ),
                            ),
                            SizedBox(
                                height:
                                    6.0), // Add spacing between title and description
                            Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      16.0), // Adjust the left padding as needed
                              child: Text(
                                widget.description,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            buildTimeInfoRow(context, '${widget.prepTime}',
                                '${widget.cookTime}', textColor),
                            SizedBox(
                              height: 16.0,
                            ),
                            buildDetailsColumn(
                                context,
                                '${widget.cuisine}',
                                '${widget.spiceLevel}',
                                '${widget.course}',
                                '${widget.servings}'),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildActionButton(context, true),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                buildIngredientsList(context, dialogSetState),
                                // buildIngredientsSection(
                                //     context), // Adjust height to 2% of screen height
                                buildAppliancesSection(context),
                                SizedBox(height: 10),
                              ],
                              //                     ),
                            ),
                          ],
                        ))
                  else if (selectedTab == 1)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildInstructions(widget.steps),
                      ),
                    )
                  else if (selectedTab == 2)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: screenWidth,
                        height: MediaQuery.of(context).size.height,
                        child: ChatWidget(
                          recipeName: widget.name,
                          recipeDescription: widget.description,
                          ingredients: widget.ingredients,
                          steps: widget.steps,
                          userId: userId!,
                          course: widget.course,
                        ),
                      ),
                    ),
                ]));
          })),
        )).then((_) {
      // This will be called when the dialog is dismissed
      _fetchShoppingList();
    });
  }

  void _showRecipeDetails() {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color textColor =
        isLightTheme ? Color.fromARGB(255, 53, 53, 53) : Colors.white;

    bool localfav = _isFavorite;

    final theme = Theme.of(context);
    final iconColor = theme.brightness == Brightness.light
        ? Color.fromARGB(255, 49, 49, 49)
        : Colors.white;
    final double screenWidth = MediaQuery.of(context).size.width;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: StatefulBuilder(
              builder: (BuildContext context, StateSetter dialogSetState) {
            return Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.04,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: Column(
                children: [
                  // Top row with title and icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            widget.name,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: screenWidth > 800
                                  ? 25
                                  : 18, // Adjust font size based on screen width
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.timer_outlined,
                              color: iconColor,
                              size: screenWidth > 800
                                  ? 25
                                  : 18, // Adjust icon size based on screen width
                            ),
                            onPressed: _showTimerPopup,
                          ),
                          IconButton(
                              icon: Icon(
                                localfav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: localfav ? Colors.red : iconColor,
                                size: screenWidth > 800 ? 25 : 18,
                              ),
                              onPressed: () {
                                _toggleFavorite(); // Call the favorite toggle logic

                                // Update localfav and UI after toggling
                                dialogSetState(() {
                                  localfav =
                                      !localfav; // Flip the localfav state
                                });
                              }),
                          IconButton(
                            icon: Icon(Icons.close),
                            color: iconColor,
                            iconSize: screenWidth > 800
                                ? 25
                                : 18, // Adjust icon size based on screen width
                            onPressed: () {
                              Navigator.of(context).pop();
                              _fetchShoppingList(); // Refresh shopping list when dialog is closed
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 50),

                  // Row containing left and right columns with independent scroll
                  Expanded(
                    child: Row(
                      children: [
                        // Left Column (Image, Action Button, Ingredients, Appliances)
                        Flexible(
                          flex: MediaQuery.of(context).size.width < 700
                              ? 5
                              : MediaQuery.of(context).size.width < 900
                                  ? 4
                                  : 3,
                          // 30% of the width
                          child: Container(
                            padding:
                                EdgeInsets.all(16), // Add padding for content
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  // Right border only
                                  color: Color.fromARGB(
                                      33, 0, 0, 0), // Border color
                                  width: 2.0, // Border width
                                ),
                              ),
                            ), // Add padding inside the container
                            child: ListView(
                              padding: EdgeInsets
                                  .zero, // Optional: control padding for ListView
                              children: [
                                // Image Section
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Container(
                                      // Make the image section take the full height with some constraint
                                      constraints: BoxConstraints(
                                        maxHeight: 400,
                                        maxWidth: 450, // Adjust as necessary
                                      ),
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            widget.imagePath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width < 1000
                                          ? 10
                                          : 40,
                                ),
                                Center(
                                    child: buildActionButton(context, false)),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                // Ingredients list
                                buildIngredientsList(context, dialogSetState),
                                SizedBox(height: 40),
                                buildAppliancesSection(context),
                                SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 50), // Spacing between columns

                        // Right Column (Description, Details, Instructions + Chatbot)
                        Flexible(
                          flex: MediaQuery.of(context).size.width < 700
                              ? 5
                              : MediaQuery.of(context).size.width < 900
                                  ? 6
                                  : 7,
                          child: Stack(
                            children: [
                              ListView(
                                padding: EdgeInsets.only(
                                    right: 20.0), // Add padding to the right
                                children: [
                                  Text(
                                    "Description:",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFFDC945F),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 15.0),
                                  Padding(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      widget.description,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  buildTimeInfoRow(
                                    context,
                                    '${widget.prepTime}',
                                    '${widget.cookTime}',
                                    textColor,
                                  ),
                                  SizedBox(height: 8),
                                  buildDetailsColumn(
                                    context,
                                    '${widget.cuisine}',
                                    '${widget.spiceLevel}',
                                    '${widget.course}',
                                    '${widget.servings}',
                                  ),
                                  SizedBox(height: 40),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: buildInstructions(widget.steps),
                                  ),
                                  SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(height: 15.0),
                                          // Conditional display based on screen width
                                          MediaQuery.of(context).size.width <
                                                  1100
                                              ? ElevatedButton(
                                                  onPressed:
                                                      _chatbotPopup, // Call your popup method
                                                  child: ClipOval(
                                                    child: Image.asset(
                                                      'assets/chef.png', // Path to your image asset
                                                      width:
                                                          60, // Adjust size as needed
                                                      height:
                                                          60, // Adjust size as needed
                                                    ),
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0.2,
                                                    shape: CircleBorder(),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 15,
                                                    ),
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                      0,
                                                      81,
                                                      168,
                                                      81,
                                                    ), // Background color
                                                  ),
                                                )
                                              : Container(
                                                  width: screenWidth *
                                                      0.4, // Default to 40% otherwise
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.7,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0), // Adjust the radius as needed
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                          78, 0, 0, 0),
                                                      width:
                                                          1.0, // Optional: add a border
                                                    ),
                                                    color: Color.fromARGB(
                                                      33,
                                                      0,
                                                      0,
                                                      0,
                                                    ), // Background color, adjust as needed
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0), // Same radius for clipping
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                          10.0), // Add your desired padding here
                                                      child: ChatWidget(
                                                        recipeName: widget.name,
                                                        recipeDescription:
                                                            widget.description,
                                                        ingredients:
                                                            widget.ingredients,
                                                        steps: widget.steps,
                                                        userId: userId!,
                                                        course: widget.course,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    ).then((_) {
      // This will be called when the dialog is dismissed
      _fetchShoppingList();
    });
  }

  void _chatbotPopup() {
    //final double screenWidth = MediaQuery.of(context).size.width;
    // showDialog(
    //     barrierColor: Color.fromARGB(158, 0, 0, 0),
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (context) {
    //       return FloatingDialog(
    //         onClose: () {
    //           Navigator.of(context).pop();
    //         },
    //         child: Stack(
    //           children: [
    //             // Background image with dark overlay
    //             Container(
    //               width: screenWidth * 0.5, // Adjust the width as needed
    //               height: MediaQuery.of(context).size.height *
    //                   0.7, // Adjust the height as needed

    //               decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.circular(
    //                     15.0), // Optional: Same as the Dialog border radius
    //               ),
    //             ),

    //             Container(
    //               width: screenWidth * 0.5,
    //               height: MediaQuery.of(context).size.height * 0.7,
    //               child: ChatWidget(
    //                 recipeName: widget.name,
    //                 recipeDescription: widget.description,
    //                 ingredients: widget.ingredients,
    //                 steps: widget.steps,
    //                 userId: userId!,
    //                 course: widget.course,
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
    //     });

    //Code if draggable causes issues
    final theme = Theme.of(context);
    final clickColor =
        theme.brightness == Brightness.light ? Colors.white : Color(0xFF283330);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15.0), // Optional: Add rounded corners
          ),
          child: Stack(
            children: [
              Container(
                width: screenWidth * 0.5, // Adjust the width as needed
                height: MediaQuery.of(context).size.height *
                    0.7, // Adjust the height as needed

                decoration: BoxDecoration(
                  color: clickColor,
                  borderRadius: BorderRadius.circular(
                      15.0), // Optional: Same as the Dialog border radius
                ),
              ),
              Container(
                width: screenWidth * 0.5,
                height: MediaQuery.of(context).size.height * 0.7,
                child: ChatWidget(
                  recipeName: widget.name,
                  recipeDescription: widget.description,
                  ingredients: widget.ingredients,
                  steps: widget.steps,
                  userId: userId!,
                  course: widget.course,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    // double fontSizeTitle;
    // double boxWidth;
    // double iconSize;
    double fontSizeDescription = screenWidth * 0.01;
    double fontSizeTimes = screenWidth * 0.008;

    // Use custom values if provided, otherwise default to calculated values
    double fontSizeTitle = widget.customFontSizeTitle ??
        (screenWidth < 450 ? screenWidth * 0.05 : screenWidth * 0.015);
    double boxWidth = widget.customBoxWidth ??
        (screenWidth < 450 ? screenWidth / 2 : screenWidth / 7);
    double iconSize = widget.customIconSize ??
        (screenWidth < 450 ? screenWidth * 0.08 : screenWidth * 0.017);

    // if (screenWidth < 500) {
    //   fontSizeTitle = screenWidth * 0.05;
    //   boxWidth = MediaQuery.of(context).size.width / 2;
    //   iconSize = MediaQuery.of(context).size.width * 0.08;
    // } else {
    //   fontSizeTitle = screenWidth * 0.015;
    //   boxWidth = MediaQuery.of(context).size.width / 7;
    //   iconSize = MediaQuery.of(context).size.width * 0.017;
    // }

    final hoverColor = theme.brightness == Brightness.light
        ? Color(0xFF202920).withOpacity(0.8)
        : Color.fromARGB(15, 0, 0, 0).withOpacity(0.5);

    bool enableHover = screenWidth >= 1029;

    void handleTap() {
      if (screenWidth < 550) {
        _showMobileRecipeDetails();
      } else {
        _showRecipeDetails();
      }
    }

// Now fontSizeTitle is accessible here

    return GestureDetector(
      onTap: handleTap,
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
                    gradient: RadialGradient(
                        // begin: Alignment.topCenter,
                        // end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(0, 0, 0, 0),
                          Color.fromARGB(129, 0, 0, 0),
                        ],
                        radius: 0.99),
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
                  width: boxWidth, // Half the width of the recipe card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeTitle,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                          height:
                              5), // Add some spacing between name and counts
                      Text(
                        'Pantry: $_ingredientsInPantry/${widget.ingredients.length} ingredients in your pantry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeTitle *
                              0.8, // Smaller font size for the counts
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
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
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.006,
                      ), // Add some spacing between name and counts
                      Text(
                        'Pantry: $_ingredientsInPantry/${widget.ingredients.length} ingredients in your pantry',
                        // 'Needed: $_ingredientsNeeded',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              fontSizeDescription, // Smaller font size for the counts
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
                top: MediaQuery.of(context).size.width * 0.01,
                right: MediaQuery.of(context).size.width * 0.01,
                child: Row(
                  children: [
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.timer,
                    //     color: Colors.white,
                    //     size: iconSize,
                    //   ),
                    //   onPressed: _showTimerPopup,
                    // ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                        size: iconSize,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  // void _suggestSubstitution() {}

  Widget buildTimeInfoRow(
      BuildContext context, String prepTime, String cookTime, Color textColor) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize;
    if (screenWidth > 700) {
      fontSize = 16;
    } else {
      fontSize = 14;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prep Time:',
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.006,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.006,
                      ),
                      child: Text(
                        '$prepTime mins',
                        style: TextStyle(
                          color: textColor,
                          fontSize: fontSize,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.008,
                ),
                Container(
                  height: 40, // Set a fixed height for the vertical divider
                  child: VerticalDivider(
                    width: 20,
                    thickness: 1.8,
                    indent: 20,
                    endIndent: 0,
                    color: textColor,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.008,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cook Time:',
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.006,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.006,
                      ),
                      child: Text(
                        '$cookTime mins',
                        style: TextStyle(
                          color: textColor,
                          fontSize: fontSize,
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
          width: MediaQuery.of(context).size.width * 0.008,
        ),
        Container(
          height: 40,
          child: VerticalDivider(
            width: 20,
            thickness: 1.8,
            indent: 20,
            endIndent: 0,
            color: textColor,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.008,
        ),
        if (MediaQuery.of(context).size.width > 700)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Time:',
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.006,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.006,
                ),
                child: Text(
                  '${int.parse(prepTime) + int.parse(cookTime)} mins',
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                  ),
                  overflow: TextOverflow.ellipsis, // Add this line for ellipsis
                  maxLines: 1, // Set the maximum number of lines
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget buildDetailsColumn(BuildContext context, String cuisine,
      String spiceLevel, String course, String servings) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize;
    if (screenWidth > 550) {
      fontSize = 16;
    } else {
      fontSize = 14;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0), // Adjust padding as needed
          child: Text(
            'Cuisine: $cuisine',
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.0), // Adjust padding as needed
          child: Text(
            'Spice Level: $spiceLevel',
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.0), // Adjust padding as needed
          child: Text(
            'Course: $course',
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.0), // Adjust padding as needed

/*
          return CheckableItem(
            title:
                '${ingredient['name']} (${ingredient['quantity']} ${ingredient['measurement_unit']})',
            requiredQuantity: ingredient['quantity'],
            requiredUnit: ingredient['measurement_unit'],
            onChanged: (bool? value) {
              if (mounted) {
                setState(() {
                  _ingredientChecked[idx] = value ?? false;
                });
              }
            },
            isInPantry: isInPantry,
            availableQuantity: availableQuantity,
            isChecked: _ingredientChecked[idx] ?? true,
            isInShoppingList: isInShoppingList,
            recipeID: widget.recipeID,
            onRecipeUpdate: _updateRecipe, // Pass recipeID here
          );
        }),
        if (widget.ingredients.every((ingredient) =>
            _pantryIngredients.containsKey(ingredient['name']) &&
            _pantryIngredients[ingredient['name']]!['quantity'] >=
                ingredient['quantity']))
          ElevatedButton(
            onPressed: _removeIngredientsFromPantry,
            child: Text('Remove ingredients from pantry'),
*/
          child: Text(
            'Servings: $servings',
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAppliancesSection(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize;

    if (screenWidth > 550) {
      fontSize = 20;
    } else {
      fontSize = 16;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Appliances:",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDC945F),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        if (widget.appliances.isEmpty)
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline, // Appropriate icon for no appliance
                  color: Colors.grey, // Same grey as the text for consistency
                ),
                SizedBox(width: 8), // Space between icon and text
                Flexible(
                  // Use Flexible to prevent overflow
                  child: Text(
                    "No appliances specified.",
                    style: TextStyle(
                      color: Colors.grey, // Light grey color
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // Limit to one line
                  ),
                ),
              ],
            ),
          )
        else
          ...widget.appliances.map((appliance) => Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(appliance),
              )),
      ],
    );
  }

  List<Widget> buildInstructions(List<String> steps) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize, stepHeight;

    if (screenWidth > 550) {
      fontSize = 20;
      stepHeight = 15.0;
    } else {
      fontSize = 16;
      stepHeight = 10.0;
    }

    List<Widget> instructions = [
      Text(
        'Instructions:',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Color(0xFFDC945F),
        ),
      ),
      SizedBox(height: stepHeight),
    ];

    // Build steps with stepHeight spacing between them
    for (int i = 0; i < steps.length; i++) {
      var subSteps = steps[i].split('<');
      for (String subStep in subSteps) {
        instructions.add(
          Padding(
            padding:
                EdgeInsets.only(bottom: 8.0), // Space between each sub-step
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24.0, // Diameter of the circle
                  height: 24.0, // Diameter of the circle
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(115, 220, 147, 95), // Circle color
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}', // Step number
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Number color
                    ),
                  ),
                ),
                SizedBox(
                    width: stepHeight), // Indentation between circle and text
                Expanded(
                  child: Text(
                    subStep,
                    style: TextStyle(fontSize: 16), // Step text style
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Add SizedBox between steps
      if (i < steps.length - 1) {
        instructions.add(SizedBox(height: stepHeight));
      }
    }

    return instructions;
  }

  Widget buildActionButton(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final clickColor =
        theme.brightness == Brightness.light ? Color(0xFF283330) : Colors.white;

    return ElevatedButton.icon(
      onPressed: () async {
        if (!_isAlteredRecipe) {
          if (userId != null) {
            // Show loading dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Adjusting recipe...',
                    style: TextStyle(color: Colors.black),
                  ),
                  content: CircularProgressIndicator(),
                  backgroundColor: Colors.white,
                );
              },
            );

            // Fetch and update recipe
            String alteredRecipeJson = await fetchDietaryConstraintsRecipe(
              userId!,
              widget.recipeID,
            );

            // Decode JSON
            Map<String, dynamic> alteredRecipe = jsonDecode(alteredRecipeJson);

            // Update recipe and refresh
            _updateRecipe(alteredRecipe);
            Navigator.of(context).pop(); // stop loading screen
            Navigator.of(context).pop();

            if (isMobile) {
              _showMobileRecipeDetails();
            } else {
              _showRecipeDetails();
            }
          }
        } else {
          // Revert to original recipe
          _revertToOriginalRecipe();
          Navigator.of(context).pop();
          if (isMobile) {
            _showMobileRecipeDetails();
          } else {
            _showRecipeDetails();
          } // Refresh recipe
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Less rounded corners
          side: BorderSide(
            color: clickColor, // Border color to match the theme
            width: 2, // Thickness of the border
          ),
        ),
        shadowColor: const Color.fromARGB(
            255, 190, 190, 190), // Shadow to make it stand out
        elevation: 0, // Higher elevation for shadow effect
      ),
      icon: Icon(
        _isAlteredRecipe
            ? Icons.restore
            : Icons.restaurant_menu, // Icon for the button
        color: clickColor, // Icon color
      ),
      label: Text(
        _isAlteredRecipe
            ? 'Revert to Original Recipe'
            : 'Adjust recipe to cater to my preferences',
        style: TextStyle(color: clickColor),
      ),
    );
  }

  Widget buildIngredientsList(
      BuildContext context, StateSetter dialogSetState) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final clickColor = isLightTheme ? Color(0xFF283330) : Colors.white;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize;
    if (screenWidth > 550) {
      fontSize = 20;
    } else {
      fontSize = 16;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients:',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDC945F),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        ...widget.ingredients.asMap().entries.map((entry) {
          int idx = entry.key;
          Map<String, dynamic> ingredient = entry.value;

          bool isInPantry = _pantryIngredients.containsKey(ingredient['name']);
          double availableQuantity = isInPantry
              ? (_pantryIngredients[ingredient['name']]?['quantity'] ?? 0.0)
              : 0.0;
          bool isInShoppingList = _shoppingList.containsKey(ingredient['name']);

          return CheckableItem(
            title:
                '${ingredient['name']} (${ingredient['quantity']} ${ingredient['measurement_unit']})',
            requiredQuantity: ingredient['quantity'],
            requiredUnit: ingredient['measurement_unit'],
            onChanged: (bool? value) {
              if (mounted) {
                setState(() {
                  _ingredientChecked[idx] = value ?? false;
                });
              }
            },
            isInPantry: isInPantry,
            availableQuantity: availableQuantity,
            isChecked: _ingredientChecked[idx] ?? true,
            isInShoppingList: isInShoppingList,
            recipeID: widget.recipeID, // Pass recipeID here
            onRecipeUpdate: (Map<String, dynamic> alteredRecipe) {
              _updateRecipe(alteredRecipe);
              if (mounted) {
                // Create new controller
                dialogSetState(
                    () {}); // Update the dialog's state// Update the dialog's state
              }
            },
          );
        }),
        SizedBox(
          height: 25,
        ),
        if (widget.ingredients.every((ingredient) =>
            _pantryIngredients.containsKey(ingredient['name']) &&
            _pantryIngredients[ingredient['name']]!['quantity'] >=
                ingredient['quantity']))
          ElevatedButton(
            onPressed: _removeIngredientsFromPantry,
            style: ElevatedButton.styleFrom(
              backgroundColor: clickColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: Text('Remove ingredients from pantry',
                style: TextStyle(
                    color: isLightTheme ? Colors.white : Color(0xFF1F4539))),
          ),
        if (widget.ingredients.any((ingredient) =>
            (!_pantryIngredients.containsKey(ingredient['name']) ||
                _pantryIngredients[ingredient['name']]!['quantity'] <
                    ingredient['quantity']) &&
            !_shoppingList.containsKey(ingredient['name'])))
          Center(
            child: ElevatedButton.icon(
              onPressed: _addAllToShoppingList,
              icon: Icon(
                Icons.add_shopping_cart_rounded, // Shopping basket icon
                color: isLightTheme
                    ? Colors.white
                    : Color(0xFF1F4539), // Icon color
              ),
              label: Text(
                'Add All Ingredients',
                style: TextStyle(
                  color: isLightTheme ? Colors.white : Color(0xFF1F4539),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: clickColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),
          ),

        //SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }

  Widget buildTabRow(
      int selectedTab, Color textColor, Function(int) onTabSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Details Tab
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: selectedTab == 0
                  ? Color.fromARGB(69, 220, 147, 95)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: TextButton(
              onPressed: () => onTabSelected(0),
              child: Center(
                child: Text(
                  "Details",
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Instructions Tab
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: selectedTab == 1
                  ? Color.fromARGB(69, 220, 147, 95)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: TextButton(
              onPressed: () => onTabSelected(1),
              child: Center(
                child: Text(
                  "Instructions",
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Chat Bot Tab
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: selectedTab == 2
                  ? Color.fromARGB(69, 220, 147, 95)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: TextButton(
              onPressed: () => onTabSelected(2),
              child: Center(
                child: Text(
                  "Chat Bot",
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

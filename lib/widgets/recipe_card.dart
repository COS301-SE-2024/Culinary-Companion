// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'chat_widget.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:your_project_name/path_to_tab_controller.dart';  // Import your tab controller file here
import '../gemini_service.dart'; // LLM
//import 'package:lottie/lottie.dart';

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
  String? userId;
  int _ingredientsInPantry = 0; //number of ingredients that I have
  // int _ingredientsNeeded = 0; //number of ingredients I still need to buy
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
    //_updateIngredientCounts();
  }

  Future<void> _fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userId = prefs.getString('userId');
      });
    }
  }

  void _updateRecipe(Map<String, dynamic> alteredRecipe) {
    //if (mounted) {
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
      widget.appliances = widget.appliances; // Assuming appliances don't change
      //print('gets here 11');

      // map ingredients
      widget.ingredients =
          alteredRecipe['ingredients'].map<Map<String, dynamic>>((ingredient) {
        //print('Ingredient: $ingredient');
        var nameEndIndex = ingredient.lastIndexOf(' (');
        var name = ingredient.substring(0, nameEndIndex);
        var quantityAndUnit = ingredient
            .substring(nameEndIndex + 2, ingredient.length - 1)
            .split(' ');
        return {
          'name': name,
          'quantity': double.tryParse(quantityAndUnit[0]) ?? 0.0,
          'measurement_unit': quantityAndUnit[1],
        };
      }).toList();

      //print('Parsed Ingredients: ${widget.ingredients}');
      //print('gets here 12');
      _isAlteredRecipe = true;
      //_showRecipeDetails();
    });
    //}
  }

  void _revertToOriginalRecipe() {
    if (_originalRecipe != null) {
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

      // Check if the ingredient is already in the shopping list
      if (_shoppingList.containsKey(name)) {
        continue; // Skip adding if the ingredient is already in the shopping list
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
                  // Update the state to reflect that the ingredient is in the shopping list
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
                // Update the state to reflect that the ingredient is in the shopping list
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

      // Calculate the new quantity
      double newQuantity = currentQuantity - quantity;

      // Determine the action based on the new quantity
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

    double dialogHeight =
        screenHeight * 0.8; // 80% of screen height for the dialog
    double imageHeight =
        dialogHeight * 0.5; // 50% of dialog height for the image
    double contentHeight =
        dialogHeight * 0.5; // 50% of dialog height for the content

    double fontSizeTitle = screenWidth * 0.05;

    final clickColor =
        theme.brightness == Brightness.light ? Colors.white : Color(0xFF283330);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              Colors.transparent, // Set background color to transparent
          child: Container(
            width: screenWidth * 0.8, // 80% of screen width for the dialog
            height: dialogHeight, // 80% of screen height for the dialog
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: imageHeight, // 50% of dialog height for the image
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
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
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
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
                        color: Colors.black
                            .withOpacity(0.5), // Background color of the circle
                      ),
                      child: Center(
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          iconSize: screenWidth * 0.05, // Adjust icon size
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
                    right: 10.0, // Adjust position as necessary
                    child: Container(
                      width: screenWidth *
                          0.1, // Adjust width of the circular background
                      height: screenWidth *
                          0.1, // Adjust height of the circular background
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black
                            .withOpacity(0.5), // Background color of the circle
                      ),
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.white,
                          ),
                          iconSize: screenWidth * 0.05, // Adjust icon size
                          onPressed: _toggleFavorite,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: contentHeight +
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
                  Positioned(
                    top: imageHeight, // Position at the bottom of the image
                    left: 0,
                    right: 0,
                    child: Container(
                      width: screenWidth * 0.8,
                      height:
                          contentHeight, // 50% of dialog height for the content
                      color: clickColor,
                      child: DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.01, // Adjust height
                            ),
                            TabBar(
                              labelColor: Colors.white,
                              indicatorColor: Colors.white,
                              tabs: [
                                Tab(text: 'Details'),
                                Tab(text: 'Instructions'),
                                Tab(text: 'Chat Bot'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  SingleChildScrollView(
                                    padding: EdgeInsets.all(
                                        16.0), // Add padding around the scrollable area
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Prep Time:',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.006,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.006,
                                                          ),
                                                          child: Text(
                                                            '${widget.prepTime} mins',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.008), // Add spacing
                                                    Container(
                                                      height:
                                                          40, // Set a fixed height for the vertical divider
                                                      child: VerticalDivider(
                                                        width: 20,
                                                        thickness: 1.8,
                                                        indent: 20,
                                                        endIndent: 0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.008), // Add spacing
                                                    // Add spacing between elements
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Cook Time:',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.006,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.006,
                                                          ),
                                                          child: Text(
                                                            '${widget.cookTime} mins',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
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
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.008), // Add spacing
                                            Container(
                                              height:
                                                  40, // Set a fixed height for the vertical divider
                                              child: VerticalDivider(
                                                width: 20,
                                                thickness: 1.8,
                                                indent: 20,
                                                endIndent: 0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.008), // Add spacing
                                            // Add spacing between elements// Add spacing between elements
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total Time:',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
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
                                                    '${widget.prepTime + widget.cookTime} mins',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15.0),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left:
                                                      16.0), // Adjust padding as needed
                                              child: Text(
                                                  'Cuisine: ${widget.cuisine}'),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left:
                                                      16.0), // Adjust padding as needed
                                              child: Text(
                                                  'Spice Level: ${widget.spiceLevel}'),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left:
                                                      16.0), // Adjust padding as needed
                                              child: Text(
                                                  'Course: ${widget.course}'),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left:
                                                      16.0), // Adjust padding as needed
                                              child: Text(
                                                  'Servings: ${widget.servings}'),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02), // Adjust height to 2% of screen height
                                        Text(
                                          "Ingredients:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFFDC945F),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01), // Adjust height to 1% of screen height
                                        ...widget.ingredients
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int idx = entry.key;
                                          Map<String, dynamic> ingredient =
                                              entry.value;
                                          bool isInPantry = _pantryIngredients
                                              .containsKey(ingredient['name']);
                                          double availableQuantity = isInPantry
                                              ? (_pantryIngredients[
                                                          ingredient['name']]
                                                      ?['quantity'] ??
                                                  0.0)
                                              : 0.0;
                                          bool isInShoppingList = _shoppingList
                                              .containsKey(ingredient['name']);

                                          return CheckableItem(
                                            title:
                                                '${ingredient['name']} (${ingredient['quantity']} ${ingredient['measurement_unit']})',
                                            requiredQuantity:
                                                ingredient['quantity'],
                                            requiredUnit:
                                                ingredient['measurement_unit'],
                                            onChanged: (bool? value) {
                                              if (mounted) {
                                                setState(() {
                                                  _ingredientChecked[idx] =
                                                      value ?? false;
                                                });
                                              }
                                            },
                                            isInPantry: isInPantry,
                                            availableQuantity:
                                                availableQuantity,
                                            isChecked:
                                                _ingredientChecked[idx] ?? true,
                                            isInShoppingList: isInShoppingList,
                                            recipeID: widget.recipeID,
                                            onRecipeUpdate:
                                                _updateRecipe, // Pass recipeID here
                                          );
                                        }),
                                        if (widget.ingredients.every(
                                            (ingredient) =>
                                                _pantryIngredients.containsKey(
                                                    ingredient['name']) &&
                                                _pantryIngredients[ingredient[
                                                        'name']]!['quantity'] >=
                                                    ingredient['quantity']))
                                          ElevatedButton(
                                            onPressed:
                                                _removeIngredientsFromPantry,
                                            child: Text(
                                                'Remove ingredients from pantry'),
                                          ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02), // Adjust height to 2% of screen height
                                        Text(
                                          "Appliances:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(
                                                0xFFDC945F), // Optionally set the thickness of the underline
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        ...widget.appliances.map(
                                          (appliance) => Padding(
                                            padding: EdgeInsets.only(
                                                left:
                                                    16.0), // Add 16 pixels of padding to the left
                                            child: Text(appliance),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  // Content for the second tab
                                  SingleChildScrollView(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Instructions:',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFDC945F)),
                                        ),
                                        SizedBox(height: 8.0),
                                        ...widget.steps.expand((step) {
                                          return step.split('<').map((subStep) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  bottom:
                                                      8.0), // Space between each step
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width:
                                                        24.0, // Diameter of the circle
                                                    height:
                                                        24.0, // Diameter of the circle
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color.fromARGB(
                                                          115,
                                                          220,
                                                          147,
                                                          95), // Color of the circle
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      '${widget.steps.indexOf(step) + 1}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors
                                                            .white, // Color of the number
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          8.0), // Adjust this value to control the indent
                                                  Expanded(
                                                    child: Text(
                                                      subStep,
                                                      style: TextStyle(
                                                          fontSize:
                                                              16), // Style for each step
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.0),
                                                ],
                                              ),
                                            );
                                          }).toList();
                                        })
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth * 0.2,
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // This will be called when the dialog is dismissed
      _fetchShoppingList();
    });
  }

//   void _showAlteredRecipe(String substitute, String substitutedIngredient) async {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Loading altered recipe...'),
//         content: CircularProgressIndicator(),
//       );
//     },
//   );

//   String jsonString = await fetchIngredientSubstitutionRecipe(widget.recipeID, substitute, substitutedIngredient);

//   Navigator.of(context).pop(); // Close the loading dialog

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Altered Recipe'),
//         content: SingleChildScrollView(
//           child: Text(jsonString),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: Text('Close'),
//           ),
//         ],
//       );
//     },
//   );
// }

  void _showRecipeDetails() {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    int neededIngredientCount = widget.ingredients
        .where((ingredient) =>
            (!_pantryIngredients.containsKey(ingredient['name']) ||
                _pantryIngredients[ingredient['name']]!['quantity'] <
                    ingredient['quantity']) &&
            !_shoppingList.containsKey(ingredient['name']))
        .length;
    final theme = Theme.of(context);

    final clickColor = theme.brightness == Brightness.light
        ? Colors.white
        : Color.fromARGB(255, 25, 58, 48);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        // ignore: unused_local_variable
        final bool showImage =
            screenWidth > 1359; // Adjust the threshold as needed

        return Dialog(
          backgroundColor: clickColor, // Change background color to green
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.01),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              return Container(
                width: screenWidth * 0.8, // Set width to 80% of screen width
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
                child: Row(
                  children: [
                    Expanded(
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
                                      color: _isFavorite
                                          ? Colors.red
                                          : Colors.grey,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.description),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
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
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.01), // Adjust height to 1% of screen height
                                  Text('Cuisine: ${widget.cuisine}'),
                                  Text('Spice Level: ${widget.spiceLevel}'),
                                  Text('Course: ${widget.course}'),
                                  Text('Servings: ${widget.servings}'),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.02), // Adjust height to 2% of screen height
                                  Text('Ingredients:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.01), // Adjust height to 1% of screen height
                                  ...widget.ingredients
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int idx = entry.key;
                                    Map<String, dynamic> ingredient =
                                        entry.value;
                                    bool isInPantry = _pantryIngredients
                                        .containsKey(ingredient['name']);
                                    double availableQuantity = isInPantry
                                        ? (_pantryIngredients[
                                                    ingredient['name']]
                                                ?['quantity'] ??
                                            0.0)
                                        : 0.0;
                                    bool isInShoppingList = _shoppingList
                                        .containsKey(ingredient['name']);

                                    return CheckableItem(
                                      title:
                                          '${ingredient['name']} (${ingredient['quantity']} ${ingredient['measurement_unit']})',
                                      requiredQuantity: ingredient['quantity'],
                                      requiredUnit:
                                          ingredient['measurement_unit'],
                                      onChanged: (bool? value) {
                                        if (mounted) {
                                          setState(() {
                                            _ingredientChecked[idx] =
                                                value ?? false;
                                          });
                                        }
                                      },
                                      isInPantry: isInPantry,
                                      availableQuantity: availableQuantity,
                                      isChecked:
                                          _ingredientChecked[idx] ?? true,
                                      isInShoppingList: isInShoppingList,
                                      recipeID:
                                          widget.recipeID, // Pass recipeID here
                                      onRecipeUpdate:
                                          (Map<String, dynamic> alteredRecipe) {
                                        _updateRecipe(alteredRecipe);
                                        dialogSetState(
                                            () {}); // Update the dialog's state
                                      },
                                    );
                                  }),
                                  if (widget.ingredients.every((ingredient) =>
                                      _pantryIngredients
                                          .containsKey(ingredient['name']) &&
                                      _pantryIngredients[ingredient['name']]![
                                              'quantity'] >=
                                          ingredient['quantity']))
                                    ElevatedButton(
                                      onPressed: _removeIngredientsFromPantry,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: textColor,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 20),
                                      ),
                                      child: Text(
                                          'Remove ingredients from pantry',
                                          style: TextStyle(
                                              color: isLightTheme
                                                  ? Colors.white
                                                  : Color(0xFF1F4539))),
                                    ),
                                  if (widget.ingredients.any((ingredient) =>
                                      (!_pantryIngredients.containsKey(
                                              ingredient['name']) ||
                                          _pantryIngredients[ingredient[
                                                  'name']]!['quantity'] <
                                              ingredient['quantity']) &&
                                      (neededIngredientCount > 1) &&
                                      !_shoppingList
                                          .containsKey(ingredient['name'])))
                                    ElevatedButton(
                                      onPressed: _addAllToShoppingList,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: textColor,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 20),
                                      ),
                                      child: Text('Add All Ingredients',
                                          style: TextStyle(
                                              color: isLightTheme
                                                  ? Colors.white
                                                  : Color(0xFF1F4539))),
                                    ),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.02), // Adjust height to 2% of screen height
                                  Text('Appliances:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.01), // Adjust height to 1% of screen height
                                  ...widget.appliances
                                      .map((appliance) => Text(appliance)),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.02), // Adjust height to 2% of screen height
                                  Text('Instructions:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.01), // Adjust height to 1% of screen height
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  if (_isAlteredRecipe)
                                    ElevatedButton(
                                      onPressed: () {
                                        _revertToOriginalRecipe();
                                        dialogSetState(
                                            () {}); // Update the dialog's state
                                      },
                                      child: Text('Revert to Original Recipe'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.2,
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

    void handleTap() {
      if (screenWidth < 450) {
        _showMobileRecipeDetails();
      } else {
        _showRecipeDetails();
      }
    }

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

  // void _suggestSubstitution() {}
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
  final String recipeID;
  final Function(Map<String, dynamic>) onRecipeUpdate; // Add this

  CheckableItem({
    required this.title,
    required this.requiredQuantity,
    required this.requiredUnit,
    required this.onChanged,
    required this.isInPantry,
    required this.availableQuantity,
    required this.isChecked,
    required this.isInShoppingList,
    required this.recipeID,
    required this.onRecipeUpdate,
  });

  @override
  _CheckableItemState createState() => _CheckableItemState();
}

class _CheckableItemState extends State<CheckableItem> {
  bool _isAdded = false;

  void _showSubstitutesDialog() async {
    // Show a loading dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Loading substitutions...',
            style: TextStyle(color: Colors.black), // Set text color to black
          ),
          content: CircularProgressIndicator(),
          backgroundColor: Colors.white, // Set background color to white
        );
      },
    );

    // Fetch the substitutions
    String jsonString =
        await fetchIngredientSubstitutions(widget.recipeID, widget.title);

    // Parse the JSON string
    Map<String, dynamic> substitutions;
    try {
      substitutions = jsonDecode(jsonString);
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading dialog
      // Show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Error',
              style: TextStyle(color: Colors.black), // Set text color to black
            ),
            content: Text(
              'Failed to fetch substitutions.',
              style: TextStyle(color: Colors.black), // Set text color to black
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFDC945F),
                    width: 1.5,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFFDC945F),
                  ), // Set text color to black
                ),
              ),
            ],
            backgroundColor: Colors.white, // Set background color to white
          );
        },
      );
      return;
    }

    // Close the loading dialog
    Navigator.of(context).pop();

    // Show the substitutions dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Here are a list of substitutes for ${widget.title}',
            style: TextStyle(color: Colors.black), // Set text color to black
          ),
          content: Container(
            width: double.maxFinite, // Make the container as wide as the dialog
            child: ListView(
              shrinkWrap: true,
              children: substitutions.entries.map((entry) {
                return ListTile(
                  title: Text(
                    entry.value,
                    style: TextStyle(
                        color: Colors.black), // Set text color to black
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pop(); // Close the substitutions dialog
                    _generateAlteredRecipe(entry.value,
                        widget.title); // Generate the altered recipe
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFFDC945F),
                  width: 1.5,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFFDC945F),
                ), // Set text color to black
              ),
            ),
          ],
          backgroundColor: Colors.white, // Set background color to white
        );
      },
    );
  }

  Future<void> _generateAlteredRecipe(
      String substitute, String substitutedIngredient) async {
    // Show a loading dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Generating altered recipe...',
            style: TextStyle(color: Colors.black), // Set text color to black
          ),
          content: CircularProgressIndicator(),
          backgroundColor: Colors.white, // Set background color to white
        );
      },
    );

    // Fetch the altered recipe
    String jsonString = await fetchIngredientSubstitutionRecipe(
        widget.recipeID, substitute, substitutedIngredient);

    // Close the loading dialog
    Navigator.of(context).pop();

    // Parse the JSON string
    Map<String, dynamic> alteredRecipe = jsonDecode(jsonString);

    // Update the recipe data with the altered recipe
    widget.onRecipeUpdate(alteredRecipe);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color textColor =
        isLightTheme ? Color.fromARGB(255, 19, 20, 20) : Colors.white;
    bool isSufficient = widget.isInPantry &&
        widget.availableQuantity >= widget.requiredQuantity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isSufficient)
              Checkbox(
                value: widget.isChecked,
                onChanged: widget.onChanged,
                activeColor: Color(0XFFDC945F),
                checkColor: textColor,
              )
            else
              SizedBox(
                width: 24.0, // to keep alignment when checkbox is missing
              ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.swap_horiz, color: textColor),
                    onPressed: _showSubstitutesDialog,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isSufficient && !(widget.isInShoppingList || _isAdded))
          Padding(
            padding: EdgeInsets.only(left: 27),
            child: TextButton(
              onPressed: () => _addToShoppingList(
                widget.title,
                widget.requiredQuantity - widget.availableQuantity,
                widget.requiredUnit,
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '+ ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: '${widget.title.split(" (")[0]}',
                      style: TextStyle(color: Color(0xFF89AA4A)),
                    ),
                    TextSpan(
                      text: ' to shopping list',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (widget.isInShoppingList || _isAdded)
          Padding(
            padding: EdgeInsets.only(left: 27, top: 0),
            child: TextButton(
              onPressed: null,
              child: Text('In Shopping List'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
          )
        else if (isSufficient)
          Padding(
            padding: EdgeInsets.only(left: 27, top: 0),
            child: TextButton(
              onPressed: null,
              child: Text('In Pantry List'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
          )
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
        if (mounted) {
          setState(() {
            _isAdded = true;
            _updateShoppingList(ingredientName, remainingQuantity, unit);
          });
        }
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
    if (mounted) {
      setState(() {
        widget.isInShoppingList = true;
      });
    }
  }
}

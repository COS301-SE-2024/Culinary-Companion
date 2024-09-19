import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import '../widgets/help_favorite.dart';

import '../widgets/recipe_card.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SavedRecipesScreen extends StatefulWidget {
  @override
  _SavedRecipesScreenState createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  String? _userId;
  List<Map<String, dynamic>> recipes = [];
  bool _isLoading = true;
  OverlayEntry? _helpMenuOverlay;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load user ID first
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getString('userId');
        //print('Login successful: $_userId');
        if (_userId != null) {
          //print('here 1');
          fetchRecipes(); // Call fetchRecipes only if userId is loaded successfully
        }
      });
    }
  }

  Future<void> fetchRecipes() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getUserFavourites', 'userId': _userId});

    try {
      // Load cached recipes first in the background without showing the loader again
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedRecipes = prefs.getString('cached_recipes');

      if (cachedRecipes != null) {
        // Only set the state if recipes list is empty (so that it doesn't "reload")
        if (recipes.isEmpty) {
          setState(() {
            recipes =
                List<Map<String, dynamic>>.from(jsonDecode(cachedRecipes));
          });
        }
      }

      // Fetch fresh recipes from Supabase
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedRecipes = jsonDecode(response.body);

        // Clear the recipes list to avoid duplication and update with fresh data
        recipes.clear();

        // Fetch recipe details in parallel
        List<Future<void>> recipeFutures = [];
        for (var recipe in fetchedRecipes) {
          final String recipeId = recipe['recipeid'];
          recipeFutures.add(fetchRecipeDetails(recipeId));
        }

        await Future.wait(recipeFutures);

        // Cache the fetched recipes for future use
        await prefs.setString('cached_recipes', jsonEncode(recipes));

        // Update the UI only after fresh data is fetched
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('Failed to load recipes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    }

    // Ensure loading spinner is hidden once data is fetched
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchRecipeDetails(String recipeId) async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getRecipe', 'recipeid': recipeId});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> fetchedRecipe = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            recipes.add(fetchedRecipe);
          });
        }
      } else {
        print('Failed to load recipe details: ${response.statusCode}');
      }
    } catch (error) {
      //print('Error fetching recipe details: $error');
    }
  }

  void _showHelpMenu() {
    _helpMenuOverlay = OverlayEntry(
      builder: (context) => HelpMenu(
        onClose: () {
          _helpMenuOverlay?.remove();
          _helpMenuOverlay = null;
        },
      ),
    );
    Overlay.of(context).insert(_helpMenuOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: Icon(Icons.help),
              onPressed: _showHelpMenu,
              iconSize: 35,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Lottie.asset('assets/loading.json'),
            )
          : recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No favorited recipes yet!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Use the heart icon to add recipes to your favorites.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;

                    // Check if the screen width is less than 600 pixels
                    if (screenWidth < 600) {
                      // Call the function for small screens (e.g., MasonryGridView layout)
                      return _buildMobileLayout();
                    } else {
                      // Call the function for larger screens (e.g., GridView layout with 4 items)
                      return _buildDesktopLayout();
                    }
                  },
                ),
    );
  }

// Function for mobile layout with MasonryGridView
  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MasonryGridView.count(
        crossAxisCount: 2, // 2 columns for mobile view
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
        itemCount: recipes.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          List<String> steps = [];
          if (recipes[index]['steps'] != null) {
            steps = (recipes[index]['steps'] as String).split('<');
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              double randomHeight = (index % 5 + 1) * 100;
              double minHeight = 200; // Set your minimum height here
              double finalHeight =
                  randomHeight < minHeight ? minHeight : randomHeight;

              return Container(
                height: finalHeight,
                child: RecipeCard(
                  recipeID: recipes[index]['recipeId'] ?? '',
                  name: recipes[index]['name'] ?? '',
                  description: recipes[index]['description'] ?? '',
                  imagePath: recipes[index]['photo'] ?? 'assets/emptyPlate.jpg',
                  prepTime: recipes[index]['preptime'] ?? 0,
                  cookTime: recipes[index]['cooktime'] ?? 0,
                  cuisine: recipes[index]['cuisine'] ?? '',
                  spiceLevel: recipes[index]['spicelevel'] ?? 0,
                  course: recipes[index]['course'] ?? '',
                  servings: recipes[index]['servings'] ?? 0,
                  steps: steps,
                  appliances: List<String>.from(recipes[index]['appliances']),
                  ingredients: List<Map<String, dynamic>>.from(
                      recipes[index]['ingredients']),
                ),
              );
            },
          );
        },
      ),
    );
  }

// Function for desktop layout with 4 columns
  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      key: ValueKey('Favourites'),
      padding: const EdgeInsets.all(30.0),
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

              double crossAxisSpacing = width * 0.01;
              double mainAxisSpacing = width * 0.02;

              // Determine the number of columns based on screen width
              int crossAxisCount = 4; // Default for larger screens
              if (width < 600) {
                crossAxisCount = 2; // Mobile view with smaller width
              }

              return GridView.builder(
                shrinkWrap: true,
                physics:
                    NeverScrollableScrollPhysics(), // Prevent GridView from scrolling
                itemCount: recipes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, index) {
                  List<String> steps = [];
                  if (recipes[index]['steps'] != null) {
                    steps = (recipes[index]['steps'] as String).split('<');
                  }

                  return RecipeCard(
                    recipeID: recipes[index]['recipeId'] ?? '',
                    name: recipes[index]['name'] ?? '',
                    description: recipes[index]['description'] ?? '',
                    imagePath:
                        recipes[index]['photo'] ?? 'assets/emptyPlate.jpg',
                    prepTime: recipes[index]['preptime'] ?? 0,
                    cookTime: recipes[index]['cooktime'] ?? 0,
                    cuisine: recipes[index]['cuisine'] ?? '',
                    spiceLevel: recipes[index]['spicelevel'] ?? 0,
                    course: recipes[index]['course'] ?? '',
                    servings: recipes[index]['servings'] ?? 0,
                    steps: steps,
                    appliances: List<String>.from(recipes[index]['appliances']),
                    ingredients: List<Map<String, dynamic>>.from(
                        recipes[index]['ingredients']),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

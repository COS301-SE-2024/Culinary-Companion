import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import '../widgets/help_saved.dart';

import '../widgets/recipe_card.dart';

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
    setState(() {
      _userId = prefs.getString('userId');
      //print('Login successful: $_userId');
      if (_userId != null) {
        //print('here 1');
        fetchRecipes(); // Call fetchRecipes only if userId is loaded successfully
      }
    });
  }

  Future<void> fetchRecipes() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getUserFavourites', 'userId': _userId});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedRecipes = jsonDecode(response.body);

        for (var recipe in fetchedRecipes) {
          final String recipeId = recipe['recipeid'];
          await fetchRecipeDetails(recipeId);
        }
      } else {
        //print('Failed to load recipes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    }

    setState(() {
      _isLoading = false;
    });
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

        setState(() {
          recipes.add(fetchedRecipe);
        });
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
          : SingleChildScrollView(
              child: Padding(
                key: ValueKey('Favourites'),
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

                        double crossAxisSpacing = width * 0.01;
                        double mainAxisSpacing = width * 0.02;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: recipes.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: crossAxisSpacing,
                            mainAxisSpacing: mainAxisSpacing,
                            childAspectRatio: aspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            // List<String> keywords =
                            //     (recipes[index]['keywords'] as String?)
                            //             ?.split(', ') ??
                            //         [];
                            List<String> steps = [];
                            if (recipes[index]['steps'] != null) {
                              steps = (recipes[index]['steps'] as String)
                                  .split(',');
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
                              appliances: List<String>.from(
                                  recipes[index]['appliances']),
                              ingredients: List<Map<String, dynamic>>.from(
                                  recipes[index]['ingredients']),
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

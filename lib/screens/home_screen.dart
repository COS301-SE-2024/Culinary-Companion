import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/recipe_card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllRecipes();
  }

  Future<void> fetchAllRecipes() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getAllRecipes'});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedRecipes = jsonDecode(response.body);

        // Fetch detailed recipes for each recipe ID
        for (var recipe in fetchedRecipes) {
          final String recipeId = recipe['recipeid'];
          await fetchRecipeDetails(recipeId);
        }
      } else {
        print('Failed to load recipes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    } finally {
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

        setState(() {
          recipes.add(fetchedRecipe);
        });
      } else {
        print('Failed to load recipe details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipe details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
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
                            List<String> keywords =
                                (recipes[index]['keywords'] as String?)
                                        ?.split(', ') ??
                                    [];
                            List<String> steps = [];
                            if (recipes[index]['steps'] != null) {
                              steps = (recipes[index]['steps'] as String)
                                  .split(',');
                            }

                            return RecipeCard(
                              name: recipes[index]['name'] ?? '',
                              description: recipes[index]['description'] ?? '',
                              imagePath: recipes[index]['photo'] ??
                                  'assets/pfp.jpg',
                              prepTime: recipes[index]['preptime'] ?? 0,
                              cookTime: recipes[index]['cooktime'] ?? 0,
                              cuisine: recipes[index]['cuisine'] ?? '',
                              spiceLevel: recipes[index]['spicelevel'] ?? 0,
                              course: recipes[index]['course'] ?? '',
                              servings: recipes[index]['servings'] ?? 0,
                              keyWords: keywords,
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

import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import '../widgets/recipe_card.dart';
import '../widgets/help_home.dart';

// import '../gemini_service.dart'; // LLM

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> recipes = [];
  bool _isLoading = true;
  bool _isGridView = false;
  String _selectedCategory = '';
  OverlayEntry? _helpMenuOverlay;
  // String _generatedText = '';  // LLM

  // Future<void> _loadContent() async {  // LLM
  // fetchKeywords
  // fetchIngredientSubstitution
  // fetchDietaryConstraints
  // final content = await fetchKeywords("7e739692-fedd-4843-b236-80cf0d23d497"); // get recipeId and put here
  // setState(() {
  //   _generatedText = content;
  // });
  // }

  @override
  void initState() {
    super.initState();
    fetchAllRecipes();
    // _fetchContent();
  }
  //   Future<void> _fetchContent() async {
  //   final apiKey = dotenv.env['API_KEY'] ?? '';
  //   if (apiKey.isEmpty) {
  //     setState(() {
  //       _generatedText = 'No \$API_KEY environment variable';
  //     });
  //     return;
  //   }

  //   final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  //   final content = [Content.text('Write a story about a magic backpack.')];
  //   final response = await model.generateContent(content);

  //   setState(() {
  //     _generatedText = response.text!;
  //   });
  // }

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

        // Fetch details concurrently
        final detailFetches = fetchedRecipes.map((recipe) {
          final String recipeId = recipe['recipeid'];
          return fetchRecipeDetails(recipeId);
        }).toList();

        await Future.wait(detailFetches);
      } else {
        print('Failed to load recipes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    }
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

  List<Map<String, dynamic>> _filterRecipesByCourse(String course) {
    return recipes.where((recipe) => recipe['course'] == course).toList();
  }

  Widget _buildRecipeList(
      String title, List<Map<String, dynamic>> filteredRecipes) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    double screenWidth = MediaQuery.of(context).size.width;
    double desiredCardsVisible = 4;
    double cardWidth = (screenWidth - (16.0 * (desiredCardsVisible + 1))) /
        desiredCardsVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isGridView = true;
                    _selectedCategory = title;
                  });
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenWidth * 0.3, // Keep the height consistent
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              List<String> steps = recipe['steps'] != null
                  ? (recipe['steps'] as String).split('<')
                  : [];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: cardWidth, // Adjust width dynamically to fit 4 cards
                  child: RecipeCard(
                    recipeID: recipe['recipeId'] ?? '',
                    name: recipe['name'] ?? '',
                    description: recipe['description'] ?? '',
                    imagePath: recipe['photo'] ?? 'assets/emptyPlate.jpg',
                    prepTime: recipe['preptime'] ?? 0,
                    cookTime: recipe['cooktime'] ?? 0,
                    cuisine: recipe['cuisine'] ?? '',
                    spiceLevel: recipe['spicelevel'] ?? 0,
                    course: recipe['course'] ?? '',
                    servings: recipe['servings'] ?? 0,
                    steps: steps,
                    appliances: List<String>.from(recipe['appliances']),
                    ingredients:
                        List<Map<String, dynamic>>.from(recipe['ingredients']),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridView() {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize;
    double backArrow;
    String category;

    if (screenWidth > 1334) {
      titleFontSize = 30.0;
      backArrow = 30;
    } else if (screenWidth > 820) {
      titleFontSize = 24.0;
      backArrow = 24;
    } else if (screenWidth < 375) {
      titleFontSize = 18.0;
      backArrow = 18;
    } else {
      titleFontSize = 16.0;
      backArrow = 16; // default size for widths between 375 and 980
    }

    if (_selectedCategory == 'Mains') {
      _selectedCategory = 'Main';
      category = 'Mains';
    } else {
      category = _selectedCategory;
    }

    List<Map<String, dynamic>> filteredRecipes =
        _filterRecipesByCourse(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isGridView = false;
                    _selectedCategory = '';
                  });
                },
                child: Icon(Icons.arrow_back, size: backArrow),
              ),
              SizedBox(width: 10),
              Text(
                category,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double itemWidth = 250;
            double itemHeight = 320;
            double aspectRatio = itemWidth / itemHeight;
            double crossAxisSpacing = width * 0.01;
            double mainAxisSpacing = width * 0.02;

            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredRecipes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                List<String> steps = [];
                if (filteredRecipes[index]['steps'] != null) {
                  steps =
                      (filteredRecipes[index]['steps'] as String).split(',');
                }

                return RecipeCard(
                  recipeID: filteredRecipes[index]['recipeId'] ?? '',
                  name: filteredRecipes[index]['name'] ?? '',
                  description: filteredRecipes[index]['description'] ?? '',
                  imagePath: filteredRecipes[index]['photo'] ??
                      'assets/emptyPlate.jpg',
                  prepTime: filteredRecipes[index]['preptime'] ?? 0,
                  cookTime: filteredRecipes[index]['cooktime'] ?? 0,
                  cuisine: filteredRecipes[index]['cuisine'] ?? '',
                  spiceLevel: filteredRecipes[index]['spicelevel'] ?? 0,
                  course: filteredRecipes[index]['course'] ?? '',
                  servings: filteredRecipes[index]['servings'] ?? 0,
                  steps: steps,
                  appliances:
                      List<String>.from(filteredRecipes[index]['appliances']),
                  ingredients: List<Map<String, dynamic>>.from(
                      filteredRecipes[index]['ingredients']),
                );
              },
            );
          },
        ),
      ],
    );
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
          ? Center(child: Lottie.asset('assets/loading.json'))
          : _isGridView
              ? SingleChildScrollView(
                  child: _buildGridView(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    key: ValueKey('Home'),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(height: 24),
                        //    Text(
                        //   _generatedText,
                        //   style: TextStyle(fontSize: 18),
                        //   textAlign: TextAlign.center,
                        // ),
                        // SizedBox(height: 16),
                        // Text(_generatedText), // LLM
                        // SizedBox(height: 20),
                        // ElevatedButton(
                        //   onPressed: _loadContent,
                        //   child: Text('Fetch Content'),
                        // ),
                        SizedBox(height: 24),
                        _buildRecipeList(
                            'Mains', _filterRecipesByCourse('Main')),
                        _buildRecipeList(
                            'Breakfast', _filterRecipesByCourse('Breakfast')),
                        _buildRecipeList(
                            'Appetizer', _filterRecipesByCourse('Appetizer')),
                        _buildRecipeList(
                            'Dessert', _filterRecipesByCourse('Dessert')),
                      ],
                    ),
                  ),
                ),
    );
  }
}

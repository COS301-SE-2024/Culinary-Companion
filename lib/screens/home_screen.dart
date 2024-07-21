// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:lottie/lottie.dart';
// import '../widgets/recipe_card.dart';
// import '../widgets/help_home.dart';

// import 'package:carousel_slider/carousel_slider.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<Map<String, dynamic>> recipes = [];
//   bool _isLoading = true;
//   OverlayEntry? _helpMenuOverlay;

//   @override
//   void initState() {
//     super.initState();
//     fetchAllRecipes();
//   }

//   Future<void> fetchAllRecipes() async {
//     final url =
//         'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
//     final headers = <String, String>{'Content-Type': 'application/json'};
//     final body = jsonEncode({'action': 'getAllRecipes'});

//     try {
//       final response =
//           await http.post(Uri.parse(url), headers: headers, body: body);

//       if (response.statusCode == 200) {
//         final List<dynamic> fetchedRecipes = jsonDecode(response.body);

//         // Fetch details concurrently
//         final detailFetches = fetchedRecipes.map((recipe) {
//           final String recipeId = recipe['recipeid'];
//           return fetchRecipeDetails(recipeId);
//         }).toList();

//         await Future.wait(detailFetches);
//       } else {
//         print('Failed to load recipes: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error fetching recipes: $error');
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> fetchRecipeDetails(String recipeId) async {
//     final url =
//         'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
//     final headers = <String, String>{'Content-Type': 'application/json'};
//     final body = jsonEncode({'action': 'getRecipe', 'recipeid': recipeId});

//     try {
//       final response =
//           await http.post(Uri.parse(url), headers: headers, body: body);

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> fetchedRecipe = jsonDecode(response.body);

//         setState(() {
//           recipes.add(fetchedRecipe);
//         });
//       } else {
//         print('Failed to load recipe details: ${response.statusCode}');
//       }
//     } catch (error) {
//       //print('Error fetching recipe details: $error');
//     }
//   }

//   void _showHelpMenu() {
//     _helpMenuOverlay = OverlayEntry(
//       builder: (context) => HelpMenu(
//         onClose: () {
//           _helpMenuOverlay?.remove();
//           _helpMenuOverlay = null;
//         },
//       ),
//     );
//     Overlay.of(context).insert(_helpMenuOverlay!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.transparent, //Color(0xFF20493C),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 20.0),
//             child: IconButton(
//               icon: Icon(Icons.help),
//               onPressed: _showHelpMenu,
//               iconSize: 35,
//             ),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: Lottie.asset('assets/loading.json'))
//           : SingleChildScrollView(
//               child: Padding(
//                 key: ValueKey('Home'),
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 24),
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         double width = constraints.maxWidth;
//                         double itemWidth = 276;
//                         double itemHeight = 320;
//                         double aspectRatio = itemWidth / itemHeight;

//                         double crossAxisSpacing = width * 0.01;
//                         double mainAxisSpacing = width * 0.02;

//                         return GridView.builder(
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemCount: recipes.length,
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 4,
//                             crossAxisSpacing: crossAxisSpacing,
//                             mainAxisSpacing: mainAxisSpacing,
//                             childAspectRatio: aspectRatio,
//                           ),
//                           itemBuilder: (context, index) {
//                             // List<String> keywords =
//                             //     (recipes[index]['keywords'] as String?)
//                             //             ?.split(', ') ??
//                             //         [];
//                             List<String> steps = [];
//                             if (recipes[index]['steps'] != null) {
//                               steps = (recipes[index]['steps'] as String)
//                                   .split(',');
//                             }

//                             return RecipeCard(
//                               recipeID: recipes[index]['recipeId'] ?? '',
//                               name: recipes[index]['name'] ?? '',
//                               description: recipes[index]['description'] ?? '',
//                               imagePath: recipes[index]['photo'] ??
//                                   'assets/emptyPlate.jpg',
//                               prepTime: recipes[index]['preptime'] ?? 0,
//                               cookTime: recipes[index]['cooktime'] ?? 0,
//                               cuisine: recipes[index]['cuisine'] ?? '',
//                               spiceLevel: recipes[index]['spicelevel'] ?? 0,
//                               course: recipes[index]['course'] ?? '',
//                               servings: recipes[index]['servings'] ?? 0,
//                               steps: steps,
//                               appliances: List<String>.from(
//                                   recipes[index]['appliances']),
//                               ingredients: List<Map<String, dynamic>>.from(
//                                   recipes[index]['ingredients']),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/recipe_card.dart';
import '../widgets/help_home.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> recipes = [];
  bool _isLoading = true;
  OverlayEntry? _helpMenuOverlay;

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

  // Widget _buildCarousel(
  //     String title, List<Map<String, dynamic>> filteredRecipes) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 16.0),
  //         child: Text(
  //           title,
  //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //       CarouselSlider(
  //         options: CarouselOptions(
  //           height: 320, // Match the height of GridView items
  //           enlargeCenterPage: false,
  //           enableInfiniteScroll: true,
  //           viewportFraction: 0.25, // Display 4 items at a time
  //           initialPage: 0, // Start from the first page
  //           scrollPhysics: BouncingScrollPhysics(), // Smooth scrolling
  //         ),
  //         items: filteredRecipes.map((recipe) {
  //           List<String> steps = [];
  //           if (recipe['steps'] != null) {
  //             steps = (recipe['steps'] as String).split(',');
  //           }

  //           return Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Container(
  //               width: 276, // Set the item width
  //               child: RecipeCard(
  //                 recipeID: recipe['recipeId'] ?? '',
  //                 name: recipe['name'] ?? '',
  //                 description: recipe['description'] ?? '',
  //                 imagePath: recipe['photo'] ?? 'assets/emptyPlate.jpg',
  //                 prepTime: recipe['preptime'] ?? 0,
  //                 cookTime: recipe['cooktime'] ?? 0,
  //                 cuisine: recipe['cuisine'] ?? '',
  //                 spiceLevel: recipe['spicelevel'] ?? 0,
  //                 course: recipe['course'] ?? '',
  //                 servings: recipe['servings'] ?? 0,
  //                 steps: steps,
  //                 appliances: List<String>.from(recipe['appliances']),
  //                 ingredients:
  //                     List<Map<String, dynamic>>.from(recipe['ingredients']),
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildCarousel(
      String title, List<Map<String, dynamic>> filteredRecipes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            double viewportWidth = constraints.maxWidth;
            double itemWidth = viewportWidth / 4 -
                16; // Divide the width by 4 and subtract padding
            double itemHeight =
                itemWidth * 320 / 276; // Maintain the aspect ratio

            return CarouselSlider(
              options: CarouselOptions(
                height: itemHeight,
                enlargeCenterPage: false,
                enableInfiniteScroll: true,
                viewportFraction: itemWidth / viewportWidth,
                initialPage: 0,
                scrollPhysics: BouncingScrollPhysics(),
              ),
              items: filteredRecipes.map((recipe) {
                List<String> steps = [];
                if (recipe['steps'] != null) {
                  steps = (recipe['steps'] as String).split(',');
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: itemWidth, // Set the item width dynamically
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
                      ingredients: List<Map<String, dynamic>>.from(
                          recipe['ingredients']),
                    ),
                  ),
                );
              }).toList(),
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    _buildCarousel('Main', _filterRecipesByCourse('Main')),
                    _buildCarousel(
                        'Breakfast', _filterRecipesByCourse('Breakfast')),
                    _buildCarousel(
                        'Appetizer', _filterRecipesByCourse('Appetizer')),
                    _buildCarousel(
                        'Dessert', _filterRecipesByCourse('Dessert')),
                  ],
                ),
              ),
            ),
    );
  }
}

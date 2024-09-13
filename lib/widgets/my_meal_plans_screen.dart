// ignore_for_file: unnecessary_to_list_in_spreads

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../widgets/recipe_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMealPlansScreen extends StatefulWidget {
  @override
  _MyMealPlanScreenState createState() => _MyMealPlanScreenState();
}

class _MyMealPlanScreenState extends State<MyMealPlansScreen> {
  String? _userId;
  List<Map<String, dynamic>> mealPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getString('userId');
        // //print('Login successful: $_userId');
        // if (_userId != null) {
        //   //print('here 1');
        //   fetchRecipes(); // Call fetchRecipes only if userId is loaded successfully
        // }
        fetchMealPlans();
      });
    }
  }

  Future<void> fetchMealPlans() async {
    if (_userId == null) return;

    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = {'Content-Type': 'application/json'};
    final body =
        jsonEncode({'action': 'getAllMealPlanners', 'userId': _userId});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        //print('here 1 $responseData');
        final List<dynamic> fetchedMealPlans = responseData['mealPlanners'];
        //print('here 2 $fetchedMealPlans');

        setState(() {
          mealPlans = fetchedMealPlans.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> mealPlan = entry.value;

            final parsedRecipes = jsonDecode(mealPlan['recipes'])['Meals']
                as Map<String, dynamic>;

            Map<String, List<Map<String, dynamic>>> days =
                parsedRecipes.map((day, recipes) {
              return MapEntry(
                day,
                List<Map<String, dynamic>>.from(recipes.map((recipe) => {
                      'recipeId': recipe['recipeid'],
                    })),
              );
            });

            return {
              'title': 'Meal Plan ${index + 1}',
              'isExpanded': false,
              'days': days,
            };
          }).toList();
        });

        // fetch recipe details
        await fetchAllRecipeDetails();
        setState(() {
          _isLoading = false;
        });
      } else {
        print('Failed to fetch meal plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching meal plans: $e');
    }
  }

  Future<void> fetchAllRecipeDetails() async {
    List<Future<void>> recipeFutures = [];

    for (var mealPlan in mealPlans) {
      for (var dayRecipes in mealPlan['days'].values) {
        for (var recipe in dayRecipes) {
          final String recipeId = recipe['recipeId'];
          recipeFutures.add(fetchRecipeDetails(recipeId, recipe));
        }
      }
    }

    await Future.wait(recipeFutures);
  }

  Future<void> fetchRecipeDetails(
      String recipeId, Map<String, dynamic> recipe) async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getRecipe', 'recipeid': recipeId});

    try {
      //print('Fetching recipe details for recipeId: $recipeId');

      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> fetchedRecipe = jsonDecode(response.body);
        recipe.addAll(fetchedRecipe);
      } else {
        print('Failed to load recipe details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipe details: $error');
    }
  }

  // Placeholder recipe data for each day of the week
  // Placeholder data for multiple meal plans
  // final List<Map<String, dynamic>> mealPlans = [
  //   {
  //     'title': 'Meal Plan 1',
  //     'isExpanded': false,
  //     'days': {
  //       'Monday': <Map<String,
  //           dynamic>>[], // Correcting type to List<Map<String, dynamic>>
  //       'Tuesday': <Map<String, dynamic>>[],
  //       'Wednesday': <Map<String, dynamic>>[],
  //       'Thursday': <Map<String, dynamic>>[],
  //       'Friday': <Map<String, dynamic>>[],
  //       'Saturday': <Map<String, dynamic>>[],
  //       'Sunday': <Map<String, dynamic>>[],
  //     },
  //   },
  //   {
  //     'title': 'Meal Plan 2',
  //     'isExpanded': false,
  //     'days': {
  //       'Monday': <Map<String,
  //           dynamic>>[], // Correcting type to List<Map<String, dynamic>>
  //       'Tuesday': <Map<String, dynamic>>[],
  //       'Wednesday': <Map<String, dynamic>>[],
  //       'Thursday': <Map<String, dynamic>>[],
  //       'Friday': <Map<String, dynamic>>[],
  //       'Saturday': <Map<String, dynamic>>[],
  //       'Sunday': <Map<String, dynamic>>[],
  //     },
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color backgroundColor =
        isLightTheme ? Colors.white : Color.fromARGB(255, 52, 68, 64);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(top: 30, left: 20),
          child: Text(
            'My Meal Plans',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(), // Loading spinner
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              children: [
                SizedBox(
                  height: 24.0,
                ),
                ExpansionPanelList(
                  elevation: 1,
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      mealPlans[index]['isExpanded'] = isExpanded;
                    });
                  },
                  children: mealPlans.map<ExpansionPanel>((mealPlan) {
                    return ExpansionPanel(
                      backgroundColor: backgroundColor,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text(
                            mealPlan['title'],
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      body: buildMealPlanContent(
                        mealPlan['days']
                            as Map<String, List<Map<String, dynamic>>>,
                        context,
                      ),
                      isExpanded: mealPlan['isExpanded'],
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  Widget buildMealPlanContent(
      Map<String, List<Map<String, dynamic>>> days, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 600 ? 300 : 150;
    double cardHeight = screenWidth > 600 ? 400 : 200;

    return Column(
      children: days.entries.map((entry) {
        String day = entry.key;
        List<Map<String, dynamic>> recipes = entry.value;
        bool hasMoreThanTwoMeals = recipes.length > 2;

        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        // Add functionality to show more info if needed
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: recipes.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> recipe = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              child: RecipeCard(
                                recipeID: recipe['recipeId'] ?? '',
                                name: recipe['name'] ?? 'Unknown Recipe',
                                description: recipe['description'] ??
                                    'No description available',
                                imagePath:
                                    recipe['photo'] ?? 'assets/emptyPlate.jpg',
                                prepTime: recipe['preptime'] ?? 0,
                                cookTime: recipe['cooktime'] ?? 0,
                                cuisine: recipe['cuisine'] ?? 'Unknown Cuisine',
                                spiceLevel: recipe['spicelevel'] ?? 0,
                                course: recipe['course'] ?? 'Unknown Course',
                                servings: recipe['servings'] ?? 1,
                                steps: (recipe['steps'] != null &&
                                        recipe['steps'] is String)
                                    ? (recipe['steps'] as String).split('<')
                                    : ['Step 1', 'Step 2'],
                                appliances: List<String>.from(
                                    recipe['appliances'] ??
                                        ['Unknown Appliance']),
                                ingredients: List<Map<String, dynamic>>.from(
                                    recipe['ingredients'] ??
                                        [
                                          {
                                            'name': 'Unknown Ingredient',
                                            'quantity': 'Unknown'
                                          }
                                        ]), // Handle null case
                              ),
                            ),
                            if (index < 2 && hasMoreThanTwoMeals)
                              Positioned(
                                right: 0,
                                top: cardHeight / 2 - 20,
                                child: Icon(Icons.arrow_forward_ios),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

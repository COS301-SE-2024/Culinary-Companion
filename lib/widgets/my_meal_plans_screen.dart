// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import '../widgets/recipe_card.dart';

class MyMealPlansScreen extends StatefulWidget {
  @override
  _MyMealPlanScreenState createState() => _MyMealPlanScreenState();
}

class _MyMealPlanScreenState extends State<MyMealPlansScreen> {
  // Placeholder recipe data for each day of the week
  // Placeholder data for multiple meal plans
  final List<Map<String, dynamic>> mealPlans = [
    {
      'title': 'Meal Plan 1',
      'isExpanded': false,
      'days': {
        'Monday': <Map<String,
            dynamic>>[], // Correcting type to List<Map<String, dynamic>>
        'Tuesday': <Map<String, dynamic>>[],
        'Wednesday': <Map<String, dynamic>>[],
        'Thursday': <Map<String, dynamic>>[],
        'Friday': <Map<String, dynamic>>[],
        'Saturday': <Map<String, dynamic>>[],
        'Sunday': <Map<String, dynamic>>[],
      },
    },
    {
      'title': 'Meal Plan 2',
      'isExpanded': false,
      'days': {
        'Monday': <Map<String,
            dynamic>>[], // Correcting type to List<Map<String, dynamic>>
        'Tuesday': <Map<String, dynamic>>[],
        'Wednesday': <Map<String, dynamic>>[],
        'Thursday': <Map<String, dynamic>>[],
        'Friday': <Map<String, dynamic>>[],
        'Saturday': <Map<String, dynamic>>[],
        'Sunday': <Map<String, dynamic>>[],
      },
    },
  ];

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
      body: ListView(
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
                  mealPlan['days'] as Map<String, List<Map<String, dynamic>>>,
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

    // Define card dimensions based on screen size
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
                    children: [
                      // ...recipes.map((recipe) {
                      //   return Padding(
                      //       padding: const EdgeInsets.only(right: 8.0),
                      //       child: SizedBox(
                      //         width: cardWidth,
                      //         height: cardHeight,
                      //         child: RecipeCard(
                      //           recipeID: recipe['recipeId'] ?? '',
                      //           name: recipe['name'] ?? 'Recipe Name',
                      //           description:
                      //               recipe['description'] ?? 'Description here',
                      //           imagePath: recipe['photo'] ??
                      //               'assets/placeholder_image.jpg',
                      //           prepTime: recipe['preptime'] ?? 0,
                      //           cookTime: recipe['cooktime'] ?? 0,
                      //           cuisine: recipe['cuisine'] ?? 'Cuisine',
                      //           spiceLevel: recipe['spicelevel'] ?? 0,
                      //           course: recipe['course'] ?? 'Main Course',
                      //           servings: recipe['servings'] ?? 1,
                      //           steps: ['Step 1', 'Step 2'],
                      //           appliances: ['Oven', 'Stove'],
                      //           ingredients: [
                      //             {'name': 'Ingredient 1', 'quantity': '100g'}
                      //           ],
                      //         ),
                      //       ));
                      // }).toList(),
                      ...recipes.asMap().entries.map((entry) {
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
                                  name: recipe['name'] ?? 'Recipe Name',
                                  description: recipe['description'] ??
                                      'Description here',
                                  imagePath: recipe['photo'] ??
                                      'assets/placeholder_image.jpg',
                                  prepTime: recipe['preptime'] ?? 0,
                                  cookTime: recipe['cooktime'] ?? 0,
                                  cuisine: recipe['cuisine'] ?? 'Cuisine',
                                  spiceLevel: recipe['spicelevel'] ?? 0,
                                  course: recipe['course'] ?? 'Main Course',
                                  servings: recipe['servings'] ?? 1,
                                  steps: ['Step 1', 'Step 2'],
                                  appliances: ['Oven', 'Stove'],
                                  ingredients: [
                                    {'name': 'Ingredient 1', 'quantity': '100g'}
                                  ],
                                ),
                              ),
                              // Conditionally add the arrow icon
                              if (index < 2 && hasMoreThanTwoMeals)
                                Positioned(
                                  right: 0,
                                  top: cardHeight / 2 -
                                      20, // Center the arrow vertically
                                  child: Icon(Icons.arrow_forward_ios),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      if (recipes.isEmpty)
                        ...List.generate(
                            3,
                            (index) => PlaceholderRecipeCard(
                                width: cardWidth, height: cardHeight)).toList(),
                    ],
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

class PlaceholderRecipeCard extends StatelessWidget {
  final double width;
  final double height;

  PlaceholderRecipeCard({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          'Placeholder Recipe',
          style: TextStyle(color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

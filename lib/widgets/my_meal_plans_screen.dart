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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(top: 30, left: 38.0),
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
        padding: const EdgeInsets.symmetric(horizontal: 38.0),
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
                body: buildMealPlanContent(mealPlan['days']
                    as Map<String, List<Map<String, dynamic>>>),
                isExpanded: mealPlan['isExpanded'],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildMealPlanContent(Map<String, List<Map<String, dynamic>>> days) {
    return Column(
      children: days.entries.map((entry) {
        String day = entry.key;
        List<Map<String, dynamic>> recipes = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                      ...recipes.map((recipe) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: RecipeCard(
                            recipeID: recipe['recipeId'] ?? '',
                            name: recipe['name'] ?? 'Recipe Name',
                            description:
                                recipe['description'] ?? 'Description here',
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
                        );
                      }).toList(),
                      if (recipes.isEmpty)
                        ...List.generate(2, (index) => PlaceholderRecipeCard())
                            .toList(),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 200,
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

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import '../widgets/recipe_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  //List<String> _searchResults = [];

  // List<String> _recipeList = [
  //   'Recipe 1',
  //   'Recipe 2',
  //   'Recipe 3',
  //   'Recipe 4',
  //   'Recipe 5'
  // ]; //Get these from the database!!!

  final List<String> _courses = ['Main', 'Breakfast', 'Appetizer', 'Dessert'];

  List<String> cuisineType = [];

  List<String> dietaryOptions = [
     'Vegan'
    'Vegetarian',
    'Gluten-Free',
    'Lactose-Free',
    'No Banana',
    'No Nuts',
    'High Protein',
    'High Calorie',
    'Low Calorie',
    'Low Carb',
    'Low Sugar'
  ]; //Change these so it is fetched from database!!!

  // List<String> ingredientOptions = [
  //   'Need 1 Extra Ingredient',
  //   'Mostly in My Pantry',
  //   'All Ingredients Available'
  // ]; //double check these options!!

  List<String> spiceLevelOptions = [
    'None', //1
    'Mild',
    'Medium',
    'Hot',
    'Extra Hot' //5
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    
  }

  Future<void> _initializeData() async {
    await _loadCuisines();
    await _loadDietaryConstraints();
    //fetchRecipes();
  }

  Future<void> _loadDietaryConstraints() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({'action': 'getDietaryConstraints'}));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          dietaryOptions = data.map<String>((constraint) {
            return constraint['name'].toString();
          }).toList();
        });
        //print('here');
      } else {
        throw Exception('Failed to load dietary constraints');
      }
    } catch (e) {
      throw Exception('Error fetching dietary constraints: $e');
    }
  }

  Future<void> _loadCuisines() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'action': 'getCuisines'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // Ensure the UI updates after cuisines are loaded
          cuisineType = data.map<String>((cuisine) {
            return cuisine['name'].toString();
          }).toList();
        });
        //print(_cuisines);
      } else {
        throw Exception('Failed to load cuisines');
      }
    } catch (e) {
      throw Exception('Error fetching cuisines: $e');
    }
  }

  List<Map<String, dynamic>> recipes = [];
  bool _isLoading = false;


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

  List<String> selectedCourseTypeOptions = [];
  List<String> selectedCuisineType = [];
  List<String> selectedDietaryOptions = [];
  String? selectedSpiceLevel;
  String? selectedIngredientOption;

  void _performSearch(String query) async {
  if (query.isEmpty) return;

  setState(() {
    _isLoading = true;
  });

  final url =
      'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
  final headers = <String, String>{'Content-Type': 'application/json'};
  final body = jsonEncode({'action': 'searchRecipes', 'searchTerm': query});

  try {
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final List<dynamic> fetchedRecipeIds = jsonDecode(response.body);
      setState(() {
        recipes.clear(); //clear recipes 
      });

     
      for (var recipe in fetchedRecipeIds) {
        final String recipeId = recipe['recipeid']; //fetch rec details for each rec
        await fetchRecipeDetails(recipeId);
      }
    } else {
      print('Failed to load search results: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching search results: $error');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

void _performFilter() async {
  setState(() {
    _isLoading = true;
  });

  Filters filters = Filters(
    course: selectedCourseTypeOptions,
    spiceLevel: selectedSpiceLevel != null ? int.tryParse(selectedSpiceLevel!) : null,
    cuisine: selectedCuisineType,
    dietaryOptions: selectedDietaryOptions,
    ingredientOption: selectedIngredientOption,
  );

  final url = 'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
  final headers = <String, String>{'Content-Type': 'application/json'};
  final body = jsonEncode({
    'action': 'filterRecipes',
    'filters': filters.toJson(),
  });

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final List<dynamic> fetchedRecipeIds = jsonDecode(response.body);
      setState(() {
        recipes.clear(); //clear the current recipes 
      });

      
      for (var recipe in fetchedRecipeIds) {
        final String recipeId = recipe['recipeid']; //fetch recpe details for each recipe
        await fetchRecipeDetails(recipeId);
      }
    } else {
      print('Failed to load filtered recipes: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching filtered recipes: $error');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _openFilterModal() {
  final theme = Theme.of(context);
  final bool isLightTheme = theme.brightness == Brightness.light;
  final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

  // Temporary variables to hold selections within the modal
  List<String> tempDietaryOptions = List.from(selectedDietaryOptions);
  List<String> tempCourseOptions = List.from(selectedCourseTypeOptions);
  List<String> tempCuisineOptions = List.from(selectedCuisineType);
  int? tempSpiceLevel = selectedSpiceLevel != null ? _spiceLevelToInt(selectedSpiceLevel!) : null;
  String? tempIngredientOption = selectedIngredientOption;

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Text('Dietary Constraints:', style: TextStyle(fontSize: 16)),
                  Wrap(
                    spacing: 8.0,
                    children: dietaryOptions.map((option) {
                      return ChoiceChip(
                        label: Text(option),
                        selected: tempDietaryOptions.contains(option),
                        onSelected: (isSelected) {
                          setState(() {
                            isSelected ? tempDietaryOptions.add(option) : tempDietaryOptions.remove(option);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 15),
                  Text('Course Type:', style: TextStyle(fontSize: 16)),
                  Wrap(
                    spacing: 8.0,
                    children: _courses.map((option) {
                      return ChoiceChip(
                        label: Text(option),
                        selected: tempCourseOptions.contains(option),
                        onSelected: (isSelected) {
                          setState(() {
                            isSelected ? tempCourseOptions.add(option) : tempCourseOptions.remove(option);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 15),
                  Text('Cuisine Type:', style: TextStyle(fontSize: 16)),
                  Wrap(
                    spacing: 8.0,
                    children: cuisineType.map((option) {
                      return ChoiceChip(
                        label: Text(option),
                        selected: tempCuisineOptions.contains(option),
                        onSelected: (isSelected) {
                          setState(() {
                            isSelected ? tempCuisineOptions.add(option) : tempCuisineOptions.remove(option);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 15),
                  Text('Spice Level:', style: TextStyle(fontSize: 16)),
                  Wrap(
                    spacing: 8.0,
                    children: spiceLevelOptions.map((option) {
                      return ChoiceChip(
                        label: Text(option),
                        selected: tempSpiceLevel == _spiceLevelToInt(option),
                        onSelected: (isSelected) {
                          setState(() {
                            tempSpiceLevel = isSelected ? _spiceLevelToInt(option) : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  // SizedBox(height: 15),
                  // Text('Ingredients:', style: TextStyle(fontSize: 16)),
                  // Wrap(
                  //   spacing: 8.0,
                  //   children: ingredientOptions.map((option) {
                  //     return ChoiceChip(
                  //       label: Text(option),
                  //       selected: tempIngredientOption == option,
                  //       onSelected: (isSelected) {
                  //         setState(() {
                  //           tempIngredientOption = isSelected ? option : null;
                  //         });
                  //       },
                  //     );
                  //   }).toList(),
                  // ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempDietaryOptions.clear();
                            tempCourseOptions.clear();
                            tempCuisineOptions.clear();
                            tempSpiceLevel = null;
                            tempIngredientOption = null;
                          });
                        },
                        child: Text('RESET', style: TextStyle(color: textColor)),
                      ),
                      ElevatedButton(
                        child: Text('APPLY', style: TextStyle(color: textColor)),
                        onPressed: () {
                          // Update the main state with the selections
                          setState(() {
                            selectedDietaryOptions = tempDietaryOptions;
                            selectedCourseTypeOptions = tempCourseOptions;
                            selectedCuisineType = tempCuisineOptions;
                            selectedSpiceLevel = tempSpiceLevel != null ? tempSpiceLevel.toString() : null;
                            selectedIngredientOption = tempIngredientOption;
                          });

                          // Call the filter function
                          _performFilter();

                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Helper function to convert spice level string to int
int? _spiceLevelToInt(String? spiceLevel) {
  if (spiceLevel == null) return null;
  switch (spiceLevel) {
    case 'None':
      return 1;
    case 'Mild':
      return 2;
    case 'Medium':
      return 3;
    case 'Hot':
      return 4;
    case 'Extra Hot':
      return 5;
    default:
      return null;
  }
}

String _intToSpiceLevel(int? spiceLevel) {
  if (spiceLevel == null) return '';
  switch (spiceLevel) {
    case 1:
      return 'None';
    case 2:
      return 'Mild';
    case 3:
      return 'Medium';
    case 4:
      return 'Hot';
    case 5:
      return 'Extra Hot';
    default:
      return '';
  }
}



  Widget _buildFilterChips() {
    List<Widget> chips = [];

    if (selectedCuisineType.isNotEmpty) {
      chips.addAll(
          selectedCuisineType.map((option) => Chip(label: Text(option))));
    }

    if (selectedCourseTypeOptions.isNotEmpty) {
      chips.addAll(
          selectedCourseTypeOptions.map((option) => Chip(label: Text(option))));
    }

   if (selectedSpiceLevel != null) {
    chips.add(Chip(label: Text(_intToSpiceLevel(int.parse(selectedSpiceLevel!)))));
  }

    if (selectedIngredientOption != null) {
      chips.add(Chip(label: Text(selectedIngredientOption!)));
    }

    if (selectedDietaryOptions.isNotEmpty) {
      chips.addAll(
          selectedDietaryOptions.map((option) => Chip(label: Text(option))));
    }

    return Wrap(
      spacing: 8.0,
      children: chips,
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final theme = Theme.of(context);
  //   final bool isLightTheme = theme.brightness == Brightness.light;
  //   final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

  //   return Scaffold(
  //     appBar: AppBar(
  //       automaticallyImplyLeading: false,
  //       backgroundColor: Colors.transparent,
  //     ),
  //     body: Padding(
  //       padding: EdgeInsets.all(16.0),
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: TextField(
  //                   controller: _searchController,
  //                   cursorColor: textColor,
  //                   decoration: InputDecoration(
  //                     focusedBorder: OutlineInputBorder(
  //                       borderSide: BorderSide(color: textColor),
  //                       borderRadius: BorderRadius.circular(20),
  //                     ),
  //                     border: OutlineInputBorder(
  //                       borderSide: BorderSide(color: textColor),
  //                       borderRadius: BorderRadius.circular(20),
  //                     ),
  //                     labelText: 'Search',
  //                     labelStyle: TextStyle(color: textColor),
  //                     suffixIcon: IconButton(
  //                       icon: Icon(Icons.search),
  //                       onPressed: () => _performSearch(_searchController.text),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               IconButton(
  //                 icon: Icon(Icons.filter_alt_rounded),
  //                 color: textColor,
  //                 onPressed: _openFilterModal,
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 10),
  //           _buildFilterChips(),
  //           SizedBox(height: 20),
  //           CarouselSlider(
  //             options: CarouselOptions(
  //               height: 200.0,
  //               autoPlay: true,
  //               enlargeCenterPage: true,
  //             ),
  //             items: _recipeList.map((recipe) {
  //               return Builder(
  //                 builder: (BuildContext context) {
  //                   return Container(
  //                     width: MediaQuery.of(context).size.width,
  //                     margin: EdgeInsets.symmetric(horizontal: 5.0),
  //                     decoration: BoxDecoration(
  //                       color: Colors.amber,
  //                     ),
  //                     child: Center(
  //                       child: Text(
  //                         recipe,
  //                         style: TextStyle(fontSize: 16.0),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               );
  //             }).toList(),
  //           ),
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: _searchResults.length,
  //               itemBuilder: (context, index) {
  //                 return ListTile(
  //                   title: Text(_searchResults[index]),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

 @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final bool isLightTheme = theme.brightness == Brightness.light;
  final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
    ),
    body: Stack(
      children: [
        // Main content
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        cursorColor: textColor,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: 'Search',
                          labelStyle: TextStyle(color: textColor),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () => _performSearch(_searchController.text),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_alt_rounded),
                      color: textColor,
                      onPressed: _openFilterModal,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _buildFilterChips(),
                SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    double width = constraints.maxWidth;
                    double crossAxisSpacing = width * 0.01;
                    double mainAxisSpacing = width * 0.02;
                    double itemWidth = 276;
                    double itemHeight = 320;
                    double aspectRatio = itemWidth / itemHeight;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recipes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // Number of columns
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing,
                        childAspectRatio: aspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        List<String> steps = [];
                        if (recipes[index]['steps'] != null) {
                          steps = (recipes[index]['steps'] as String).split(',');
                        }

                        return RecipeCard(
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
                          ingredients: List<Map<String, dynamic>>.from(recipes[index]['ingredients']),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Lottie.asset('assets/loading.json'),
            ),
          ),
      ],
    ),
  );
}
}

class Filters {
  List<String>? course;
  int? spiceLevel;
  List<String>? cuisine;
  List<String>? dietaryOptions;
  String? ingredientOption;

  Filters({
    this.course,
    this.spiceLevel,
    this.cuisine,
    this.dietaryOptions,
    this.ingredientOption,
  });

  Map<String, dynamic> toJson() {
    return {
      'course': course,
      'spiceLevel': spiceLevel,
      'cuisine': cuisine,
      'dietaryOptions': dietaryOptions,
      'ingredientOption': ingredientOption,
    };
  }
}

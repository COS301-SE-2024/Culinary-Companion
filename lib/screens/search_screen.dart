import 'package:flutter/material.dart';
//import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import '../widgets/recipe_card.dart';
import '../widgets/help_search.dart';
import '../widgets/filter_recipes.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  OverlayEntry? _helpMenuOverlay;

  final List<String> _courses = ['Main', 'Breakfast', 'Appetizer', 'Dessert'];
  List<String> cuisineType = [];
  List<String> dietaryOptions = [];
  Timer? _debounce;
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
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Perform the search only when the user has stopped typing for 500ms
      _performSearch(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchAllRecipes();
    await _loadCuisines();
    await _loadDietaryConstraints();
  }

  Future<void> fetchAllRecipes() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getAllRecipes'});

    try {
      // Load cached recipes to avoid re-fetching if already available
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedRecipes = prefs.getString('cached_all_recipes');

      if (cachedRecipes != null && recipes.isEmpty) {
        setState(() {
          recipes = List<Map<String, dynamic>>.from(jsonDecode(cachedRecipes));
        });
      }

      // Fetch fresh recipes from Supabase
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedRecipes = jsonDecode(response.body);

        // Clear the recipes list to avoid duplication
        recipes.clear();

        // Fetch recipe details in parallel using Future.wait for faster results
        List<Future<void>> detailFetches = fetchedRecipes.map((recipe) {
          final String recipeId = recipe['recipeid'];
          return fetchRecipeDetails(recipeId); // Fetch in parallel
        }).toList();

        await Future.wait(detailFetches);

        // Cache the fetched recipes
        await prefs.setString('cached_all_recipes', jsonEncode(recipes));
      } else {
        print('Failed to load recipes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    }

    if (mounted) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _loadDietaryConstraints() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({'action': 'getDietaryConstraints'}));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            dietaryOptions = data.map<String>((constraint) {
              return constraint['name'].toString();
            }).toList();

            // Sort the dietary constraints alphabetically, but put "None" at the end
            dietaryOptions.sort((a, b) {
              if (a.toLowerCase() == 'none') return 1; // Put "None" at the end
              if (b.toLowerCase() == 'none') return -1;
              return a.toLowerCase().compareTo(b.toLowerCase());
            });
          });
        }
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
        if (mounted) {
          setState(() {
            // Ensure the UI updates after cuisines are loaded
            cuisineType = data.map<String>((cuisine) {
              return cuisine['name'].toString();
            }).toList();

            // Sort cuisines alphabetically, but put "None" at the end
            cuisineType.sort((a, b) {
              if (a.toLowerCase() == 'none') return 1; // Put "None" at the end
              if (b.toLowerCase() == 'none') return -1;
              return a.toLowerCase().compareTo(b.toLowerCase());
            });
          });
        }
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

  List<String> selectedCourseTypeOptions = [];
  List<String> selectedCuisineType = [];
  List<String> selectedDietaryOptions = [];
  String? selectedSpiceLevel;
  String? selectedIngredientOption;

  void _performSearch(String query) async {
    if (query.isEmpty) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'searchRecipes', 'searchTerm': query});

    try {
      // Load search results from Supabase
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedRecipeIds = jsonDecode(response.body);
        setState(() {
          recipes.clear(); // Clear the current list of recipes
        });

        // Fetch recipe details in parallel for search results
        final detailFetches = fetchedRecipeIds.map((recipe) {
          final String recipeId = recipe['recipeid'];
          return fetchRecipeDetails(recipeId);
        }).toList();

        await Future.wait(detailFetches);
      } else {
        print('Failed to load search results: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching search results: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchController.clear();
        });
      }
    }
  }

  void _performFilter() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Perform filtering on cached recipes when possible
    Filters filters = Filters(
      course: selectedCourseTypeOptions,
      spiceLevel:
          selectedSpiceLevel != null ? int.tryParse(selectedSpiceLevel!) : null,
      cuisine: selectedCuisineType,
      dietaryOptions: selectedDietaryOptions,
    );

    // Filter recipes locally first
    List<Map<String, dynamic>> filteredRecipes = recipes.where((recipe) {
      bool matchesCourse = selectedCourseTypeOptions.isEmpty ||
          selectedCourseTypeOptions.contains(recipe['course']);
      bool matchesCuisine = selectedCuisineType.isEmpty ||
          selectedCuisineType.contains(recipe['cuisine']);
      bool matchesSpiceLevel = selectedSpiceLevel == null ||
          recipe['spicelevel'] == int.tryParse(selectedSpiceLevel!);
      bool matchesDietary = selectedDietaryOptions.isEmpty ||
          selectedDietaryOptions
              .any((option) => recipe['dietary'].contains(option));

      return matchesCourse &&
          matchesCuisine &&
          matchesSpiceLevel &&
          matchesDietary;
    }).toList();

    if (filteredRecipes.isNotEmpty) {
      setState(() {
        recipes = filteredRecipes; // Update with locally filtered recipes
        _isLoading = false;
      });
      return;
    }

    // If no local matches, fetch filtered recipes from Supabase
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({
      'action': 'filterRecipes',
      'filters': filters.toJson(),
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedRecipeIds = jsonDecode(response.body);
        setState(() {
          recipes.clear(); // Clear the current recipes
          _searchController.clear();
        });

        // Fetch recipe details for filtered results
        List<Future<void>> detailFetches = fetchedRecipeIds.map((recipe) {
          final String recipeId = recipe['recipeid'];
          return fetchRecipeDetails(recipeId); // Fetch in parallel
        }).toList();

        await Future.wait(detailFetches);
      } else {
        print('Failed to load filtered recipes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching filtered recipes: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    int? tempSpiceLevel = selectedSpiceLevel != null
        ? _spiceLevelToInt(selectedSpiceLevel!)
        : null;
    //String? tempIngredientOption = selectedIngredientOption;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filter',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    Text('Dietary Constraints:',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8,
                      children: dietaryOptions.map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          selected: tempDietaryOptions.contains(option),
                          onSelected: (isSelected) {
                            if (mounted) {
                              setState(() {
                                isSelected
                                    ? tempDietaryOptions.add(option)
                                    : tempDietaryOptions.remove(option);
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text('Course Type:', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8,
                      children: _courses.map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          selected: tempCourseOptions.contains(option),
                          onSelected: (isSelected) {
                            if (mounted) {
                              setState(() {
                                isSelected
                                    ? tempCourseOptions.add(option)
                                    : tempCourseOptions.remove(option);
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text('Cuisine Type:', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8,
                      children: cuisineType.map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          selected: tempCuisineOptions.contains(option),
                          onSelected: (isSelected) {
                            if (mounted) {
                              setState(() {
                                isSelected
                                    ? tempCuisineOptions.add(option)
                                    : tempCuisineOptions.remove(option);
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text('Spice Level:', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8,
                      children: spiceLevelOptions.map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          selected: tempSpiceLevel == _spiceLevelToInt(option),
                          onSelected: (isSelected) {
                            if (mounted) {
                              setState(() {
                                tempSpiceLevel = isSelected
                                    ? _spiceLevelToInt(option)
                                    : null;
                              });
                            }
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
                            if (mounted) {
                              setState(() {
                                tempDietaryOptions.clear();
                                tempCourseOptions.clear();
                                tempCuisineOptions.clear();
                                tempSpiceLevel = null;
                                //tempIngredientOption = null;
                              });
                            }
                          },
                          child:
                              Text('RESET', style: TextStyle(color: textColor)),
                        ),
                        ElevatedButton(
                          child:
                              Text('APPLY', style: TextStyle(color: textColor)),
                          onPressed: () {
                            // Update the main state with the selections
                            if (mounted) {
                              setState(() {
                                selectedDietaryOptions = tempDietaryOptions;
                                selectedCourseTypeOptions = tempCourseOptions;
                                selectedCuisineType = tempCuisineOptions;
                                selectedSpiceLevel = tempSpiceLevel?.toString();
                                //selectedIngredientOption = tempIngredientOption;
                              });
                            }

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
      chips.add(
          Chip(label: Text(_intToSpiceLevel(int.parse(selectedSpiceLevel!)))));
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
                        Icons.search_off,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No recipes found!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Try adjusting your search or filters.',
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
                      return Column(
                        children: [
                          _buildSearchAndFilterBar(),
                          Expanded(child: _buildMobileLayout()),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildSearchAndFilterBar(),
                          Expanded(child: _buildDesktopLayout()),
                        ],
                      );
                    }
                  },
                ),
    );
  }

// Widget for search bar and filter chips
  Widget _buildSearchAndFilterBar() {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;
    return Column(
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
                    onPressed: () => _onSearchChanged(_searchController.text),
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
      ],
    );
  }

// Mobile layout with MasonryGridView (same as the original one)
  Widget _buildMobileLayout() {
    double screenWidth = MediaQuery.of(context).size.width;
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
              double finalHeight;

              // Set explicit heights for the first two items
              if (index == 0) {
                finalHeight = 350; // Fixed height for the first item
              } else if (index == 1) {
                finalHeight = 450; // Fixed height for the second item
              } else {
                // Randomize heights for the rest
                double randomHeight = (index % 5 + 1) * 100;
                double minHeight = 300; // Set your minimum height here
                finalHeight =
                    randomHeight < minHeight ? minHeight : randomHeight;
              }

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
                  customBoxWidth: screenWidth / 3,
                  customFontSizeTitle: 16, // Custom font size for mobile layout
                  customIconSize: 24,
                ),
              );
            },
          );
        },
      ),
    );
  }

// Desktop layout with 4 columns (same as the original)
  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
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

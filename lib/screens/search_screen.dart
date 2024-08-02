import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  List<String> _recipeList = [
    'Recipe 1',
    'Recipe 2',
    'Recipe 3',
    'Recipe 4',
    'Recipe 5'
  ]; //Get these from the database!!!

  final List<String> _courses = ['Main', 'Breakfast', 'Appetizer', 'Dessert'];

  List<String> cuisineType = [];

  List<String> dietaryOptions = [
    'Vegan',
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

  List<String> ingredientOptions = [
    'Need 1 Extra Ingredient',
    'Mostly in My Pantry',
    'All Ingredients Available'
  ]; //double check these options!!

  List<String> spiceLevelOptions = [
    'None',
    'Mild',
    'Medium',
    'Hot',
    'Extra Hot'
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadCuisines();
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

  List<String> selectedCourseTypeOptions = [];
  List<String> selectedCuisineType = [];
  List<String> selectedDietaryOptions = [];
  String? selectedSpiceLevel;
  String? selectedIngredientOption;

  void _performSearch(String query) {
    // Replace this with the actual search logic!!!
    setState(() {
      _searchResults = ['Recipe 1', 'Recipe 2', 'Recipe 3']
          .where((recipe) => recipe.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _openFilterModal() {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    // Temporary variables to hold selections within the modal
    List<String> tempDietaryOptions = List.from(selectedDietaryOptions);
    List<String> tempCourseOptions = List.from(selectedCourseTypeOptions);
    List<String> tempCuisineOptions = List.from(selectedCuisineType);
    String? tempSpiceLevel = selectedSpiceLevel;
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
                    Text('Filter',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    Text('Dietary Constraints:',
                        style: TextStyle(fontSize: 16)),
                    Wrap(
                      spacing: 8.0,
                      children: dietaryOptions.map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          selected: tempDietaryOptions.contains(option),
                          onSelected: (isSelected) {
                            setState(() {
                              isSelected
                                  ? tempDietaryOptions.add(option)
                                  : tempDietaryOptions.remove(option);
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
                              isSelected
                                  ? tempCourseOptions.add(option)
                                  : tempCourseOptions.remove(option);
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
                              isSelected
                                  ? tempCuisineOptions.add(option)
                                  : tempCuisineOptions.remove(option);
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
                          selected: tempSpiceLevel == option,
                          onSelected: (isSelected) {
                            setState(() {
                              tempSpiceLevel = isSelected ? option : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 15),
                    Text('Ingredients:', style: TextStyle(fontSize: 16)),
                    Wrap(
                      spacing: 8.0,
                      children: ingredientOptions.map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          selected: tempIngredientOption == option,
                          onSelected: (isSelected) {
                            setState(() {
                              tempIngredientOption = isSelected ? option : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
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
                          child: Text(
                            'RESET',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        ElevatedButton(
                          child: Text(
                            'APPLY',
                            style: TextStyle(color: textColor),
                          ),
                          onPressed: () {
                            // Perform filtering logic here
                            // Update the main state with the selections
                            setState(() {
                              selectedDietaryOptions = tempDietaryOptions;
                              selectedCourseTypeOptions = tempCourseOptions;
                              selectedCuisineType = tempCuisineOptions;
                              selectedSpiceLevel = tempSpiceLevel;
                              selectedIngredientOption = tempIngredientOption;
                            });
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

  Widget _buildFilterChips() {
    List<Widget> chips = [];

    if (selectedDietaryOptions.isNotEmpty) {
      chips.addAll(
          selectedDietaryOptions.map((option) => Chip(label: Text(option))));
    }

    if (selectedCourseTypeOptions.isNotEmpty) {
      chips.addAll(
          selectedCourseTypeOptions.map((option) => Chip(label: Text(option))));
    }

    if (selectedSpiceLevel != null) {
      chips.add(Chip(label: Text(selectedSpiceLevel!)));
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
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
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: _recipeList.map((recipe) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                      ),
                      child: Center(
                        child: Text(
                          recipe,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_searchResults[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

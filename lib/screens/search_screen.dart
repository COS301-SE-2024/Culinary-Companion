import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

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

  Set<String> selectedCourseTypeOptions = {};
  Set<String> selectedCuisineType = {};
  Set<String> selectedDietaryOptions = {};
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
                          selected: selectedDietaryOptions.contains(option),
                          onSelected: (isSelected) {
                            setState(() {
                              isSelected
                                  ? selectedDietaryOptions.add(option)
                                  : selectedDietaryOptions.remove(option);
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
                          selected: selectedCourseTypeOptions.contains(option),
                          onSelected: (isSelected) {
                            setState(() {
                              isSelected
                                  ? selectedCourseTypeOptions.add(option)
                                  : selectedCourseTypeOptions.remove(option);
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
                          selected: selectedCuisineType.contains(option),
                          onSelected: (isSelected) {
                            setState(() {
                              isSelected
                                  ? selectedCuisineType.add(option)
                                  : selectedCuisineType.remove(option);
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
                          selected: selectedSpiceLevel == option,
                          onSelected: (isSelected) {
                            setState(() {
                              selectedSpiceLevel = isSelected ? option : null;
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
                          selected: selectedIngredientOption == option,
                          onSelected: (isSelected) {
                            setState(() {
                              selectedIngredientOption =
                                  isSelected ? option : null;
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
                              selectedDietaryOptions.clear();
                              selectedCourseTypeOptions.clear();
                              selectedCuisineType.clear();
                              selectedSpiceLevel = null;
                              selectedIngredientOption = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterModal,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _performSearch(_searchController.text),
                ),
              ),
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

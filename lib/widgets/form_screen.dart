import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/number_spinner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../gemini_service.dart'; // LLM

class RecipeForm extends StatefulWidget {
  @override
  _RecipeFormState createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm>
    with SingleTickerProviderStateMixin {
  List<MultiSelectItem<String>> _applianceItems = [];
  List<String> _selectedAppliances = [];
  final List<TextEditingController> _ingredientControllers = [];

  // Add this line inside your class
  List<String> measurementUnits = [
    'units',
    'kg',
    'g',
    'lbs',
    'oz',
    'milliliters',
    'fl oz',
    'cups',
    'tbsp',
    'tsp',
    'quart',
    'pint',
    'liter',
    'gallon',
    'piece',
    'pack',
    'dozen',
    'slice',
    'clove',
    'bunch',
    'can',
    'bottle',
    'jar',
    'bag',
    'box',
    'whole'
  ];

  final List<String> _preloadedImages = [
    'https://gsnhwvqprmdticzglwdf.supabase.co/storage/v1/object/public/recipe_photos/default.jpg?t=2024-07-23T07%3A29%3A02.690Z'
    // 'https://gsnhwvqprmdticzglwdf.supabase.co/storage/v1/object/public/recipe_photos/recipe_photos/d2.jpg?t=2024-07-23T08%3A45%3A33.653Z',
    // 'https://gsnhwvqprmdticzglwdf.supabase.co/storage/v1/object/public/recipe_photos/recipe_photos/d3.jpg?t=2024-07-23T08%3A45%3A33.653Z',
  ];

  String _imageUrl = "";
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _initializeData() async {
    await _loadUserId();
    await _loadCuisines();
    await _loadAppliances();
    await _fetchIngredientNames();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      print('No image selected.');
      return;
    }

    final supabase = Supabase.instance.client;
    final imageBytes = await image.readAsBytes();
    //final imagePath = '/recipe_photos';
    final imageName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
    final imagePath = 'recipe_photos/$imageName';

    try {
      final response =
          await supabase.storage.from('recipe_photos').uploadBinary(
                imagePath,
                imageBytes,
                fileOptions: FileOptions(
                  upsert: true,
                  contentType: 'image/*',
                ),
              );

      if (response.isNotEmpty) {
        _imageUrl =
            supabase.storage.from('recipe_photos').getPublicUrl(imagePath);
        //print('here1: $_imageUrl');
        if (mounted) {
          setState(() {
            _selectedImage = _imageUrl;
          });
        }
        //print('here2: $_selectedImage');
      } else {
        print('Error uploading image: $response');
      }
    } catch (error) {
      print('Exception during image upload: $error');
    }
  }

  String? _userId;
  List<String> _cuisines = [];
  List<String> _appliances =
      []; //Change to get the appliances from the database

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getString('userId');
      });
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
            _cuisines = data.map<String>((cuisine) {
              return cuisine['name'].toString();
            }).toList();
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

  Future<void> _fetchIngredientNames() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: '{"action": "getIngredientNames"}',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _availableIngredients = data
                .map((item) => {
                      'name': item['name'].toString(),
                      'measurementUnit': item['measurementUnit'].toString(),
                    })
                .toList();

            // Sort items alphabetically by name
            _availableIngredients
                .sort((a, b) => a['name']!.compareTo(b['name']!));
          });
        }
      } else {
        print('Failed to fetch ingredient names: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching ingredient names: $error');
    }
  }

  Future<void> _loadAppliances() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'action': 'getAllAppliances'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _appliances = data.map<String>((appliance) {
              return appliance['name'].toString();
            }).toList();
            _applianceItems = _appliances
                .map((appliance) =>
                    MultiSelectItem<String>(appliance, appliance))
                .toList();
          });
        }
      } else {
        throw Exception('Failed to load appliances');
      }
    } catch (e) {
      throw Exception('Error fetching appliances: $e');
    }
  }

 void _showAddIngredientDialog(int index) { //popup for users to add ingredients that arent in db
  String newIngredientName = '';
  String selectedUnit = measurementUnits.first;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Ingredient Name'),
              onChanged: (value) {
                newIngredientName = value;
              },
            ),
            DropdownButtonFormField<String>(
              value: selectedUnit,
              onChanged: (value) {
                selectedUnit = value!;
              },
              items: measurementUnits.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Measurement Unit'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              //capitalize new ingredient
              newIngredientName = capitalizeEachWord(newIngredientName);

              //add ingredient to db
              await addIngredientIfNotExists(newIngredientName, selectedUnit);

              if (mounted) {
                setState(() {
                  _ingredients[index]['name'] = newIngredientName;
                  _ingredients[index]['unit'] = selectedUnit;
                  _ingredientControllers[index].text = newIngredientName;
                  _availableIngredients.add({
                    'name': newIngredientName,
                    'measurementUnit': selectedUnit,
                  });
                });
              }

              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}


String capitalizeEachWord(String input) {
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}


Future<void> addIngredientIfNotExists(String ingredientName, String measurementUnit) async {
  //make sure each first letter of a word is capitalized
  String formattedIngredientName = capitalizeEachWord(ingredientName);

  final response = await http.post(
    Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'action':'addIngredientIfNotExists',
      'ingredientName': formattedIngredientName,
      'measurementUnit': measurementUnit,
    }),
  );

  if (response.statusCode != 200) {
    print('Failed to add ingredient: ${response.body}');
  } else {
    print('Ingredient added successfully');
  }
}



  final List<Map<String, String>> _ingredients = [];
  final List<String> _methods = [];
  late TabController _tabController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _servingAmountController =
      TextEditingController();

  String _selectedCuisine = 'Mexican';
  String _selectedCourse = 'Main';
  int _spiceLevel = 1;
  // bool _showAppliancesDropdown = false;

  final List<String> _courses = [
    'Main',
    'Breakfast',
    'Appetizer',
    'Dessert'
  ]; //Change these so it is fetched from database

  // Define the list of available ingredients
  //List<String> _availableIngredients = [];
  List<Map<String, String>> _availableIngredients = [];

  void _addIngredientField() {
    if (mounted) {
      setState(() {
        _ingredients.add({
          'name': _availableIngredients.isNotEmpty
              ? _availableIngredients[0]['name'] ?? ''
              : '',
          'quantity': '',
          'unit': _availableIngredients.isNotEmpty
              ? _availableIngredients[0]['measurementUnit'] ??
                  measurementUnits.first
              : measurementUnits.first,
        });
        _ingredientControllers.add(TextEditingController());
      });
    }
  }

  void _removeIngredientField(int index) {
    if (mounted) {
      setState(() {
        _ingredients.removeAt(index);
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addMethodField() {
    if (mounted) {
      setState(() {
        _methods.add('');
      });
    }
  }

  void _removeMethodField(int index) {
    if (mounted) {
      setState(() {
        _methods.removeAt(index);
      });
    }
  }

  Future<void> _submitRecipe() async {

    // ignore: avoid_function_literals_in_foreach_calls
    _ingredients.forEach((ingredient) {
      ingredient['name'] = capitalizeEachWord(ingredient['name']!);
    });
    print("ingredients: $_ingredients");
    List<Map<String, String>> appliancesData =
        _selectedAppliances.map((appliance) {
      return {'name': appliance};
    }).toList();
    final recipeData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'methods': _methods.join('<'),
      'cookTime': int.parse(_cookingTimeController.text),
      'cuisine': _selectedCuisine,
      'spiceLevel': _spiceLevel,
      'prepTime': int.parse(_prepTimeController.text),
      'course': _selectedCourse,
      'servingAmount': int.parse(_servingAmountController.text),
      'ingredients': _ingredients.map((ingredient) {
        return {
          'name': ingredient['name'],
          'quantity': num.parse(ingredient['quantity']!),
          'unit': ingredient['unit'],
        };
      }).toList(),
      'appliances': appliancesData,
      'photo': _selectedImage,
    };

    final response = await http.post(
      Uri.parse(
          'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'action': 'addRecipe',
        'userId': _userId,
        'recipeData': recipeData,
      }),
    );

    if (response.statusCode == 200) {
      // Successfully added recipe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recipe added successfully!'),
          duration: Duration(seconds: 3), // Adjust the duration here
        ),
      );

      print("over here");

      final recipeIdResponse = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': 'getRecipeId',
          'recipeData': {
            'name': _nameController.text,
          },
        }),
      );

      if (recipeIdResponse.statusCode == 200) {
        final recipeId = json.decode(recipeIdResponse.body)['recipeId'];

        print("just before fetching keywords");

        // Fetch keywords using fetchKeywords function
        final keywordsJsonString = await fetchKeywords(recipeId);
        print(keywordsJsonString);
        Map<String, String> keywords;
        try {
          keywords = Map<String, String>.from(json.decode(keywordsJsonString));
        } catch (e) {
          print('Failed to parse keywords: $e');
          return;
        }

        // Convert the keywords map to a comma-separated string
        final keywordsList = keywords.values.toList();
        final keywordsString = keywordsList.join(',');

        print("just after fetching keywords");

        final addKeywordsResponse = await http.post(
          Uri.parse(
              'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'action': 'addRecipeKeywords',
            'recipeid': recipeId,
            'keywords':
                keywordsString, // Ensure _keywords is defined and contains the keywords
          }),
        );

        print("after adding keywords");

        if (addKeywordsResponse.statusCode == 200) {
          print('Keywords added successfully');
        } else {
          print('Failed to add keywords');
        }

        final dietaryConstraintsJsonString =
            await fetchDietaryConstraints(recipeId);
        print(dietaryConstraintsJsonString);

        Map<String, dynamic> dietaryConstraints;
        try {
          dietaryConstraints = json.decode(dietaryConstraintsJsonString);
        } catch (e) {
          print('Failed to parse dietary constraints: $e');
          return;
        }

// print("dietaryConstraints");
// print(dietaryConstraints);
        // Filter dietary constraints that are "yes" or "true"
        final filteredConstraints = dietaryConstraints.entries
            .where((entry) =>
                entry.value.toLowerCase() == 'yes' ||
                entry.value.toLowerCase() == 'true')
            .map((entry) => entry.key)
            .toList();

        // print("filteredConstraints");
        // print(filteredConstraints);
        // Convert the filtered constraints to a comma-separated string
        final constraintsString = filteredConstraints.join(',');

        print("constraintsString");
        print(constraintsString);

        final addDietaryConstraintsResponse = await http.post(
          Uri.parse(
              'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'action': 'addRecipeDietaryConstraints',
            'recipeid': recipeId,
            'dietaryConstraints': constraintsString,
          }),
        );

        if (addDietaryConstraintsResponse.statusCode == 200) {
          print('Dietary constraints added successfully');
        } else {
          print('Failed to add dietary constraints');
        }
      } else {
        print('Failed to retrieve recipe ID');
      }

      // Clear all form inputs
      _nameController.clear();
      _descriptionController.clear();
      _cookingTimeController.clear();
      _prepTimeController.clear();
      _servingAmountController.clear();
      _methods.clear();
      _ingredients.clear();
      _selectedAppliances.clear();
      _selectedCuisine = _cuisines.first;
      _selectedCourse = _courses.first;
      _spiceLevel = 1;
      if (mounted) {
        setState(() {});
      }
    } else {
      // Failed to add recipe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add recipe: ${response.body}'),
          duration: Duration(seconds: 3), // Adjust the duration here
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration(String labelText, {IconData? icon}) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: textColor),
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF0B3D36)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  String _getSpiceLevelLabel(int spiceLevel) {
    switch (spiceLevel) {
      case 1:
        return 'None';
      case 2:
        return 'Mild🌶️';
      case 3:
        return 'Medium🌶️🌶️';
      case 4:
        return 'Hot🌶️🌶️🌶️';
      case 5:
        return 'Extra Hot🌶️🌶️🌶️🌶️';
      default:
        return '';
    }
  }

  Widget _buildAppliancesMultiSelect() {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(left: 5, top: 10, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Appliances:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          MultiSelectDialogField<String>(
            checkColor: Colors.white,
            selectedColor: Color(0xFF20493C),
            backgroundColor: Color(0xFFDC945F),
            items: _applianceItems,
            initialValue: _selectedAppliances,
            onConfirm: (values) {
              if (mounted) {
                setState(() {
                  _selectedAppliances = values;
                });
              }
            },
            chipDisplay: MultiSelectChipDisplay(
              chipColor: Color(0xFFDC945F),
              textStyle: TextStyle(color: Color(0xFF20493C), fontSize: 16),
            ),
            buttonText: Text(
              'Select Appliances',
              style: TextStyle(
                color: textColor,
              ),
            ),
            buttonIcon: Icon(
              Icons.arrow_drop_down,
              color: textColor,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                color: textColor,
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recipe Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Card(
              color: theme.brightness == Brightness.light
                  ? Color.fromARGB(255, 223, 223, 223)
                  : Color.fromARGB(255, 21, 48, 39),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      cursorColor: textColor,
                      decoration: _buildInputDecoration('Name of Recipe',
                          icon: Icons.fastfood),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _descriptionController,
                      cursorColor: textColor,
                      decoration: _buildInputDecoration('Description of Recipe',
                          icon: Icons.description),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _cookingTimeController,
                      cursorColor: textColor,
                      decoration: _buildInputDecoration('Cooking Time (min)',
                          icon: Icons.timer),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _prepTimeController,
                      cursorColor: textColor,
                      decoration: _buildInputDecoration(
                          'Preparation Time (min)',
                          icon: Icons.timer_off),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      dropdownColor:
                          isLightTheme ? Colors.white : Color(0xFF20493C),
                      value: _selectedCuisine,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedCuisine = value!;
                          });
                        }
                      },
                      items: _cuisines.map((cuisine) {
                        return DropdownMenuItem<String>(
                          value: cuisine,
                          child: Text(cuisine),
                        );
                      }).toList(),
                      decoration: _buildInputDecoration('Type of Cuisine',
                          icon: Icons.restaurant),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      dropdownColor:
                          isLightTheme ? Colors.white : Color(0xFF20493C),
                      value: _selectedCourse,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedCourse = value!;
                          });
                        }
                      },
                      items: _courses.map((course) {
                        return DropdownMenuItem<String>(
                          value: course,
                          child: Text(course),
                        );
                      }).toList(),
                      decoration: _buildInputDecoration('Type of Course',
                          icon: Icons.category),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('Spice Level:',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 16),
                        const Icon(Icons.local_fire_department,
                            color: Colors.red),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              valueIndicatorTextStyle: TextStyle(
                                  color: Colors
                                      .black), // Change this to the desired color
                            ),
                            child: Slider(
                              value: _spiceLevel.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: _getSpiceLevelLabel(_spiceLevel),
                              onChanged: (value) {
                                if (mounted) {
                                  setState(() {
                                    _spiceLevel = value.toInt();
                                  });
                                }
                              },
                              activeColor: Color(
                                  0xFFDC945F), // Change this to the desired color for the active part of the slider
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('Serving Amount:',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 16),
                        NumberSpinner(
                          initialValue: 1,
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                _servingAmountController.text =
                                    value.toString();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Ingredients:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ..._ingredients.map((ingredient) {
                      int index = _ingredients.indexOf(ingredient);
                      String initialUnit =
                          _ingredients[index]['unit'] ?? measurementUnits.first;

                      if (!measurementUnits.contains(initialUnit)) {
                        initialUnit = measurementUnits.first;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TypeAheadFormField<String>(
  textFieldConfiguration: TextFieldConfiguration(
    cursorColor: textColor,
    controller: _ingredientControllers[index],
    decoration: _buildInputDecoration(
      'Ingredient',
    ),
    onChanged: (value) {
      // Update the ingredient's name with the user input
      if (mounted) {
        setState(() {
          _ingredients[index]['name'] = value;
        });
      }
    },
  ),
  suggestionsCallback: (pattern) {
  final suggestions = _availableIngredients
      .where((ingredient) => ingredient['name']!
          .toLowerCase()
          .contains(pattern.toLowerCase()))
      .map((ingredient) => ingredient['name']!)
      .toList();

  if (suggestions.isEmpty) {
    suggestions.add('No items found, add new ingredient');
  }

  return suggestions;
},
  itemBuilder: (context, String suggestion) {
    return ListTile(
      title: Text(suggestion),
    );
  },
  onSuggestionSelected: (String suggestion) {
  if (suggestion == 'No items found, add new ingredient') {
    _showAddIngredientDialog(index);
  } else {
    if (mounted) {
      setState(() {
        _ingredients[index]['name'] = suggestion;
        final selectedIngredient = _availableIngredients.firstWhere(
            (ingredient) => ingredient['name'] == suggestion);
        _ingredients[index]['unit'] =
            selectedIngredient['measurementUnit'] ?? measurementUnits.first;
        _ingredientControllers[index].text = suggestion;
      });
    }
  }
},

  validator: (value) {
    if (value!.isEmpty) {
      return 'Please select an ingredient';
    }
    return null;
  },
  onSaved: (value) {
    _ingredients[index]['name'] = value!;
  },
),

                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                cursorColor: textColor,
                                onChanged: (value) {
                                  if (mounted) {
                                    setState(() {
                                      _ingredients[index]['quantity'] = value;
                                    });
                                  }
                                },
                                decoration: _buildInputDecoration('Quantity'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(_ingredients[index]['unit'] ??
                                ''), // Display the unit directly
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () => _removeIngredientField(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _addIngredientField,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Methods:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ..._methods.map((method) {
                      int index2 = _methods.indexOf(method);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                cursorColor: textColor,
                                onChanged: (value) {
                                  if (mounted) {
                                    setState(() {
                                      _methods[index2] = value;
                                    });
                                  }
                                },
                                decoration: _buildInputDecoration('Method'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () => _removeMethodField(index2),
                            ),
                          ],
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _addMethodField,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAppliancesMultiSelect(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isLightTheme ? Colors.white : Color(0xFF1F4539),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      child: Text(
                        'Upload Image',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Or use the preloaded image:'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: _preloadedImages.map((image) {
                        return GestureDetector(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                _selectedImage = image;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedImage == image
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: Image.network(
                              image,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        //key: Key('recipe_button'),
                        onPressed: _submitRecipe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC945F),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                        ),
                        child: const Text(
                          key: ValueKey('AddRecipe'),
                          'Add Recipe',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _cookingTimeController.dispose();
    _prepTimeController.dispose();
    _servingAmountController.dispose();
    super.dispose();
  }
}

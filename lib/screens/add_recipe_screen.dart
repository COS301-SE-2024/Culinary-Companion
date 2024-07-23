import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/help_add_recipe.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _helpMenuOverlay;
  List<MultiSelectItem<String>> _applianceItems = [];
  List<String> _selectedAppliances = [];

  // Add this line inside your class
  List<String> measurementUnits = [
    'unit',
    'kg',
    'g',
    'lbs',
    'oz',
    'ml',
    'fl oz',
    'cup',
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
  'https://gsnhwvqprmdticzglwdf.supabase.co/storage/v1/object/public/recipe_photos/default.jpg?t=2024-07-23T07%3A29%3A02.690Z',
  'https://gsnhwvqprmdticzglwdf.supabase.co/storage/v1/object/public/recipe_photos/Caesar_salad.jpeg?t=2024-07-23T08%3A24%3A46.050Z',
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
    final response = await supabase.storage.from('recipe_photos').uploadBinary(
      imagePath,
      imageBytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: 'image/*',
      ),
    );

    if (response.isNotEmpty) {
      
      _imageUrl = supabase.storage.from('recipe_photos').getPublicUrl(imagePath);
      //print('here1: $_imageUrl');
      setState(() {
        _selectedImage = _imageUrl;
      });
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
    setState(() {
      _userId = prefs.getString('userId');
    });
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
          _cuisines = data.map<String>((cuisine) {
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
        setState(() {
          _availableIngredients = data
              .map((item) => {
                    'name': item['name'].toString(),
                    'measurementUnit': item['measurementUnit'].toString(),
                  })
              .toList();
        });
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
        setState(() {
          _appliances = data.map<String>((appliance) {
            return appliance['name'].toString();
          }).toList();
          _applianceItems = _appliances
              .map((appliance) => MultiSelectItem<String>(appliance, appliance))
              .toList();
        });
      } else {
        throw Exception('Failed to load appliances');
      }
    } catch (e) {
      throw Exception('Error fetching appliances: $e');
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
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addMethodField() {
    setState(() {
      _methods.add('');
    });
  }

  void _removeMethodField(int index) {
    setState(() {
      _methods.removeAt(index);
    });
  }

  // void _addAppliance(String appliance) {
  //   setState(() {
  //     _selectedAppliances.add(appliance);
  //     _showAppliancesDropdown = false;
  //   });
  // }

  // void _removeAppliance(String appliance) {
  //   setState(() {
  //     _selectedAppliances.remove(appliance);
  //   });
  // }

  Future<void> _submitRecipe() async {
    List<Map<String, String>> appliancesData =
        _selectedAppliances.map((appliance) {
      return {'name': appliance};
    }).toList();
    final recipeData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'methods': _methods.join(',\n'),
      'cookTime': int.parse(_cookingTimeController.text),
      'cuisine': _selectedCuisine,
      'spiceLevel': _spiceLevel,
      'prepTime': int.parse(_prepTimeController.text),
      'course': _selectedCourse,
      'servingAmount': int.parse(_servingAmountController.text),
      'ingredients': _ingredients.map((ingredient) {
        return {
          'name': ingredient['name'],
          'quantity': int.parse(ingredient['quantity']!),
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

      setState(() {});
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
    return InputDecoration(
      labelText: labelText,
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
              setState(() {
                _selectedAppliances = values;
              });
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
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.0),
          child: Stack(
            alignment: Alignment.centerRight, //aligns help button to the right
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Scan Recipe'),
                  Tab(text: 'Paste Recipe'),
                  Tab(text: 'Add My Own Recipe'),
                ],
                labelColor: textColor,
                unselectedLabelColor: Color(0xFFDC945F),
                indicatorColor: textColor,
              ),
              Positioned(
                right: 20,
                bottom: 5,
                child: IconButton(
                  icon: Icon(Icons.help),
                  onPressed: _showHelpMenu,
                  iconSize: 35,
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Scan Recipe Screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // //const SizedBox(height: 20),
                // const Padding(
                //   padding: EdgeInsets.only(left: 32.0),
                //   child: Row(
                //     children: [
                //       Text(
                //         'Scan Recipe:',
                //         style: TextStyle(
                //             fontSize: 24, fontWeight: FontWeight.bold),
                //       ),
                //     ],
                //   ),
                // ),
                const Icon(Icons.camera_alt, size: 100),
                const Text(
                  'Drag & Drop Recipe Here',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Browse Files'),
                ),
                const SizedBox(height: 150),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      key: Key('recipe_button'),
                      onPressed: () {
                        // Add functionality to format the scanned recipe
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC945F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      child: const Text(
                        'Format Recipe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      //key: Key('recipe_button'),
                      onPressed: () {
                        // Add functionality to analyze the scanned recipe
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.brightness == Brightness.light
                            ? Colors.white
                            : Color(0xFF1F4539),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                        side: const BorderSide(
                            color: Color(0xFFDC945F), width: 2),
                      ),
                      child: const Text(
                        'Analyze Recipe',
                        style: TextStyle(
                          color: Color(0xFFDC945F),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Text Input Screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 32.0),
                  child: Row(
                    children: [
                      Text(
                        'Paste Recipe',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        hintText: 'Paste your recipe here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors
                                  .grey), // Optional: customize the border color
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors
                                  .transparent), // Optional: customize the border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors
                                  .transparent), // Optional: customize the border color on focus
                        ),
                        contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      //key: Key('recipe_button'),
                      onPressed: () {
                        // Add functionality to format the pasted recipe
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFDC945F), // Set the background color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      child: const Text(
                        'Format Recipe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      //key: Key('recipe_button'),
                      onPressed: () {
                        // Add functionality to analyze the pasted recipe
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.brightness == Brightness.light
                            ? Colors.white
                            : Color(0xFF1F4539), // Set the background color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                        side: const BorderSide(
                            color: Color(0xFFDC945F), width: 2),
                      ),
                      child: const Text(
                        'Analyze Recipe',
                        style: TextStyle(
                          color: Color(0xFFDC945F),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Form Screen
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recipe Details',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                            decoration: _buildInputDecoration('Name of Recipe',
                                icon: Icons.fastfood),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _descriptionController,
                            decoration: _buildInputDecoration(
                                'Description of Recipe',
                                icon: Icons.description),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _cookingTimeController,
                            decoration: _buildInputDecoration(
                                'Cooking Time (min)',
                                icon: Icons.timer),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _prepTimeController,
                            decoration: _buildInputDecoration(
                                'Preparation Time (min)',
                                icon: Icons.timer_off),
                          ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            dropdownColor: const Color(0xFF1F4539),
                            value: _selectedCuisine,
                            onChanged: (value) {
                              setState(() {
                                _selectedCuisine = value!;
                              });
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
                            dropdownColor: const Color(0xFF1F4539),
                            value: _selectedCourse,
                            onChanged: (value) {
                              setState(() {
                                _selectedCourse = value!;
                              });
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
                                      setState(() {
                                        _spiceLevel = value.toInt();
                                      });
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
                                  setState(() {
                                    _servingAmountController.text =
                                        value.toString();
                                  });
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
                            String initialUnit = _ingredients[index]['unit'] ??
                                measurementUnits.first;

                            if (!measurementUnits.contains(initialUnit)) {
                              initialUnit = measurementUnits.first;
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      dropdownColor: const Color(0xFF1F4539),
                                      value: _ingredients[index]['name'],
                                      onChanged: (value) {
                                        setState(() {
                                          _ingredients[index]['name'] = value!;
                                          // Find the selected ingredient and update the unit
                                          final selectedIngredient =
                                              _availableIngredients.firstWhere(
                                                  (ingredient) =>
                                                      ingredient['name'] ==
                                                      value);
                                          _ingredients[index]['unit'] =
                                              selectedIngredient[
                                                  'measurementUnit']!;
                                        });
                                      },
                                      items: _availableIngredients
                                          .map((ingredient) {
                                        return DropdownMenuItem<String>(
                                          value: ingredient['name'],
                                          child: Text(ingredient['name']!),
                                        );
                                      }).toList(),
                                      decoration:
                                          _buildInputDecoration('Ingredient'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _ingredients[index]['quantity'] =
                                              value;
                                        });
                                      },
                                      decoration:
                                          _buildInputDecoration('Quantity'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_ingredients[index]['unit'] ??
                                      ''), // Display the unit directly
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _removeIngredientField(index),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _methods[index2] = value;
                                        });
                                      },
                                      decoration:
                                          _buildInputDecoration('Method'),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
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
                const Text('Select Image:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
const Text('Or choose a preloaded image:'),
const SizedBox(height: 10),
Wrap(
  spacing: 10,
  children: _preloadedImages.map((image) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImage = image;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedImage == image ? Colors.blue : Colors.transparent,
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
          ),
        ],
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

void main() {
  runApp(MaterialApp(
    home: AddRecipeScreen(),
  ));
}

class NumberSpinner extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;

  NumberSpinner({required this.initialValue, required this.onChanged});

  @override
  _NumberSpinnerState createState() => _NumberSpinnerState();
}

class _NumberSpinnerState extends State<NumberSpinner> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _increment() {
    setState(() {
      _value++;
      widget.onChanged(_value);
    });
  }

  void _decrement() {
    setState(() {
      if (_value > 1) {
        _value--;
        widget.onChanged(_value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _decrement,
        ),
        Text(
          _value.toString(),
          style: const TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _increment,
        ),
      ],
    );
  }
}

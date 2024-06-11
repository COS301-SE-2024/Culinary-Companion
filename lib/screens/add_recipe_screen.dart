import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _initializeData();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _initializeData() async {
    await _loadUserId();
    await _loadCuisines();
  }

  String? _userId;
  List<String> _cuisines = [];
  List<String> _appliances = [
    'Oven',
    'Microwave',
    'Blender',
    'Toaster',
    'Grill'
  ]; //Change to get the appliances from the database

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

  final List<Map<String, String>> _ingredients = [];
  final List<String> _methods = [];
  final List<String> _selectedAppliances = [];
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
  bool _showAppliancesDropdown = false;

  final List<String> _courses = [
    'Main',
    'Breakfast',
    'Appetizer',
    'Dessert'
  ]; //Change these so it is fetched from database

  void _addIngredientField() {
    setState(() {
      _ingredients.add({'name': '', 'quantity': '', 'unit': ''});
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

  void _addAppliance(String appliance) {
    setState(() {
      _selectedAppliances.add(appliance);
      _showAppliancesDropdown = false;
    });
  }

  void _removeAppliance(String appliance) {
    setState(() {
      _selectedAppliances.remove(appliance);
    });
  }

  Future<void> _submitRecipe() async {
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
      'appliances': _selectedAppliances,
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
      //print('Recipe added successfully!');
      // Handle success (e.g., show a success message, navigate back, etc.)
    } else {
      //print('Failed to add recipe: ${response.body}');
      // Handle error (e.g., show an error message)
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
      case 0:
        return 'None';
      case 1:
        return 'Mild🌶️';
      case 2:
        return 'Medium🌶️🌶️';
      case 3:
        return 'Hot🌶️🌶️🌶️';
      case 4:
        return 'Extra Hot🌶️🌶️🌶️🌶️';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Scan Recipe'),
            Tab(text: 'Paste Recipe'),
            Tab(text: 'Add My Own Recipe'),
          ],
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
                const Icon(Icons.camera_alt, size: 100),
                const SizedBox(height: 16),
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
                      onPressed: () {
                        // Add functionality to analyze the scanned recipe
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F4539),
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
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        hintText: 'Paste your recipe here...',
                        border: OutlineInputBorder(),
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
                      onPressed: () {
                        // Add functionality to analyze the pasted recipe
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1F4539), // Set the background color
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
                  const Text('Recipe Details:',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  Card(
                    color: Color(0xFF19372D),
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
                                    min: 0,
                                    max: 4,
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
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _ingredients[index]['name'] = value;
                                        });
                                      },
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
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _ingredients[index]['unit'] = value;
                                        });
                                      },
                                      decoration: _buildInputDecoration('Unit'),
                                    ),
                                  ),
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
                          const Text('Appliances:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          // Wrap(
                          //   spacing: 8.0,
                          //   runSpacing: 4.0,
                          //   children: [
                          //     for (var appliance in _selectedAppliances)
                          //       Row(
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           const Icon(Icons.soup_kitchen, size: 16),
                          //           const SizedBox(width: 4),
                          //           Text(appliance),
                          //           IconButton(
                          //             icon: const Icon(Icons.delete, size: 16),
                          //             onPressed: () => _removeAppliance(appliance),
                          //           ),
                          //         ],
                          //       ),
                          //       if (_showAppliancesDropdown)
                          //         DropdownButton<String>(
                          //           items: _appliances
                          //               .where((appliance) =>
                          //                   !_selectedAppliances.contains(appliance))
                          //               .map((appliance) {
                          //             return DropdownMenuItem(
                          //               value: appliance,
                          //               child: Text(appliance),
                          //             );
                          //           }).toList(),
                          //           onChanged: (value) {
                          //             if (value != null) {
                          //               _addAppliance(value);
                          //             }
                          //           },
                          //           hint: const Text('Select Appliance'),
                          //         ),
                          //       IconButton(
                          //         icon: const Icon(Icons.add),
                          //         onPressed: () {
                          //           setState(() {
                          //             _showAppliancesDropdown = !_showAppliancesDropdown;
                          //           });
                          //         },
                          //       ),
                          //     ],
                          //   ),

                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: _selectedAppliances.length,
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedAppliances[index],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () {
                                      _removeAppliance(
                                          _selectedAppliances[index]);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          if (_showAppliancesDropdown)
                            DropdownButtonFormField<String>(
                              dropdownColor: const Color(0xFF1F4539),
                              items: _appliances.map((appliance) {
                                return DropdownMenuItem<String>(
                                  value: appliance,
                                  child: Text(appliance),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null &&
                                    !_selectedAppliances.contains(value)) {
                                  _addAppliance(value);
                                }
                              },
                              decoration:
                                  _buildInputDecoration('Select Appliance'),
                            ),
                          Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _showAppliancesDropdown =
                                      !_showAppliancesDropdown;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              onPressed: _submitRecipe,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC945F),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20),
                              ),
                              child: const Text(
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

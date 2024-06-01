import 'package:flutter/material.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen>
    with SingleTickerProviderStateMixin {
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

  final List<String> _cuisines = [
    'Mexican',
    'Italian',
    'Chinese',
    'Indian',
    'American'
  ];
  final List<String> _courses = ['Main', 'Breakfast', 'Appetizer', 'Dessert'];

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

  void _submitRecipe() {
    // Collect all data and print or save it to a database
    print('Name: ${_nameController.text}');
    print('Description: ${_descriptionController.text}');
    print('Cooking Time: ${_cookingTimeController.text}');
    print('Preparation Time: ${_prepTimeController.text}');
    print('Type of Cuisine: $_selectedCuisine');
    print('Spice Level: $_spiceLevel');
    print('Type of Course: $_selectedCourse');
    print('Serving Amount: ${_servingAmountController.text}');
    print('Ingredients: $_ingredients');
    print('Methods: $_methods');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  InputDecoration _buildInputDecoration(String labelText, {IconData? icon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF0B3D36)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [
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
                Icon(Icons.camera_alt, size: 100),
                SizedBox(height: 16),
                Text(
                  'Drag & Drop Recipe Here',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: Text('Browse Files'),
                ),
              ],
            ),
          ),
          // Text Input Screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.text_fields, size: 100),
                SizedBox(height: 16),
                Text(
                  'Paste Text',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: Text('Analyze Recipe'),
                ),
              ],
            ),
          ),
          // Form Screen
          Padding(
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recipe Details:',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 40),
                  Card(
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
                          SizedBox(height: 24),
                          TextField(
                            controller: _descriptionController,
                            decoration: _buildInputDecoration(
                                'Description of Recipe',
                                icon: Icons.description),
                            maxLines: 3,
                          ),
                          SizedBox(height: 24),
                          TextField(
                            controller: _cookingTimeController,
                            decoration: _buildInputDecoration(
                                'Cooking Time (min)',
                                icon: Icons.timer),
                          ),
                          SizedBox(height: 24),
                          TextField(
                            controller: _prepTimeController,
                            decoration: _buildInputDecoration(
                                'Preparation Time (min)',
                                icon: Icons.timer_off),
                          ),
                          SizedBox(height: 24),
                          DropdownButtonFormField<String>(
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
                          SizedBox(height: 24),
                          DropdownButtonFormField<String>(
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
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Text('Spice Level:',
                                  style: TextStyle(fontSize: 16)),
                              SizedBox(width: 16),
                              Icon(Icons.local_fire_department,
                                  color: Colors.red),
                              Expanded(
                                child: Slider(
                                  value: _spiceLevel.toDouble(),
                                  min: 1,
                                  max: 3,
                                  divisions: 2,
                                  label: _spiceLevel.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      _spiceLevel = value.toInt();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          TextField(
                            controller: _servingAmountController,
                            decoration: _buildInputDecoration('Serving Amount',
                                icon: Icons.people),
                          ),
                          SizedBox(height: 24),
                          Text('Ingredients:',
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
                                  SizedBox(width: 8),
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
                                  SizedBox(width: 8),
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
                                    icon: Icon(Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _removeIngredientField(index),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: _addIngredientField,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text('Methods:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          ..._methods.map((method) {
                            int index = _methods.indexOf(method);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _methods[index] = value;
                                        });
                                      },
                                      decoration:
                                          _buildInputDecoration('Method'),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () => _removeMethodField(index),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: _addMethodField,
                            ),
                          ),
                          SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              onPressed: _submitRecipe,
                              child: Text('Add Recipe'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0B3D36),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20),
                                textStyle: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
}

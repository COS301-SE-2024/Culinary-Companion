import 'package:flutter/material.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _ingredients = [];
  final List<String> _methods = [];
  late TabController _tabController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _servingAmountController = TextEditingController();

  String _selectedCuisine = 'Mexican';
  String _selectedCourse = 'Main';
  int _spiceLevel = 1;

  final List<String> _cuisines = ['Mexican', 'Italian', 'Chinese', 'Indian', 'American'];
  final List<String> _courses = ['Main', 'Breakfast', 'Appetizer', 'Dessert'];

  void _addIngredientField() {
    setState(() {
      _ingredients.add({'name': '', 'quantity': '', 'unit': ''});
    });
  }

  void _addMethodField() {
    setState(() {
      _methods.add('');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Culinary Companion'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Scan Recipe'),
            Tab(text: 'Form'),
            Tab(text: 'Text Input'),
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
          // Form Screen
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recipe Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name of Recipe',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description of Recipe',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _cookingTimeController,
                    decoration: InputDecoration(
                      labelText: 'Cooking Time (min)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _prepTimeController,
                    decoration: InputDecoration(
                      labelText: 'Preparation Time (min)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
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
                    decoration: InputDecoration(
                      labelText: 'Type of Cuisine',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
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
                    decoration: InputDecoration(
                      labelText: 'Type of Course',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Spice Level:', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 16),
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
                  SizedBox(height: 16),
                  TextField(
                    controller: _servingAmountController,
                    decoration: InputDecoration(
                      labelText: 'Serving Amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Ingredients:', style: TextStyle(fontSize: 16)),
                  ..._ingredients.map((ingredient) {
                    int index = _ingredients.indexOf(ingredient);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _ingredients[index]['name'] = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Ingredient',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _ingredients[index]['quantity'] = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
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
                              decoration: InputDecoration(
                                hintText: 'Unit',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: _addIngredientField,
                  ),
                  SizedBox(height: 20),
                  Text('Methods:', style: TextStyle(fontSize: 16)),
                  ..._methods.map((method) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            int index = _methods.indexOf(method);
                            _methods[index] = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Method',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }).toList(),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: _addMethodField,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitRecipe,
                      child: Text('Add Recipe'),
                    ),
                  ),
                ],
              ),
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
        ],
      ),
    );
  }
}

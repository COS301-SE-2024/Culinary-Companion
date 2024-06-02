// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class AddRecipeScreen extends StatefulWidget {
//   @override
//   _AddRecipeScreenState createState() => _AddRecipeScreenState();
// }

// class _AddRecipeScreenState extends State<AddRecipeScreen> with SingleTickerProviderStateMixin {
//   final List<Map<String, String>> _ingredients = [];
//   final List<String> _methods = [];
//   late TabController _tabController;

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _cookingTimeController = TextEditingController();
//   final TextEditingController _prepTimeController = TextEditingController();
//   final TextEditingController _servingAmountController = TextEditingController();

//   String _selectedCuisine = 'Mexican';
//   String _selectedCourse = 'Main';
//   int _spiceLevel = 1;

//   final List<String> _cuisines = ['Mexican', 'Italian', 'Chinese', 'Indian', 'American'];
//   final List<String> _courses = ['Main', 'Breakfast', 'Appetizer', 'Dessert'];

//   void _addIngredientField() {
//     setState(() {
//       _ingredients.add({'name': '', 'quantity': '', 'unit': ''});
//     });
//   }

//   void _addMethodField() {
//     setState(() {
//       _methods.add('');
//     });
//   }

//   Future<void> _submitRecipe() async {
//     final recipeData = {
//       'name': _nameController.text,
//       'description': _descriptionController.text,
//       'methods': _methods.join(',\n'),
//       'cookTime': int.parse(_cookingTimeController.text),
//       'cuisine': _selectedCuisine,
//       'spiceLevel': _spiceLevel,
//       'prepTime': int.parse(_prepTimeController.text),
//       'course': _selectedCourse,
//       'servingAmount': int.parse(_servingAmountController.text),
//       'ingredients': _ingredients.map((ingredient) {
//         return {
//           'name': ingredient['name'],
//           'quantity': int.parse(ingredient['quantity']!),
//           'unit': ingredient['unit'],
//         };
//       }).toList(),
//     };

//     final response = await http.post(
//       Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         'action': 'addRecipe',
//         'recipeData': recipeData,
//       }),
//     );

//     if (response.statusCode == 200) {
//       print('Recipe added successfully!');
//       // Handle success (e.g., show a success message, navigate back, etc.)
//     } else {
//       print('Failed to add recipe: ${response.body}');
//       // Handle error (e.g., show an error message)
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(text: 'Scan Recipe'),
//             Tab(text: 'Form'),
//             Tab(text: 'Text Input'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // Scan Recipe Screen
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.camera_alt, size: 100),
//                 SizedBox(height: 16),
//                 Text(
//                   'Drag & Drop Recipe Here',
//                   style: TextStyle(fontSize: 18),
//                 ),
//                 SizedBox(height: 8),
//                 OutlinedButton(
//                   onPressed: () {},
//                   child: Text('Browse Files'),
//                 ),
//               ],
//             ),
//           ),
//           // Form Screen
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Recipe Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 16),
//                   TextField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: 'Name of Recipe',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   TextField(
//                     controller: _descriptionController,
//                     decoration: InputDecoration(
//                       labelText: 'Description of Recipe',
//                       border: OutlineInputBorder(),
//                     ),
//                     maxLines: 3,
//                   ),
//                   SizedBox(height: 16),
//                   TextField(
//                     controller: _cookingTimeController,
//                     decoration: InputDecoration(
//                       labelText: 'Cooking Time (min)',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   TextField(
//                     controller: _prepTimeController,
//                     decoration: InputDecoration(
//                       labelText: 'Preparation Time (min)',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     value: _selectedCuisine,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedCuisine = value!;
//                       });
//                     },
//                     items: _cuisines.map((cuisine) {
//                       return DropdownMenuItem<String>(
//                         value: cuisine,
//                         child: Text(cuisine),
//                       );
//                     }).toList(),
//                     decoration: InputDecoration(
//                       labelText: 'Type of Cuisine',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     value: _selectedCourse,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedCourse = value!;
//                       });
//                     },
//                     items: _courses.map((course) {
//                       return DropdownMenuItem<String>(
//                         value: course,
//                         child: Text(course),
//                       );
//                     }).toList(),
//                     decoration: InputDecoration(
//                       labelText: 'Type of Course',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Text('Spice Level:', style: TextStyle(fontSize: 16)),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: Slider(
//                           value: _spiceLevel.toDouble(),
//                           min: 1,
//                           max: 3,
//                           divisions: 2,
//                           label: _spiceLevel.toString(),
//                           onChanged: (value) {
//                             setState(() {
//                               _spiceLevel = value.toInt();
//                             });
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   TextField(
//                     controller: _servingAmountController,
//                     decoration: InputDecoration(
//                       labelText: 'Serving Amount',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text('Ingredients:', style: TextStyle(fontSize: 16)),
//                   ..._ingredients.map((ingredient) {
//                     int index = _ingredients.indexOf(ingredient);
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               onChanged: (value) {
//                                 setState(() {
//                                   _ingredients[index]['name'] = value;
//                                 });
//                               },
//                               decoration: InputDecoration(
//                                 hintText: 'Ingredient',
//                                 border: OutlineInputBorder(),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: TextField(
//                               onChanged: (value) {
//                                 setState(() {
//                                   _ingredients[index]['quantity'] = value;
//                                 });
//                               },
//                               decoration: InputDecoration(
//                                 hintText: 'Quantity',
//                                 border: OutlineInputBorder(),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: TextField(
//                               onChanged: (value) {
//                                 setState(() {
//                                   _ingredients[index]['unit'] = value;
//                                 });
//                               },
//                               decoration: InputDecoration(
//                                 hintText: 'Unit',
//                                 border: OutlineInputBorder(),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                   IconButton(
//                     icon: Icon(Icons.add_circle_outline),
//                     onPressed: _addIngredientField,
//                   ),
//                   SizedBox(height: 20),
//                   Text('Methods:', style: TextStyle(fontSize: 16)),
//                   ..._methods.map((method) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: TextField(
//                         onChanged: (value) {
//                           setState(() {
//                             int index = _methods.indexOf(method);
//                             _methods[index] = value;
//                           });
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Method',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                   IconButton(
//                     icon: Icon(Icons.add_circle_outline),
//                     onPressed: _addMethodField,
//                   ),
//                   SizedBox(height: 20),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: _submitRecipe,
//                       child: Text('Submit Recipe'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Text Input Screen
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Text('Recipe Text Input:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 16),
//                 Expanded(
//                   child: TextField(
//                     maxLines: null,
//                     expands: true,
//                     decoration: InputDecoration(
//                       hintText: 'Paste or type your recipe here...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _cookingTimeController.dispose();
//     _prepTimeController.dispose();
//     _servingAmountController.dispose();
//     super.dispose();
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: AddRecipeScreen(),
//   ));
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    };

    final response = await http.post(
      Uri.parse(
          'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'action': 'addRecipe',
        'recipeData': recipeData,
      }),
    );

    if (response.statusCode == 200) {
      print('Recipe added successfully!');
      // Handle success (e.g., show a success message, navigate back, etc.)
    } else {
      print('Failed to add recipe: ${response.body}');
      // Handle error (e.g., show an error message)
    }
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
        borderSide: const BorderSide(color: Color(0xFF0B3D36)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Scan Recipe'),
            const Tab(text: 'Paste Recipe'),
            const Tab(text: 'Add My Own Recipe'),
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
                        backgroundColor: const Color(0xFF1A2D27),
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
                            const Color(0xFF1A2D27), // Set the background color
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
                  Text('Recipe Details:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      child: Text('Submit Recipe'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Text Input Screen
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Recipe Text Input:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: 'Paste or type your recipe here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
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

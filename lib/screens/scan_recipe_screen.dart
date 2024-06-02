import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart'
    as http; // Add this line to import the http package
import 'dart:convert'; // Add this line to import the dart:convert library for JSON parsing


class ScanRecipeScreen extends StatefulWidget {
  @override
  _ScanRecipeScreenState createState() => _ScanRecipeScreenState();
}

class _ScanRecipeScreenState extends State<ScanRecipeScreen> {
  String? _userId;
  @override
void initState() {
  super.initState();
  _initializeData();
}

Future<void> _initializeData() async {
  await _loadUserId();
  _fetchIngredientNames();
  _loadDontShowAgainPreference();
  _fetchShoppingList();
  _fetchPantryList();
}


  final Map<String, List<String>> _shoppingList = {};

  final Map<String, List<String>> _pantryList = {};

  final Map<String, bool> _checkboxStates = {};

  final List<String> _categories = [
    'Dairy',
    'Meat',
    'Fish',
    'Nuts',
    'Spice/Herb',
    'Starch',
    'Vegetable',
    'Vegeterian',
    'Fruit',
    'Legume',
    'Staple',
    'Other'
  ];

  List<String> _items = [];

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }



  Future<void> _fetchIngredientNames() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: '{"action": "getIngredientNames"}', // Body of the request
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // If the request is successful, parse the response JSON
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _items = data.map((item) => item['name'].toString()).toList();
        });
      } else {
        // Handle other status codes, such as 404 or 500
        print('Failed to fetch ingredient names: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Error fetching ingredient names: $error');
    }
  }

  Future<void> _fetchShoppingList() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'getShoppingList',
          'userId': _userId, //'dcd8108f-acc2-4be8-aef6-69d5763f8b5b', // Hardcoded user ID
        }), // Body of the request
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // If the request is successful, parse the response JSON
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> shoppingList = data['shoppingList'];
        setState(() {
          _shoppingList.clear();
          for (var item in shoppingList) {
            final ingredientName = item['ingredientName'].toString();
            final category = item['category'] ?? 'Other';
            _shoppingList.putIfAbsent(category, () => []);
            _shoppingList[category]?.add(ingredientName);
          }
        });
      } else {
        // Handle other status codes, such as 404 or 500
        print('Failed to fetch shopping list: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Error fetching shopping list: $error');
    }
  }

  Future<void> _fetchPantryList() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'getAvailableIngredients',
          'userId': _userId, //'dcd8108f-acc2-4be8-aef6-69d5763f8b5b', // Hardcoded user ID
        }), // Body of the request
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // If the request is successful, parse the response JSON
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> pantryList = data['availableIngredients'];
        setState(() {
          _pantryList.clear();
          for (var item in pantryList) {
            final ingredientName = item['name'].toString();
            final category = item['category'] ?? 'Other';
            _pantryList.putIfAbsent(category, () => []);
            _pantryList[category]?.add(ingredientName);
          }
        });
      } else {
        // Handle other status codes, such as 404 or 500
        print('Failed to fetch pantry list: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Error fetching pantry list: $error');
    }
  }

  Future<void> _addToShoppingList(String? userId, String ingredientName) async {
  try {
    final response = await http.post(
      Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      body: jsonEncode({
        'action': 'addToShoppingList',
        'userId': userId,
        'ingredientName': ingredientName,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Successfully added $ingredientName to shopping list');
    } else {
      print('Failed to add $ingredientName to shopping list: ${response.statusCode}');
    }
  } catch (error) {
    print('Error adding $ingredientName to shopping list: $error');
  }
}

Future<void> _removeFromShoppingList(String category, String ingredientName) async {
  try {
    final response = await http.post(
      Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      body: jsonEncode({
        'action': 'removeFromShoppingList',
        'userId': _userId,
        'ingredientName': ingredientName,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // If the request is successful, update the shopping list
      setState(() {
        _shoppingList[category]?.remove(ingredientName);
      });
    } else {
      // Handle other status codes
      print('Failed to remove item from shopping list: ${response.statusCode}');
    }
  } catch (error) {
    // Handle network errors or other exceptions
    print('Error removing item from shopping list: $error');
  }
}


Future<void> _addToPantryList(String? userId, String ingredientName) async {
  try {
    final response = await http.post(
      Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      body: jsonEncode({
        'action': 'addToPantryList', // Change action to addToPantryList
        'userId': userId,
        'ingredientName': ingredientName,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Successfully added $ingredientName to pantry list');
    } else {
      print('Failed to add $ingredientName to pantry list: ${response.statusCode}');
    }
  } catch (error) {
    print('Error adding $ingredientName to pantry list: $error');
  }
}

Future<void> _removeFromPantryList(String category, String ingredientName) async {
  try {
    final response = await http.post(
      Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      body: jsonEncode({
        'action': 'removeFromPantryList',
        'userId': _userId,
        'ingredientName': ingredientName,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // If the request is successful, update the pantry list
      setState(() {
        _pantryList[category]?.remove(ingredientName);
        if (_pantryList[category]?.isEmpty ?? true) {
          _pantryList.remove(category);
        }
      });
    } else {
      // Handle other status codes
      print('Failed to remove item from pantry list: ${response.statusCode}');
    }
  } catch (error) {
    // Handle network errors or other exceptions
    print('Error removing item from pantry list: $error');
  }
}


  bool _dontShowAgain = false;

  Future<void> _loadDontShowAgainPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dontShowAgain = prefs.getBool('dontShowAgain') ?? false;
    });
  }

  Future<void> _setDontShowAgainPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('dontShowAgain', value);
  }

 void _addItem(String category, String item, bool type) {
  if (type) {
    setState(() {
      _shoppingList.putIfAbsent(category, () => []).add(item);
      _checkboxStates[item] = false;
    });
    _addToShoppingList(_userId, item); // Existing line for shopping list
  } else {
    setState(() {
      _pantryList.putIfAbsent(category, () => []).add(item);
      _checkboxStates[item] = false;
    });
    _addToPantryList( _userId, item); // New line for pantry list
  }
}



  void _toggleCheckbox(String category, String item, bool type) {
    setState(() {
      final isChecked = !(_checkboxStates[item] ?? false);
      _checkboxStates[item] = isChecked;
      //_checkboxStates[item] = !(_checkboxStates[item] ?? false);
    });
    // if (type) {
    //   if (_dontShowAgain) {
    //     _moveItem(category, item);
    //   } else {
    //     _showConfirmationDialog(category, item);
    //   }
    // } else {
    //   if (_dontShowAgain) {
    //     _movePantryItem(category, item);
    //   } else {
    //     _showPantryConfirmationDialog(category, item);
    //   }
    // }
  }

  void _movePantryItem(String category, String item) {
    setState(() {
      final isChecked = !(_checkboxStates[item] ?? false);
      _checkboxStates[item] = isChecked;

      if (isChecked) {
        // Move item from shopping list to pantry list if it's not already in pantry list
        if (!_shoppingList.values.any((list) => list.contains(item))) {
          _pantryList[category]?.remove(item);
          _shoppingList.putIfAbsent(category, () => []).add(item);
        } else {
          // Remove item from shopping list if it's already in pantry list
          _pantryList[category]?.remove(item);
        }
      } else {
        // Move item from pantry list back to shopping list if it's not already in shopping list
        if (!_pantryList.values.any((list) => list.contains(item))) {
          _shoppingList[category]?.remove(item);
          _pantryList.putIfAbsent(category, () => []).add(item);
        } else {
          // Remove item from pantry list if it's already in shopping list
          _shoppingList[category]?.remove(item);
        }
      }

      // Remove category if empty
      if (_shoppingList[category]?.isEmpty ?? true) {
        _shoppingList.remove(category);
      }
      if (_pantryList[category]?.isEmpty ?? true) {
        _pantryList.remove(category);
      }

      // Ensure checkbox is not checked for items in the pantry list
      if (_shoppingList.values.any((list) => list.contains(item))) {
        _checkboxStates[item] = false;
      }
    });
  }

  void _moveItem(String category, String item) {
    setState(() {
      final isChecked = !(_checkboxStates[item] ?? false);
      _checkboxStates[item] = isChecked;

      if (isChecked) {
        // Move item from shopping list to pantry list if it's not already in pantry list
        if (!_pantryList.values.any((list) => list.contains(item))) {
          _shoppingList[category]?.remove(item);
          _pantryList.putIfAbsent(category, () => []).add(item);
        } else {
          // Remove item from shopping list if it's already in pantry list
          _shoppingList[category]?.remove(item);
        }
      } else {
        // Move item from pantry list back to shopping list if it's not already in shopping list
        if (!_shoppingList.values.any((list) => list.contains(item))) {
          _pantryList[category]?.remove(item);
          _shoppingList.putIfAbsent(category, () => []).add(item);
        } else {
          // Remove item from pantry list if it's already in shopping list
          _pantryList[category]?.remove(item);
        }
      }

      // Remove category if empty
      if (_shoppingList[category]?.isEmpty ?? true) {
        _shoppingList.remove(category);
      }
      if (_pantryList[category]?.isEmpty ?? true) {
        _pantryList.remove(category);
      }

      // Ensure checkbox is not checked for items in the pantry list
      if (_pantryList.values.any((list) => list.contains(item))) {
        _checkboxStates[item] = false;
      }
    });
  }

  void _showConfirmationDialog(String category, String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool localDontShowAgain = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add $item to your Pantry'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: localDontShowAgain,
                        onChanged: (bool? value) {
                          setState(() {
                            localDontShowAgain = value ?? false;
                          });
                        },
                      ),
                      Text("Don't show again"),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Yes'),
                  onPressed: () {
                    setState(() {
                      _dontShowAgain = localDontShowAgain;
                      _setDontShowAgainPreference(_dontShowAgain);
                      _moveItem(category, item);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPantryConfirmationDialog(String category, String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool localDontShowAgain = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add $item to your Shopping List'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: localDontShowAgain,
                        onChanged: (bool? value) {
                          setState(() {
                            localDontShowAgain = value ?? false;
                          });
                        },
                      ),
                      Text("Don't show again"),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Yes'),
                  onPressed: () {
                    setState(() {
                      _dontShowAgain = localDontShowAgain;
                      _setDontShowAgainPreference(_dontShowAgain);
                      _movePantryItem(category, item);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          // Shopping List Column
          // Pantry List Column
          Expanded(
            //Container(
            //width: 600.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                //100.0, // left padding
                0,
                20.0, // top padding
                0.0, // right padding
                0.0, // bottom padding
              ), // Adjust the top padding as needed
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Left-align children
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Shopping List',
                      style: TextStyle(
                        fontSize: 24.0, // Set the font size for h2 equivalent
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                      textAlign: TextAlign.left, // Ensure text is left-aligned
                    ),
                  ),
                  // Pantry list items with categories and checkboxes
                  Expanded(
                    child: ListView(
                      children: _shoppingList.entries.expand((entry) {
                        return [
                          if (entry.value.isNotEmpty) ...[
                            _buildCategoryHeader(entry.key),
                          ],
                          ...entry.value.asMap().entries.map((item) =>
                              _buildCheckableListItem(entry.key, item.value,
                                  item.key % 2 == 1, true)),
                          //Divider(thickness: 2),
                        ];
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddItemDialog(context, 'Shopping');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFFDC945F), // Button background color
                        foregroundColor: Colors.white, // Text color
                        fixedSize:
                            Size(48.0, 48.0), // Ensure the button is square
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16), // Rounded corners
                        ),
                        padding: EdgeInsets.all(0), // Remove default padding
                      ),
                      child: Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 35, // Increase the font size
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Pantry List Column
          Expanded(
            //Container(
            //width: 600.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                //100.0, // left padding
                0,
                20.0, // top padding
                0.0, // right padding
                0.0, // bottom padding
              ), // Adjust the top padding as needed
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Left-align children
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Pantry',
                      style: TextStyle(
                        fontSize: 24.0, // Set the font size for h2 equivalent
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                      textAlign: TextAlign.left, // Ensure text is left-aligned
                    ),
                  ),
                  // Pantry list items with categories and checkboxes
                  Expanded(
                    child: ListView(
                      children: _pantryList.entries.expand((entry) {
                        return [
                          if (entry.value.isNotEmpty) ...[
                            _buildCategoryHeader(entry.key),
                          ],
                          ...entry.value.asMap().entries.map((item) =>
                              _buildCheckableListItem(entry.key, item.value,
                                  item.key % 2 == 1, false)),
                          //Divider(thickness: 2),
                        ];
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddItemDialog(context, 'Pantry');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFFDC945F), // Button background color
                        foregroundColor: Colors.white, // Text color
                        fixedSize:
                            Size(48.0, 48.0), // Ensure the button is square
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16), // Rounded corners
                        ),
                        padding: EdgeInsets.all(0), // Remove default padding
                      ),
                      child: Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 35, // Increase the font size
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a category header
  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20.0, // Font size for category headers
          fontWeight: FontWeight.bold, // Bold text for headers
        ),
      ),
    );
  }

  Widget _buildCheckableListItem(
      String category, String title, bool shaded, bool listType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            leading: listType
                ? // Conditionally include the checkbox
                Container(
                    decoration: BoxDecoration(),
                    child: Transform.scale(
                      scale: 1,
                      child: Checkbox(
                        value: _checkboxStates[title] ?? false,
                        onChanged: (bool? value) {
                          _toggleCheckbox(category, title, listType);
                        },
                      ),
                    ),
                  )
                : null,
            title: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(title),
            ),
            trailing: IconButton(
              icon: SizedBox(
                width: 22, // Set the desired width
                height: 22, // Set the desired height
                child: Image.asset('trash-can.png'),
              ),
              onPressed: () {
                _confirmRemoveItem(context, category, title, listType);
                //_removeFromShoppingList(category, ingredientName);
              },
            ),
            onTap: () {
              if (listType) {
                _toggleCheckbox(category, title, listType);
              }
            },
          ),
        ),
      ),
    );
  }

  void _confirmRemoveItem(
      BuildContext context, String category, String title, bool listType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          // Apply custom theme to the AlertDialog
          data: ThemeData(
            // Set the background color to white
            dialogBackgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
          child: AlertDialog(
            title: Text("Confirm Remove"),
            content: Text(
                "Are you sure you want to remove '$title' from the ${listType ? 'Shopping List' : 'Pantry'}?"),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  side: BorderSide(
                    color: Colors.orange,
                    width: 1.5, // Border thickness
                  ), // Outline color
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFDC945F), // Set the color to orange
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFDC945F), // Background color
                ),
                child: Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.white, // Set the color to white
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  _removeItem(category, title, listType); // Remove the item
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeItem(String category, String title, bool listType) {
    setState(() {
      if (listType) {
        _removeFromShoppingList(category, title);
        _shoppingList[category]?.remove(title);
        if (_shoppingList[category]?.isEmpty ?? true) {
          _shoppingList.remove(category);
        }
      } else {
        _removeFromPantryList(category, title);
        _pantryList[category]?.remove(title);
        if (_pantryList[category]?.isEmpty ?? true) {
          _pantryList.remove(category);
        }
      }
      _checkboxStates.remove(title);
    });
  }

  void _showAddItemDialog(BuildContext context, String type) {
    final TextEditingController _textFieldController = TextEditingController();
    final TextEditingController _foodTypeController = TextEditingController();
    // String? selectedCategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          // Apply custom theme to the AlertDialog
          data: ThemeData(
            // Set the background color to white
            dialogBackgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
          child: AlertDialog(
            title: Text('Add New Item To $type List'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _foodTypeController, // Use the controller here
                    decoration: InputDecoration(labelText: 'Select Food Type'),
                  ),
                  suggestionsCallback: (pattern) {
                    return _categories.where((category) =>
                        category.toLowerCase().contains(pattern.toLowerCase()));
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    _foodTypeController.text = suggestion;
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _textFieldController,
                    decoration: InputDecoration(hintText: "Enter item name"),
                  ),
                  suggestionsCallback: (pattern) {
                    return _items.where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()));
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    _textFieldController.text = suggestion;
                  },
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an item name' : null,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  side: BorderSide(
                    color: Colors.orange,
                    width: 1.5, // Border thickness
                  ), // Outline color
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFDC945F), // Set the color to orange
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFDC945F), // Background color
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white, // Set the color to orange
                  ),
                ),
                onPressed: () {
                  if (_foodTypeController.text.isNotEmpty &&
                      _textFieldController.text.isNotEmpty) {
                    if (type == 'Shopping') {
                      _addItem(
                        _foodTypeController.text,
                        _textFieldController.text,
                        true,
                      );
                    } else {
                      _addItem(
                        _foodTypeController.text,
                        _textFieldController.text,
                        false,
                      );
                    }
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

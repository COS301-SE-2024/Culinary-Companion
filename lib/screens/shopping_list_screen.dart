import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart'
    as http; // Add this line to import the http package
import 'dart:convert'; // Add this line to import the dart:convert library for JSON parsing
import '../widgets/help_shopping.dart';

Color shade(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.light
      ? Color.fromARGB(181, 52, 78, 70)
      : Color(0xFF344E46);
}

// color: shaded ? Color(0xFF344E46) : Color(0xFF1D2C1F)
Color unshade(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.light
      ? Color.fromARGB(188, 29, 44, 31)
      : Color(0xFF1D2C1F);
}

class ShoppingListScreen extends StatefulWidget {
  final http.Client? client;

  ShoppingListScreen({Key? key, this.client}) : super(key: key);

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  //late http.Client _client;
  String? _userId;
  OverlayEntry? _helpMenuOverlay;

  @override
  void initState() {
    super.initState();
    //_client = widget.client ?? http.Client();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserId();
    _fetchIngredientNames();
    _loadDontShowAgainPreference();
    _fetchShoppingList();
  }

  final Map<String, List<String>> _shoppingList = {};
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
        //print('Failed to fetch ingredient names: ${response.statusCode}');
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
          'userId':
              _userId, //'dcd8108f-acc2-4be8-aef6-69d5763f8b5b', // Hardcoded user ID
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
        //print('Failed to fetch shopping list: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Error fetching shopping list: $error');
    }
  }

  Future<void> _addToShoppingList(String? userId, String ingredientName) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'addToShoppingList',
          'userId': userId,
          'ingredientName': ingredientName,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        //print('Successfully added $ingredientName to shopping list');
      } else {
        print(
            'Failed to add $ingredientName to shopping list: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding $ingredientName to shopping list: $error');
    }
  }

  Future<void> _removeFromShoppingList(
      String category, String ingredientName) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
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
        print(
            'Failed to remove item from shopping list: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Error removing item from shopping list: $error');
    }
  }

  // ignore: unused_field
  bool _dontShowAgain = false;

  Future<void> _loadDontShowAgainPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dontShowAgain = prefs.getBool('dontShowAgain') ?? false;
    });
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
        _checkboxStates[item] = false;
      });
    }
  }

  void _toggleCheckbox(String category, String item, bool type) {
    setState(() {
      final isChecked = !(_checkboxStates[item] ?? false);
      _checkboxStates[item] = isChecked;
    });
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
        title: Padding(
          padding: EdgeInsets.only(top: 30, left: 38.0),
          child: Text(
            'Shopping List',
            style: TextStyle(
              fontSize: 24.0, // Set the font size for h2 equivalent
              fontWeight: FontWeight.bold, // Make the text bold
            ),
          ),
        ),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Row(
          children: <Widget>[
            // Shopping List Column
            Expanded(
              // Adjust the top padding as needed
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Left-align children
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 30.0),
                  // Shopping list items with categories and checkboxes
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
                        ];
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      key: ValueKey('Pantry'),
                      onPressed: () {
                        _showAddItemDialog(context, 'Shopping');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFDC945F), // Button background color
                        foregroundColor: Colors.white, // Text color
                        fixedSize: const Size(
                            48.0, 48.0), // Ensure the button is square
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16), // Rounded corners
                        ),
                        padding:
                            const EdgeInsets.all(0), // Remove default padding
                      ),
                      child: const Center(
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
          ],
        ),
      ),
    );
  }

  // Helper method to build a category header
  Widget _buildCategoryHeader(String title) {
    final Map<String, IconData> categoryIcons = {
      'Dairy': Icons.icecream,
      'Meat': Icons.kebab_dining,
      'Fish': Icons.set_meal_outlined,
      'Nuts': Icons.sports_rugby_outlined,
      'Spice/Herb': Icons.grass,
      'Starch': Icons.bakery_dining,
      'Vegetable': Icons.local_florist,
      'Vegeterian': Icons.eco_outlined,
      'Fruit': Icons.apple,
      'Legume': Icons.grain, //scatter_plot
      'Staple': Icons.breakfast_dining,
      'Other': Icons.workspaces,
    };

    final Map<String, Color> categoryColors = {
      'Dairy': const Color.fromARGB(255, 255, 190, 24),
      'Meat': Color.fromARGB(255, 163, 26, 16),
      'Fish': Colors.blue,
      'Nuts': Color.fromARGB(255, 131, 106, 98),
      'Spice/Herb': Colors.green,
      'Starch': Colors.orange,
      'Vegetable': Colors.green,
      'Vegeterian': Colors.green,
      'Fruit': Colors.red,
      'Legume': Color.fromARGB(255, 131, 106, 98),
      'Staple': const Color.fromARGB(255, 225, 195, 151),
      'Other': Colors.grey,
    };

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(categoryIcons[title] ?? Icons.category,
              color: categoryColors[title] ?? Colors.black),
          SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.0, // Font size for category headers
              fontWeight: FontWeight.bold, // Bold text for headers
              color: categoryColors[title] ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckableListItem(
      String category, String title, bool shaded, bool listType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: shaded ? shade(context) : unshade(context),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
            leading: listType
                ? // Conditionally include the checkbox
                Container(
                    decoration: const BoxDecoration(),
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
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () {
                _confirmRemoveItem(context, category, title, listType);
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
            dialogBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          child: AlertDialog(
            title: const Text("Confirm Remove"),
            content: Text(
                "Are you sure you want to remove '$title' from the Shopping List?"),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.orange,
                    width: 1.5, // Border thickness
                  ), // Outline color
                ),
                child: const Text(
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
                  backgroundColor: const Color(0xFFDC945F), // Background color
                ),
                child: const Text(
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
      }
      _checkboxStates.remove(title);
    });
  }

  void _showAddItemDialog(BuildContext context, String type) {
    final TextEditingController textFieldController = TextEditingController();
    final TextEditingController foodTypeController = TextEditingController();
    // String? selectedCategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          // Apply custom theme to the AlertDialog
          data: ThemeData(
            // Set the background color to white
            dialogBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          child: AlertDialog(
            title: Text('Add New Item To $type List'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: foodTypeController, // Use the controller here
                    decoration:
                        const InputDecoration(labelText: 'Select Food Type'),
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
                    foodTypeController.text = suggestion;
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: textFieldController,
                    decoration:
                        const InputDecoration(hintText: "Enter item name"),
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
                    textFieldController.text = suggestion;
                  },
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an item name' : null,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.orange,
                    width: 1.5, // Border thickness
                  ), // Outline color
                ),
                child: const Text(
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
                  backgroundColor: const Color(0xFFDC945F), // Background color
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white, // Set the color to orange
                  ),
                ),
                onPressed: () {
                  if (foodTypeController.text.isNotEmpty &&
                      textFieldController.text.isNotEmpty) {
                    if (type == 'Shopping') {
                      _addItem(
                        foodTypeController.text,
                        textFieldController.text,
                        true,
                      );
                    } else {
                      _addItem(
                        foodTypeController.text,
                        textFieldController.text,
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

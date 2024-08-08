import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'help_shopping.dart';
import 'package:lottie/lottie.dart';

Color shade(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.light
      ? Color.fromARGB(181, 52, 78, 70)
      : Color(0xFF344E46);
}

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
  String? _userId;
  OverlayEntry? _helpMenuOverlay;
  String _measurementUnit = ''; 
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
  setState(() {
    _isLoading = true;
  });
  await _loadUserId();
  await _fetchIngredientNames();
  _loadDontShowAgainPreference();
  await _fetchShoppingList();
  if(mounted){
  setState(() {
    _isLoading = false;
  });}
}


  final Map<String, List<String>> _shoppingList = {};
  final Map<String, bool> _checkboxStates = {};

  List<Map<String, String>> _items = [];

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _fetchIngredientNames() async {
  try {
    final response = await http.post(
      Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      body: '{"action": "getIngredientNames"}',
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _items = data.map((item) => {
          'id': item['id'].toString(),
          'name': item['name'].toString(),
          'category': item['category'].toString(),
          'measurementUnit': item['measurementUnit'].toString(),
        }).toList();
      });
    } else {
      print('Failed to fetch ingredient names: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching ingredient names: $error');
  }
}


  Future<void> _fetchShoppingList() async {
  try {
    final response = await http.post(
      Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      body: jsonEncode({
        'action': 'getShoppingList',
        'userId': _userId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> shoppingList = data['shoppingList'];
      setState(() {
        _shoppingList.clear();
        for (var item in shoppingList) {
          final ingredientName = item['ingredientName'].toString();
          final category = item['category'] ?? 'Other';
          final quantity = item['quantity'] ?? 1.0;
          final measurementUnit = item['measurmentunit'] ?? 'unit';
          final displayText = '$ingredientName ($quantity $measurementUnit)';
          _shoppingList.putIfAbsent(category, () => []);
          _shoppingList[category]?.add(displayText);
        }
      });
    } else {
      print('Failed to fetch shopping list: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching shopping list: $error');
  }
}


  void _addItem(String category, String item, double quantity, String measurementUnit) {
  setState(() {
    _shoppingList.putIfAbsent(category, () => []).add('$item ($quantity $measurementUnit)');
    _checkboxStates['$item ($quantity $measurementUnit)'] = false;
  });
  _addToShoppingList(_userId, item, quantity, measurementUnit); // Pass quantity and measurementUnit
}


Future<void> _addToShoppingList(String? userId, String ingredientName, double quantity, String measurementUnit) async {
  try {
    final response = await http.post(
      Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      body: jsonEncode({
        'action': 'addToShoppingList',
        'userId': userId,
        'ingredientName': ingredientName,
        'quantity': quantity,
        'measurementUnit': measurementUnit,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Successfully added $ingredientName to shopping list with quantity $quantity $measurementUnit');
    } else {
      print('Failed to add $ingredientName to shopping list: ${response.statusCode}');
    }
  } catch (error) {
    print('Error adding $ingredientName to shopping list: $error');
  }
}

Future<void> _editShoppingListItem(String category, String item, double quantity, String measurementUnit) async {
  try {
    final response = await http.post(
      Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      body: jsonEncode({
        'action': 'editShoppingListItem',
        'userId': _userId,
        'ingredientName': item,
        'quantity': quantity,
        'measurementUnit': measurementUnit,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        final displayText = '$item ($quantity $measurementUnit)';
        if (_shoppingList[category] != null) {
          final index = _shoppingList[category]!.indexWhere((ingredient) => ingredient.startsWith(item));
          if (index != -1) {
            _shoppingList[category]![index] = displayText;
          }
        }
      });
      print('Successfully edited $item in shopping list with quantity $quantity $measurementUnit');
    } else {
      print('Failed to edit $item in shopping list: ${response.statusCode}');
    }
  } catch (error) {
    print('Error editing $item in shopping list: $error');
  }
}


  Future<void> _removeFromShoppingList(String category, String item) async {
  // Extract the ingredient name, quantity, and measurement unit from the item string
  final parts = item.split(' (');
  String ingredientName = parts[0];

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
      setState(() {
        _shoppingList[category]?.remove(item);
        if (_shoppingList[category]?.isEmpty ?? true) {
          _shoppingList.remove(category);
        }
        _checkboxStates.remove(item);
      });
      print('Successfully removed $ingredientName from shopping list');
    } else {
      print('Failed to remove $ingredientName from shopping list: ${response.statusCode}');
    }
  } catch (error) {
    print('Error removing $ingredientName from shopping list: $error');
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


  void _toggleCheckbox(String category, String item) {
  setState(() {
    final isChecked = !(_checkboxStates[item] ?? false);
    _checkboxStates[item] = isChecked;
    if (isChecked) {
      Future.delayed(Duration(seconds: 1), () {
        _removeFromShoppingList(category, item);
        _addToPantryList(_userId, item); // Add to pantry
      });
    }
  });
}


Future<void> _addToPantryList(String? userId, String item) async {
  // Extract the ingredient name, quantity, and measurement unit from the item string
  final parts = item.split(' (');
  String ingredientName = parts[0];
  double quantity = 1.0; // Default quantity
  String measurementUnit = 'unit'; // Default measurement unit

  if (parts.length == 2) {
    final quantityParts = parts[1].split(' ');
    if (quantityParts.length == 2) {
      quantity = double.tryParse(quantityParts[0]) ?? 1.0;
      measurementUnit = quantityParts[1].replaceAll(')', '');
    }
  }

  try {
    final response = await http.post(
      Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      body: jsonEncode({
        'action': 'addToPantryList',
        'userId': userId,
        'ingredientName': ingredientName,
        'quantity': quantity,
        'measurementUnit': measurementUnit,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['newQuantity'] != null) {
        print('Updated quantity of $ingredientName in pantry list to ${responseBody['newQuantity']}');
      } else {
        print('Successfully added $ingredientName to pantry list');
      }
    } else {
      print('Failed to add $ingredientName to pantry list: ${response.statusCode}');
    }
  } catch (error) {
    print('Error adding $ingredientName to pantry list: $error');
  }
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
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              key: Key('help_button'),
              icon: Icon(Icons.help),
              onPressed: _showHelpMenu,
              iconSize: 35,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: Lottie.asset('assets/loading.json'))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 30.0),
                        Expanded(
                          child: _shoppingList.isEmpty
                              ? Center(
                                  child: Text(
                                    "No ingredients have been added. Click the plus icon to add your first ingredient!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              : ListView(
                                  key: Key('shopping_list'),
                                  children: _shoppingList.entries.expand((entry) {
                                    return [
                                      if (entry.value.isNotEmpty) ...[
                                        _buildCategoryHeader(entry.key),
                                      ],
                                      ...entry.value.asMap().entries.map((item) =>
                                          _buildCheckableListItem(entry.key,
                                              item.value, item.key % 2 == 1)),
                                    ];
                                  }).toList(),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            key: ValueKey('add_shopping_list_button'),
                            onPressed: () {
                              _showAddItemDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC945F),
                              foregroundColor: Colors.white,
                              fixedSize: const Size(48.0, 48.0),
                              shape: const CircleBorder(),
                              padding: EdgeInsets.all(0),
                            ),
                            child: const Icon(Icons.add, size: 32.0),
                          ),
                        ),
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
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;
    
  final Map<String, IconData> categoryIcons = {
    'Dairy': Icons.icecream,
    'Meat': Icons.kebab_dining,
    'Fish': Icons.set_meal_outlined,
    'Nuts': Icons.sports_rugby_outlined,
    'Spice/Herb': Icons.grass,
    'Starch': Icons.bakery_dining,
    'Vegetable': Icons.local_florist,
    'Vegetarian': Icons.eco_outlined,
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
    'Vegetarian': Colors.green,
    'Fruit': Colors.red,
    'Legume': Color.fromARGB(255, 131, 106, 98),
    'Staple': const Color.fromARGB(255, 225, 195, 151),
    'Other': Colors.grey,
  };

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(
          categoryIcons[title] ?? Icons.category,
          size: 28.0,
          color: categoryColors[title] ?? Colors.orange,
        ),
        SizedBox(width: 8.0),
        Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}


  Widget _buildCheckableListItem(String category, String item, bool isShaded) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
        color: isShaded ? shade(context) : unshade(context),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListTile(
        key: ValueKey(item),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Checkbox(
          value: _checkboxStates[item] ?? false,
          onChanged: (bool? value) {
            if (value != null) {
              _toggleCheckbox(category, item);
            }
          },
          activeColor: Colors.orange,
          checkColor: Colors.white,
        ),
        title: Text(
          item,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        trailing: Container(
          margin: EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  _showEditItemDialog(context, category, item);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  _removeFromShoppingList(category, item);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}




  Future<void> _showAddItemDialog(BuildContext context) async {
  String selectedItem = '';
  double quantity = 1.0; // Default quantity

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: ThemeData(
          dialogBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Item to Shopping List'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      TypeAheadFormField<Map<String, String>>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: itemNameController,
                          decoration: InputDecoration(labelText: 'Item Name'),
                        ),
                        suggestionsCallback: (pattern) async {
                          return _items.where((item) =>
                              item['name']!
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()));
                        },
                        itemBuilder: (context, Map<String, String> suggestion) {
                          return ListTile(
                            title: Text(suggestion['name']!),
                          );
                        },
                        onSuggestionSelected: (Map<String, String> suggestion) {
                          itemNameController.text = suggestion['name']!;
                          categoryController.text = suggestion['category']!;
                          selectedItem = suggestion['name']!;
                          setState(() {
                            _measurementUnit = suggestion['measurementUnit']!;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please select an item';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          selectedItem = value!;
                        },
                      ),
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a quantity';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          quantity = double.tryParse(value) ?? 1.0; // Default to 1.0 if parsing fails
                        },
                      ),
                      SizedBox(height: 16.0), // Add spacing for better UI
                      Text('Measurement Unit: $_measurementUnit'), // Display the measurement unit
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFDC945F),
                      width: 1.5,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFFDC945F),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFDC945F),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      final category = categoryController.text;
                      _addItem(category, selectedItem, quantity, _measurementUnit);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}



Future<void> _showEditItemDialog(BuildContext context, String category, String item) async {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  double quantity = 1.0; // Default quantity
  String measurementUnit = 'unit'; // Default measurement unit

  // Extract existing quantity and measurement unit from the item string
  final parts = item.split(' (');
  String itemName = parts[0];
  if (parts.length == 2) {
    final quantityParts = parts[1].split(' ');
    if (quantityParts.length == 2) {
      quantity = double.tryParse(quantityParts[0]) ?? 1.0;
      measurementUnit = quantityParts[1].replaceAll(')', '');
    }
  }

  final TextEditingController quantityController = TextEditingController(text: quantity.toString());

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Edit Item',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: unshade(context),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    quantity = double.tryParse(value) ?? 1.0; // Default to 1.0 if parsing fails
                  },
                ),
                SizedBox(height: 16.0), // Add spacing for better UI
                Text('Measurement Unit: $measurementUnit', style: TextStyle(color: Colors.white)), // Display the measurement unit
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              side: BorderSide(color: Color(0xFFDC945F), width: 1.5),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFDC945F)),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFDC945F),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                _editShoppingListItem(category, itemName, quantity, measurementUnit);
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}
}
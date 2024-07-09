import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/help_shopping.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserId();
    await _fetchIngredientNames();
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
    'Fruit',
    'Legume',
    'Staple',
    'Other'
  ];

  final Map<String, IconData> _categoryIcons = {
    'Dairy': Icons.local_drink,
    'Meat': Icons.local_dining,
    'Fish': Icons.pool,
    'Nuts': Icons.spa,
    'Spice/Herb': Icons.local_florist,
    'Starch': Icons.fastfood,
    'Vegetable': Icons.eco,
    'Fruit': Icons.local_offer,
    'Legume': Icons.grass,
    'Staple': Icons.kitchen,
    'Other': Icons.category,
  };

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
            _shoppingList.putIfAbsent(category, () => []);
            _shoppingList[category]?.add(ingredientName);
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
    _shoppingList.putIfAbsent(category, () => []).add(item);
    _checkboxStates[item] = false;
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
        setState(() {
          _shoppingList[category]?.remove(ingredientName);
        });
      } else {
        print('Failed to remove item from shopping list: ${response.statusCode}');
      }
    } catch (error) {
      print('Error removing item from shopping list: $error');
    }
  }

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
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 30.0),
                  Expanded(
                    child: ListView(
                      children: _shoppingList.entries.expand((entry) {
                        return [
                          if (entry.value.isNotEmpty) ...[
                            _buildCategoryHeader(entry.key),
                          ],
                          ...entry.value.asMap().entries.map((item) =>
                              _buildCheckableListItem(entry.key, item.value,
                                  item.key % 2 == 1)),
                        ];
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      key: ValueKey('Pantry'),
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
            color: Color(0xFF1D2C1F),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildCheckableListItem(
      String category, String item, bool isShaded) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isShaded ? shade(context) : unshade(context),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          key: ValueKey(item),
          leading: Checkbox(
            value: _checkboxStates[item] ?? false,
            onChanged: (bool? value) {
              if (value != null) {
                _toggleCheckbox(category, item);
                if (value) {
                  Future.delayed(Duration(seconds: 1), () {
                    _removeFromShoppingList(category, item);
                  });
                }
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
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _removeFromShoppingList(category, item);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
  String _selectedItem = '';
  double _quantity = 1.0; // Default quantity
  String _measurementUnit = 'unit'; // Default measurement unit

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _measurementUnitController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: ThemeData(
          dialogBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        ),
        child: AlertDialog(
          title: Text('Add Item to Shopping List'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TypeAheadFormField<Map<String, String>>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _itemNameController,
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
                      _itemNameController.text = suggestion['name']!;
                      _categoryController.text = suggestion['category']!;
                      _selectedItem = suggestion['name']!;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please select an item';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _selectedItem = value!;
                    },
                  ),
                  TextFormField(
                    controller: _quantityController,
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
                      _quantity = double.tryParse(value) ?? 1.0; // Default to 1.0 if parsing fails
                    },
                  ),
                  TextFormField(
                    controller: _measurementUnitController,
                    decoration: InputDecoration(
                      labelText: 'Measurement Unit',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a measurement unit';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _measurementUnit = value;
                    },
                  ),
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
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final category = _categoryController.text;
                  _addItem(category, _selectedItem, _quantity, _measurementUnit);
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
        ),
      );
    },
  );
}
}
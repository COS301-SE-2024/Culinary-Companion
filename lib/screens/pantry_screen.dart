import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/help_pantry.dart';

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

class PantryScreen extends StatefulWidget {
  final http.Client? client;

  PantryScreen({Key? key, this.client}) : super(key: key);
  @override
  _PantryScreenState createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen>{
  String? _userId;
  OverlayEntry? _helpMenuOverlay;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserId();
    _fetchIngredientNames();
    _loadDontShowAgainPreference();
    _fetchPantryList();
  }

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

  Future<void> _fetchPantryList() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'getAvailableIngredients',
          'userId':
              _userId, //'dcd8108f-acc2-4be8-aef6-69d5763f8b5b', // Hardcoded user ID
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
        //print('Failed to fetch pantry list: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Error fetching pantry list: $error');
    }
  }

  Future<void> _addToPantryList(String? userId, String ingredientName, double quantity, String measurementUnit) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'addToPantryList', // Change action to addToPantryList
          'userId': userId,
          'ingredientName': ingredientName,
          'quantity': quantity,
          'measurementUnit': measurementUnit,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        //print('Successfully added $ingredientName to pantry list');
      } else {
        print(
            'Failed to add $ingredientName to pantry list: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding $ingredientName to pantry list: $error');
    }
  }

  Future<void> _removeFromPantryList(
      String category, String ingredientName) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
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

  // ignore: unused_field
  bool _dontShowAgain = false;

  Future<void> _loadDontShowAgainPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dontShowAgain = prefs.getBool('dontShowAgain') ?? false;
    });
  }

  void _addItem(String category, String item, bool type,double quantity, String measurementUnit) {
    if (type) {
      //do nothing
    } else {
      setState(() {
        _pantryList.putIfAbsent(category, () => []).add(item);
        _checkboxStates[item] = false;
      });
      _addToPantryList(_userId, item,quantity,measurementUnit); // New line for pantry list
    }
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
            'Pantry',
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
                      children: _pantryList.entries.expand((entry) {
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
            _removeFromPantryList(category, item);
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

  List<String> _measurementUnits = ['unit', 'kg', 'g', 'lbs', 'oz', 'ml', 'fl oz'];
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
                  DropdownButtonFormField<String>(
                    value: _measurementUnit,
                    decoration: InputDecoration(
                      labelText: 'Measurement Unit',
                    ),
                    items: _measurementUnits.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _measurementUnit = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a measurement unit';
                      }
                      return null;
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
                  _addItem(category, _selectedItem, false,_quantity, _measurementUnit);
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
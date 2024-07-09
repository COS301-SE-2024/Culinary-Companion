import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/help_appliance.dart';

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

class AppliancesPage extends StatefulWidget {
  @override
  _AppliancesPageState createState() => _AppliancesPageState();
}

class _AppliancesPageState extends State<AppliancesPage> {
  OverlayEntry? _helpMenuOverlay;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserId();
    await _loadAppliances();
    await _loadUserAppliances();
  }

  String? _userId;

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  List<String> appliances =
      []; //change code to get appliances from the database

  List<String> allAppliances = [];

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
          allAppliances = data.map<String>((cuisine) {
            return cuisine['name'].toString();
          }).toList();
        });
      } else {
        throw Exception('Failed to load appliances');
      }
    } catch (e) {
      throw Exception('Error fetching appliances: $e');
    }
  }

  Future<void> _loadUserAppliances() async {
    var response = await http.post(
      Uri.parse(
          'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'), // Replace with your API endpoint
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'action': 'getUserAppliances',
        'userId': _userId,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> appliancesJson = jsonDecode(response.body);

      setState(() {
        appliances = appliancesJson
            .map((appliance) => appliance['applianceName'].toString())
            .toList();
      });

      // Print the appliances to verify
      //print(appliances);
    } else {
      print('Failed to fetch appliances');
    }
  }

  void _addAppliance(String appliance) async {
    final success = await _addUserApplianceToDatabase(appliance);
    if (success) {
      setState(() {
        appliances.add(appliance);
      });
    }
  }

  Future<bool> _addUserApplianceToDatabase(String applianceName) async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'; // Replace with your actual API endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'addUserAppliance',
          'userId': _userId,
          'applianceName': applianceName,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to add appliance');
        return false;
      }
    } catch (e) {
      print('Error adding appliance: $e');
      return false;
    }
  }

  Future<bool> _removeUserApplianceFromDatabase(String applianceName) async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'; // Replace with your actual API endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'removeUserAppliance',
          'userId': _userId,
          'applianceName': applianceName,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to remove appliance');
        return false;
      }
    } catch (e) {
      print('Error removing appliance: $e');
      return false;
    }
  }

  void _removeAppliance(String appliance) async {
    final success = await _removeUserApplianceFromDatabase(appliance);
    if (success) {
      setState(() {
        appliances.remove(appliance);
      });
    }
  }

  void _showAddApplianceDialog() {
    final TextEditingController typeAheadController = TextEditingController();
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
            title: const Text('Add Appliance'),
            content: TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: typeAheadController,
                decoration: const InputDecoration(labelText: 'Appliance'),
              ),
              suggestionsCallback: (pattern) {
                return allAppliances.where((item) =>
                    item.toLowerCase().contains(pattern.toLowerCase()));
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                typeAheadController.text = suggestion;
              },
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFDC945F),
                    width: 1.5, // Border thickness
                  ),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC945F), // Background color
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white, // Set the color to orange
                  ),
                ),
                onPressed: () {
                  final newItem = typeAheadController.text;
                  if (newItem.isNotEmpty && !appliances.contains(newItem)) {
                    _addAppliance(newItem);
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
            'Appliances',
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
        child: Row(children: <Widget>[
          Expanded(
            // Adjust the top padding as needed
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Left-align children
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 30.0),
                Expanded(
                  child: appliances.isEmpty
                      ? Center(
                          child: Text(
                            "No appliances have been added. Click the plus icon to add your first appliance!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: appliances.length,
                          itemBuilder: (context, index) {
                            final appliance = appliances[index];
                            return Card(
                              color: index.isEven
                                  ? shade(context)
                                  : unshade(context),
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                leading:
                                    Icon(Icons.kitchen, color: Colors.white),
                                title: Text(
                                  appliance,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: Colors.white),
                                  onPressed: () {
                                    _removeAppliance(appliance);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    key: ValueKey('Appliances'),
                    onPressed: _showAddApplianceDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFDC945F), // Button background color
                      foregroundColor: Colors.white, // Text color
                      fixedSize:
                          const Size(48.0, 48.0), // Ensure the button is square
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // Rounded corners
                      ),
                      padding:
                          const EdgeInsets.all(0), // Remove default padding
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

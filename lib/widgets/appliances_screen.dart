import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'help_appliance.dart';
import 'package:lottie/lottie.dart';

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

class AppliancesScreen extends StatefulWidget {
  final http.Client? client;

  AppliancesScreen({Key? key, this.client}) : super(key: key);
  @override
  _AppliancesScreenState createState() => _AppliancesScreenState();
}

class _AppliancesScreenState extends State<AppliancesScreen> {
  OverlayEntry? _helpMenuOverlay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await _loadUserId();
    await _loadAppliances();
    await _loadUserAppliances();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _userId;

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getString('userId');
      });
    }
  }

  List<String> appliances =
      []; //change code to get appliances from the database

  List<String> allAppliances = [];

  Future<void> _loadAppliances() async {
    final prefs = await SharedPreferences.getInstance();
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

        // Cache the appliance data locally
        await prefs.setString('cachedAllAppliances', json.encode(data));

        if (mounted) {
          setState(() {
            allAppliances = data.map<String>((appliance) {
              return appliance['name'].toString();
            }).toList();

            // Sort appliances alphabetically by name
            allAppliances.sort((a, b) => a.compareTo(b));
          });
        }
      } else {
        throw Exception('Failed to load appliances');
      }
    } catch (e) {
      //print('Error fetching appliances: $e');

      // Load cached appliances if the network request fails
      final cachedData = prefs.getString('cachedAllAppliances');
      if (cachedData != null) {
        final List<dynamic> cachedAppliances = json.decode(cachedData);
        if (mounted) {
          setState(() {
            allAppliances = cachedAppliances.map<String>((appliance) {
              return appliance['name'].toString();
            }).toList();

            // Sort appliances alphabetically by name
            allAppliances.sort((a, b) => a.compareTo(b));
          });
        }
      }
    }
  }

  Future<void> _loadUserAppliances() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
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

        // Cache the appliances data locally
        await prefs.setString('cachedAppliances', jsonEncode(appliancesJson));

        if (mounted) {
          setState(() {
            appliances = appliancesJson
                .map((appliance) => appliance['applianceName'].toString())
                .toList();

            // Sort the appliances alphabetically
            appliances.sort((a, b) => a.compareTo(b));
          });
        }

        // Print the appliances to verify
        //print(appliances);
      } else {
        print('Failed to fetch appliances');
      }
    } catch (error) {
      final cachedData = prefs.getString('cachedAppliances');
      if (cachedData != null) {
        final List<dynamic> appliancesJson = jsonDecode(cachedData);
        if (mounted) {
          setState(() {
            appliances = appliancesJson
                .map((appliance) => appliance['applianceName'].toString())
                .toList();

            // Sort the appliances alphabetically
            appliances.sort((a, b) => a.compareTo(b));
          });
        }
      }
    }
  }

  void _addAppliance(String appliance) async {
    final success = await _addUserApplianceToDatabase(appliance);
    if (success) {
      if (mounted) {
        setState(() {
          appliances.add(appliance);
        });
      }
    }
  }

  Future<bool> _addUserApplianceToDatabase(String applianceName) async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
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
      if (mounted) {
        setState(() {
          appliances.remove(appliance);
        });
      }
    }
  }

  void _showAddApplianceDialog() {
    final TextEditingController typeAheadController = TextEditingController();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Theme(
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
                key: ValueKey('Appliances'),
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
          padding: EdgeInsets.only(top: 30, left: 30.0),
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
                                key: Key('appliances_list'),
                                itemCount: appliances.length,
                                itemBuilder: (context, index) {
                                  final appliance = appliances[index];
                                  return Card(
                                    key: Key('appliance_item_$index'),
                                    color: index.isEven
                                        ? shade(context)
                                        : unshade(context),
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    child: ListTile(
                                      key: Key('appliance_item_$index'),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      leading: Icon(Icons.kitchen,
                                          color: Colors.white),
                                      title: Text(
                                        appliance,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        key: Key('delete_appliance_$index'),
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
                          key: Key('add_appliance_button'),
                          onPressed: _showAddApplianceDialog,
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
              ]),
            ),
    );
  }
}

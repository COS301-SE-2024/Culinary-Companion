import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AppliancesPage extends StatefulWidget {
  @override
  _AppliancesPageState createState() => _AppliancesPageState();
}

class _AppliancesPageState extends State<AppliancesPage> {
  List<String> appliances = [
    'Oven',
    'Stove',
    'Blender',
    'Airfryer'
  ]; //change code to get appliances from the database
  final List<String> allAppliances = [
    'Oven',
    'Stove',
    'Blender',
    'Airfryer',
    'Microwave',
    'Toaster'
  ];

  void _addAppliance(String appliance) {
    setState(() {
      appliances.add(appliance);
    });
  }

  void _removeAppliance(String appliance) {
    setState(() {
      appliances.remove(appliance);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
        //   Container(  
        //     decoration: BoxDecoration(
        //       image: DecorationImage(  
        //         image: AssetImage('background.png'),
        //         fit: BoxFit.cover,
        //       ),
        //     ),
        //   ),
        //Foreground content
        Padding(  
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Row(
            children: <Widget>[
              // Pantry List Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    0, // left padding
                    20.0, // top padding
                    0.0, // right padding
                    0.0, // bottom padding
                  ), // Adjust the top padding as needed
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Left-align children
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Appliances',
                          style: TextStyle(
                            fontSize: 24.0, // Set the font size for h2 equivalent
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                          textAlign:
                              TextAlign.left, // Ensure text is left-aligned
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: appliances.length,
                          itemBuilder: (context, index) {
                            final appliance = appliances[index];
                            return Card(
                              color: index.isEven ? Color(0xFF1D2C1F) : Color(0xFF344E46),
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                leading: Icon(Icons.kitchen, color: Colors.white),
                                title: Text(
                                  appliance,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.white),
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
                          onPressed: _showAddApplianceDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFFDC945F), // Button background color
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
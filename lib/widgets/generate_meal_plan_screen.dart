import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../gemini_service.dart'; // LLM
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GenerateMealPlanScreen extends StatefulWidget {
  final TabController tabController;

  // Accept TabController as a parameter
  GenerateMealPlanScreen({required this.tabController});

  @override
  GenerateMealPlanState createState() => GenerateMealPlanState();
}

class GenerateMealPlanState extends State<GenerateMealPlanScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  final _formKey = GlobalKey<FormState>();
  String? _gender;
  String? _mealPlanName;
  double? _height;
  String _heightUnit = 'cm'; // Default unit for height
  double? _weight;
  String _weightUnit = 'kg'; // Default unit for weight
  int? _age;
  int _activityLevel = 1;
  String? _goal;
  int _mealFrequency = 3;
  List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Appetizer',
    'Dessert'
  ];
  List<String> _selectedMeals = [];

  String? _userId;
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getString('userId');
      });
    }
  }

  Future<void> addToMealPlanner(String userId, String recipes) async {
    final url = Uri.parse(
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint');

    // print("userid $userId");
    // print("rec details $recipes");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'action': 'addToMealPlanner',
        'userId': userId,
        'recipes': recipes,
      }),
    );

    if (response.statusCode == 200) {
      print('Meal plan added successfully');
    } else {
      print('Failed to add meal plan: ${response.body}');
    }
  }

  void _showValidationDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Missing Information'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF283330) : Colors.white;
    // Declare a variable to hold the validation state
    bool isMealTypeSelected = true;

    return SingleChildScrollView(
        padding: EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Personal Information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              //name
              TextFormField(
                cursorColor: textColor,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Meal Plan Name:',
                  labelStyle: TextStyle(fontSize: 20, color: textColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFA9B8AC),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFDC945F),
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _mealPlanName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a meal plan name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Gender
              DropdownButtonFormField<String>(
                dropdownColor:
                    isLightTheme ? Colors.white : const Color(0xFF283330),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Gender:',
                  labelStyle: TextStyle(fontSize: 20, color: textColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFA9B8AC),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFDC945F),
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0,
                  ),
                ),
                value: _gender,
                items: ['Female', 'Male', 'Other']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value; // Save the selected gender
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

// Height
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      cursorColor: textColor,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: 'Height:',
                        labelStyle: TextStyle(fontSize: 20, color: textColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFA9B8AC),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFDC945F),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _height =
                              double.tryParse(value); // Save the entered height
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your height';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      dropdownColor:
                          isLightTheme ? Colors.white : const Color(0xFF283330),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFA9B8AC),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFDC945F),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                      ),
                      value: _heightUnit,
                      items: ['cm', 'm', 'ft', 'in']
                          .map((unit) => DropdownMenuItem(
                                child: Text(unit),
                                value: unit,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _heightUnit = value!; // Save the selected height unit
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

// Weight
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      cursorColor: textColor,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: 'Weight:',
                        labelStyle: TextStyle(fontSize: 20, color: textColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFA9B8AC),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFDC945F),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _weight =
                              double.tryParse(value); // Save the entered weight
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      dropdownColor:
                          isLightTheme ? Colors.white : const Color(0xFF283330),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFA9B8AC),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFDC945F),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                      ),
                      value: _weightUnit,
                      items: ['kg', 'lb']
                          .map((unit) => DropdownMenuItem(
                                child: Text(unit),
                                value: unit,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _weightUnit = value!; // Save the selected weight unit
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Age
              TextFormField(
                cursorColor: textColor,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Age:',
                  labelStyle: TextStyle(fontSize: 20, color: textColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFA9B8AC),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFDC945F),
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _age = int.tryParse(value); // Save the entered age
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Activity Level - Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Level:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _activityLevel.toDouble(),
                    min: 1,
                    max: 4,
                    divisions: 3,
                    label: _getActivityLevelDescription(_activityLevel),
                    onChanged: (value) {
                      setState(() {
                        _activityLevel =
                            value.toInt(); // Save the activity level
                      });
                    },
                    activeColor: Color(0xFFDC945F),
                  ),
                ],
              ),

              SizedBox(height: 24),
              Text('Meal Plan Goals',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              // Goal
              DropdownButtonFormField<String>(
                dropdownColor:
                    isLightTheme ? Colors.white : const Color(0xFF283330),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Dietary Goal:',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    color: textColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFA9B8AC),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFDC945F),
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0,
                  ),
                ),
                value: _goal,
                items: ['Eat Healthy', 'Lose Weight', 'Gain Muscle']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your dietary goal';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _goal = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Meal Frequency - Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferred Meal Frequency (meals/day):',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Slider(
                    value: _mealFrequency.toDouble(),
                    min: 1,
                    max: 6,
                    divisions: 5,
                    label: _getMealFrequencyDescription(_mealFrequency),
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _mealFrequency = value.toInt();
                          _selectedMeals
                              .clear(); //Clear selected meals when frequency changes
                        });
                      }
                    },
                    activeColor: Color(0xFFDC945F),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Meal Type Checkboxes in a Row
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Meal Types:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 100.0,
                    runSpacing: 4.0,
                    children: _mealTypes.map((mealType) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _selectedMeals.contains(mealType),
                            onChanged: _selectedMeals.length < _mealFrequency ||
                                    _selectedMeals.contains(mealType)
                                ? (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedMeals.add(mealType);
                                      } else {
                                        _selectedMeals.remove(mealType);
                                      }
                                      // Check if at least one meal type is selected
                                      isMealTypeSelected =
                                          _selectedMeals.isNotEmpty;
                                    });
                                  }
                                : null, // Disable if limit is reached
                          ),
                          Text(
                            mealType,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  // Display error message if no meal type is selected
                  if (!isMealTypeSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select at least one meal type.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // ensure all form values are filled in
                  if (_mealPlanName == null || _mealPlanName!.isEmpty) {
                    _showValidationDialog("Please enter a meal plan name.");
                    return;
                  }

                  if (_gender == null || _gender!.isEmpty) {
                    _showValidationDialog("Please select your gender.");
                    return;
                  }

                  if (_height == null || _height! <= 0) {
                    _showValidationDialog("Please enter your height.");
                    return;
                  }

                  if (_weight == null || _weight! <= 0) {
                    _showValidationDialog("Please enter your weight.");
                    return;
                  }

                  if (_age == null || _age! <= 0) {
                    _showValidationDialog("Please enter your age.");
                    return;
                  }

                  if (_goal == null || _goal!.isEmpty) {
                    _showValidationDialog("Please select a dietary goal.");
                    return;
                  }

                  if (_selectedMeals.isEmpty) {
                    _showValidationDialog(
                        "Please select at least one meal type.");
                    return;
                  }

                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();

                    // Show loading screen
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(
                          child: Lottie.asset(
                            'assets/planner_load.json',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    );

                    // Call the Gemini function to generate meal plan
                    final result = await fetchMealPlannerRecipes(
                      _userId ?? "",
                      _gender ?? "",
                      _weight?.toString() ?? "",
                      _weightUnit,
                      _height?.toString() ?? "",
                      _heightUnit,
                      _age ?? 0,
                      _getActivityLevelDescription(_activityLevel),
                      _goal ?? "",
                      _mealFrequency.toString(),
                      _selectedMeals.join(","),
                      _mealPlanName ?? "",
                      context,
                    );

                    if (result.isNotEmpty && result != 'Error parsing JSON') {
                      await addToMealPlanner(_userId ?? "", result);
                    }

                    // Close loading dialog and switch to "My Meal Plans" tab
                    Navigator.of(context).pop();
                    widget.tabController.animateTo(1);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC945F),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.09,
                    vertical: 20,
                  ),
                ),
                child: Text(
                  'Generate Meal Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  String _getActivityLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Sedentary';
      case 2:
        return 'Lightly Active';
      case 3:
        return 'Moderately Active';
      case 4:
        return 'Very Active';
      default:
        return '';
    }
  }

  String _getMealFrequencyDescription(int level) {
    switch (level) {
      case 1:
        return '1 meal/day';
      case 2:
        return '2 meals/day';
      case 3:
        return '3 meals/day';
      case 4:
        return '4 meals/day';
      case 5:
        return '5 meals/day';
      case 6:
        return '6 meals/day';
      default:
        return '';
    }
  }
}

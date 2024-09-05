import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GenerateMealPlanScreen extends StatefulWidget {
  final TabController tabController;

  // Accept TabController as a parameter
  GenerateMealPlanScreen({required this.tabController});

  @override
  GenerateMealPlanState createState() => GenerateMealPlanState();
}

class GenerateMealPlanState extends State<GenerateMealPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _gender;
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF283330) : Colors.white;

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
              // Gender
              DropdownButtonFormField<String>(
                dropdownColor: isLightTheme ? Colors.white : Color(0xFF1F4539),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Gender:',
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
                value: _gender,
                items: ['Female', 'Male', 'Other']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
                onChanged: (value) {},
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
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your height';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      dropdownColor:
                          isLightTheme ? Colors.white : Color(0xFF1F4539),
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
                        _heightUnit = value!;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      cursorColor: textColor,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: 'Weight:',
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
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      dropdownColor:
                          isLightTheme ? Colors.white : Color(0xFF1F4539),
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
                        _weightUnit = value!;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Age -add years text at end
              TextFormField(
                cursorColor: textColor,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Age:',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    color: textColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // Adjust the border radius as needed
                    borderSide: const BorderSide(
                      color: Color(0xFFA9B8AC), // Set the border color
                      width: 2.0, // Adjust the border thickness as needed
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        8.0), // Ensure the border radius matches
                    borderSide: const BorderSide(
                      color: Color(
                          0xFFDC945F), // Set the border color when the field is focused
                      width: 2.0, // Adjust the border thickness as needed
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
                onSaved: (value) {},
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
                  SizedBox(height: 16),
                  Slider(
                    value: _activityLevel.toDouble(),
                    min: 1,
                    max: 4,
                    divisions: 3,
                    label: _getActivityLevelDescription(_activityLevel),
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _activityLevel = value.toInt();
                        });
                      }
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
                dropdownColor: isLightTheme ? Colors.white : Color(0xFF1F4539),
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
                onChanged: (value) {},
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
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    // You can process the form data here
                    // For example, save the data to a database or use it to generate meal plans
                    print("Gender: $_gender");
                    print("Height: $_height");
                    print("Weight: $_weight");
                    print("Age: $_age");
                    print("Activity Level: $_activityLevel");
                    print("Goal: $_goal");
                    print("Meal Frequency: $_mealFrequency");
                    print("Selected Meals: $_selectedMeals");

                    // Show loading dialog with Lottie animation
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

                    // Simulate meal plan generation with a delay
                    Future.delayed(Duration(seconds: 10), () {
                      Navigator.of(context).pop();

                      // Switch to "My Meal Plans" tab
                      widget.tabController.animateTo(1);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC945F),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth *
                        0.09, // Adjust the horizontal padding based on screen width
                    vertical:
                        20, // Adjust the vertical padding based on screen width
                  ),
                ),
                child: Text(
                  'Generate Meal Plan',
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontSize: 16, // Text size
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

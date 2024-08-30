import 'package:flutter/material.dart';

class GenerateMealPlanScreen extends StatefulWidget {
  @override
  GenerateMealPlanState createState() => GenerateMealPlanState();
}

class GenerateMealPlanState extends State<GenerateMealPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _gender;
  double? _height;
  double? _weight;
  int? _age;
  int _activityLevel = 1;
  String? _goal;
  int _mealFrequency = 3;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF283330) : Colors.white;

    return SingleChildScrollView(
        padding: EdgeInsets.all(40.0),
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
              // Height - add dropdown to choose cm/inch
              TextFormField(
                cursorColor: textColor,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Height:',
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
                    return 'Please enter your height';
                  }
                  return null;
                },
                onSaved: (value) {},
              ),
              const SizedBox(height: 16),
              // Weight - add dropdown to choose kg/lbs
              TextFormField(
                cursorColor: textColor,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Weight:',
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
                    return 'Please enter your weight';
                  }
                  return null;
                },
                onSaved: (value) {},
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
                  Text('Activity Level:'),
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
              // Dietary Preferences - get this from database, no need to enter again
              // Meal Frequency - Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preferred Meal Frequency (meals/day):'),
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
                        });
                      }
                    },
                    activeColor: Color(0xFFDC945F),
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

                    // Navigate to another page or show a confirmation dialog
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

import 'package:flutter/material.dart';

class GenerateMealPlanScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  String? _gender;
  double? _height;
  double? _weight;
  int? _age;
  String? _activityLevel;
  String? _goal;
  int? _mealFrequency;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Female', 'Male', 'Other']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
              // Height - add dropdown to choose cm/inch
              TextFormField(
                decoration: InputDecoration(labelText: 'Height'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
                onSaved: (value) {},
              ),
              // Weight - add dropdown to choose kg/lbs
              TextFormField(
                decoration: InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
                onSaved: (value) {},
              ),
              // Age -add years at end
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
                onSaved: (value) {},
              ),
              // Activity Level
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Activity Level'),
                items: [
                  'Sedentary',
                  'Lightly Active',
                  'Moderately Active',
                  'Very Active'
                ]
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your activity level';
                  }
                  return null;
                },
                onChanged: (value) {},
              ),
              SizedBox(height: 24),
              Text('Meal Plan Goals',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              // Goal
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Dietary Goal'),
                items: ['Eat Healthy', 'Lose Weight', 'Gain Muscle']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your dietary goal';
                  }
                  return null;
                },
                onChanged: (value) {},
              ),
              // Dietary Preferences - get this from database, no need to enter again
              // Meal Frequency - make this a slider
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Preferred Meal Frequency (meals/day)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your meal frequency';
                  }
                  return null;
                },
                onSaved: (value) {},
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
                child: Text('Generate Meal Plan'),
              ),
            ],
          ),
        ));
  }
}

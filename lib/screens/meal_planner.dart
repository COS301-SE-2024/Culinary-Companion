import 'package:flutter/material.dart';

class MealPlannerPage extends StatefulWidget {
  @override
  _MealPlannerPageState createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  final _formKey = GlobalKey<FormState>();
  String? _gender;
  double? _height;
  double? _weight;
  int? _age;
  String? _activityLevel;
  String? _goal;
  List<String> _dietaryPreferences = [];
  List<String> _allergies = [];
  int? _mealFrequency;
  int? _caloricIntake;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Gender
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              // Height
              TextFormField(
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _height = double.tryParse(value ?? '');
                },
              ),
              // Weight
              TextFormField(
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _weight = double.tryParse(value ?? '');
                },
              ),
              // Age
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _age = int.tryParse(value ?? '');
                },
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
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value;
                  });
                },
              ),
              // Goal
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Dietary Goal'),
                items: [
                  'Lose Weight',
                  'Gain Muscle',
                  'Maintain Weight'
                ]
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _goal = value;
                  });
                },
              ),
              // Dietary Preferences
              TextFormField(
                decoration: InputDecoration(labelText: 'Dietary Preferences'),
                onSaved: (value) {
                  _dietaryPreferences = value?.split(',') ?? [];
                },
              ),
              // Allergies
              TextFormField(
                decoration: InputDecoration(labelText: 'Allergies'),
                onSaved: (value) {
                  _allergies = value?.split(',') ?? [];
                },
              ),
              // Meal Frequency
              TextFormField(
                decoration: InputDecoration(labelText: 'Preferred Meal Frequency (meals/day)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _mealFrequency = int.tryParse(value ?? '');
                },
              ),
              // Caloric Intake
              TextFormField(
                decoration: InputDecoration(labelText: 'Caloric Intake Goal (if known)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _caloricIntake = int.tryParse(value ?? '');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    // Process the form data here
                  }
                },
                child: Text('Save Information'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/generate_meal_plan_screen.dart';
import '../widgets/my_meal_plans_screen.dart';
import '../widgets/help_meal_planner.dart';

class MealPlannerScreen extends StatefulWidget {
  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> with SingleTickerProviderStateMixin {
  OverlayEntry? _helpMenuOverlay;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showHelpMenu() {
    _helpMenuOverlay = OverlayEntry(
      builder: (context) => HelpMealPlanner(
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
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.0),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Generate My Meal Plan'),
                  Tab(text: 'My Meal Plans'),
                ],
                labelColor: textColor,
                unselectedLabelColor: Color(0xFFDC945F),
                indicatorColor: textColor,
              ),
              Positioned(
                right: 20,
                bottom: 5,
                child: IconButton(
                  icon: Icon(Icons.help),
                  onPressed: _showHelpMenu,
                  iconSize: 35,
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GenerateMealPlanScreen(),
          MyMealPlansScreen(),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MealPlannerScreen(),
  ));
}


// import 'package:flutter/material.dart';

// class MealPlannerPage extends StatefulWidget {
//   @override
//   _MealPlannerPageState createState() => _MealPlannerPageState();
// }

// class _MealPlannerPageState extends State<MealPlannerPage> {
//   final _formKey = GlobalKey<FormState>();
//   String? _gender;
//   double? _height;
//   double? _weight;
//   int? _age;
//   String? _activityLevel;
//   String? _goal;
//   List<String> _dietaryPreferences = [];
//   int? _mealFrequency;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Meal Planner'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               // Gender
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(labelText: 'Gender'),
//                 items: ['Male', 'Female', 'Other']
//                     .map((label) => DropdownMenuItem(
//                           child: Text(label),
//                           value: label,
//                         ))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _gender = value;
//                   });
//                 },
//               ),
//               // Height
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Height (cm)'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your height';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _height = double.tryParse(value ?? '');
//                 },
//               ),
//               // Weight
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Weight (kg)'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your weight';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _weight = double.tryParse(value ?? '');
//                 },
//               ),
//               // Age
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Age'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your age';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _age = int.tryParse(value ?? '');
//                 },
//               ),
//               // Activity Level
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(labelText: 'Activity Level'),
//                 items: [
//                   'Sedentary',
//                   'Lightly Active',
//                   'Moderately Active',
//                   'Very Active'
//                 ]
//                     .map((label) => DropdownMenuItem(
//                           child: Text(label),
//                           value: label,
//                         ))
//                     .toList(),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select your activity level';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     _activityLevel = value;
//                   });
//                 },
//               ),
//               // Goal
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(labelText: 'Dietary Goal'),
//                 items: ['Lose Weight', 'Gain Muscle', 'Maintain Weight']
//                     .map((label) => DropdownMenuItem(
//                           child: Text(label),
//                           value: label,
//                         ))
//                     .toList(),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your dietary goal';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     _goal = value;
//                   });
//                 },
//               ),
//               // Dietary Preferences - get this from database, no need to enter again
//               // Meal Frequency
//               TextFormField(
//                 decoration: InputDecoration(
//                     labelText: 'Preferred Meal Frequency (meals/day)'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your meal frequency';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _mealFrequency = int.tryParse(value ?? '');
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState?.validate() ?? false) {
//                     _formKey.currentState?.save();
//                     // You can process the form data here
//                     // For example, save the data to a database or use it to generate meal plans
//                     print("Gender: $_gender");
//                     print("Height: $_height");
//                     print("Weight: $_weight");
//                     print("Age: $_age");
//                     print("Activity Level: $_activityLevel");
//                     print("Goal: $_goal");
//                     print("Dietary Preferences: $_dietaryPreferences");
//                     print("Meal Frequency: $_mealFrequency");

//                     // Navigate to another page or show a confirmation dialog
//                   }
//                 },
//                 child: Text('Generate my meal plan'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

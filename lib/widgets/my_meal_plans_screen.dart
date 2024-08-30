import 'package:flutter/material.dart';

class MyMealPlansScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        // Replace this with real data
        ListTile(
          title: Text('Meal Plan 1'),
          subtitle: Text('Details of Meal Plan 1'),
          onTap: () {
            // Handle navigation to meal plan details
          },
        ),
        ListTile(
          title: Text('Meal Plan 2'),
          subtitle: Text('Details of Meal Plan 2'),
          onTap: () {
            // Handle navigation to meal plan details
          },
        ),
        // Add more meal plans as needed
      ],
    );
  }
}

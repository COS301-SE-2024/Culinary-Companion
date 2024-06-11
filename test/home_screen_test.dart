import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen should build without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    expect(find.text('Categories'), findsOneWidget);
    expect(find.byType(Chip), findsNWidgets(7)); // Assuming there are 7 categories
  });

  // testWidgets('RecipeCard should display recipe information', (WidgetTester tester) async {
  //   final recipe = {
  //     'name': 'Test Recipe',
  //     'description': 'Test Description',
  //     'imagePath': 'assets/test_image.jpg',
  //     'steps': ['Step 1', 'Step 2']
  //   };

  //   await tester.pumpWidget(MaterialApp(home: RecipeCard(
  //     name: recipe['name'] as String, // Cast to String
  //     description: recipe['description'] as String, // Cast to String
  //     imagePath: recipe['imagePath'] as String, // Cast to String
  //     steps: (recipe['steps'] as List).cast<String>(), // Cast each item to String
  //   )));

  //   expect(find.text('Test Recipe'), findsOneWidget);
  //   expect(find.text('Test Description'), findsOneWidget);
  //   expect(find.text('Steps:'), findsOneWidget);
  //   expect(find.text('- Step 1'), findsOneWidget);
  //   expect(find.text('- Step 2'), findsOneWidget);
  // });
}

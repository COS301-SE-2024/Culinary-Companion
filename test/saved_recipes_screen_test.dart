import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/screens/saved_recipes_screen.dart';

void main() {
  testWidgets('SavedRecipesScreen displays text', (WidgetTester tester) async {
    // Build the SavedRecipesScreen widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: SavedRecipesScreen()));

    // Verify that the text 'Saved Recipes' is displayed.
    expect(find.text('Saved Recipes'), findsOneWidget);
  });

  testWidgets('SavedRecipesScreen has center alignment', (WidgetTester tester) async {
    // Build the SavedRecipesScreen widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: SavedRecipesScreen()));

    // Verify that the text is centered within the screen.
    expect(find.byType(Center), findsOneWidget);
    expect(find.text('Saved Recipes'), findsOneWidget);
  });

  testWidgets('SavedRecipesScreen has Scaffold', (WidgetTester tester) async {
    // Build the SavedRecipesScreen widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: SavedRecipesScreen()));

    // Verify that the SavedRecipesScreen widget contains a Scaffold.
    expect(find.byType(Scaffold), findsOneWidget);
  });
}

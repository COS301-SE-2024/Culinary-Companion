import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/shopping_list_screen.dart';

void main() {
  testWidgets('ShoppingListScreen displays correct information', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: ShoppingListScreen()));

    // Verify if the Shopping List text is displayed
    expect(find.text('Shopping List'), findsOneWidget);

    // Verify if the Center widget is present
    expect(find.byType(Center), findsOneWidget);

    // Verify if the Text widget is inside the Center widget
    final centerFinder = find.byType(Center);
    final textFinder = find.descendant(of: centerFinder, matching: find.text('Shopping List'));
    expect(textFinder, findsOneWidget);
  });
}

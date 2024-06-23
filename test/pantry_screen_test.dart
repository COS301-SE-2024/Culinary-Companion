import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/screens/pantry_screen.dart'; // Replace with actual import

import 'pantry_screen_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpPantryScreen(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PantryScreen(client: mockClient)));
    await tester.pumpAndSettle();
  }

  testWidgets('Pantry initializes correctly', (WidgetTester tester) async {
    await pumpPantryScreen(tester);
    
    expect(find.text('Pantry'), findsOneWidget);
    expect(find.byIcon(Icons.help), findsOneWidget);
  });

  testWidgets('Add item button shows dialog', (WidgetTester tester) async {
    await pumpPantryScreen(tester);
    
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    
    expect(find.text('Add New Item To Pantry List'), findsOneWidget);
  });

   testWidgets('Adding an item to the pantry updates the UI', (WidgetTester tester) async {
    await pumpPantryScreen(tester);
    
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TypeAheadFormField<String>).first, 'Dairy');
    await tester.enterText(find.byType(TypeAheadFormField<String>).last, 'Cheese');
    
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Cheese'), findsOneWidget);
  });
}

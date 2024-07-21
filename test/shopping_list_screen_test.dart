import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/widgets/shopping_list_screen.dart'; // Replace with actual import

import 'shopping_list_screen_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpShoppingListScreen(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ShoppingListScreen(client: mockClient)));
    await tester.pumpAndSettle();
  }

  testWidgets('ShoppingListScreen initializes correctly', (WidgetTester tester) async {
    await pumpShoppingListScreen(tester);
    
    expect(find.text('Shopping List'), findsOneWidget);
    expect(find.byIcon(Icons.help), findsOneWidget);
  });

  // testWidgets('Add item button shows dialog', (WidgetTester tester) async {
  //   await pumpShoppingListScreen(tester);
    
  //   await tester.tap(find.byType(ElevatedButton));
  //   await tester.pumpAndSettle();
    
  //   expect(find.text('Add New Item To Shopping List'), findsOneWidget);
  // });
}
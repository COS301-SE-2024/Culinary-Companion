import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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
    
    expect(find.text('Add New Item To Shopping List'), findsOneWidget);
  });

  testWidgets('ShoppingListScreen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ShoppingListScreen(client: mockClient)));

    // Check if the app bar title is present
    expect(find.text('Shopping List'), findsOneWidget);

    // Check if the help icon is present
    expect(find.byIcon(Icons.help), findsOneWidget);

    // Check if the add item button is present
    expect(find.byKey(ValueKey('Pantry')), findsOneWidget);
  });
// testWidgets('Fetch shopping list test', (WidgetTester tester) async {
//   when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
//       .thenAnswer((_) async => http.Response(
//           '{"shoppingList": [{"ingredientName": "Milk", "category": "Dairy"}]}', 200));

//   await tester.pumpWidget(MaterialApp(home: ShoppingListScreen(client: mockClient)));

//   // Wait for the widget to rebuild after fetching data
//   await tester.pumpAndSettle(Duration(seconds: 3));

//   expect(find.text('Milk'), findsOneWidget);
//   expect(find.text('Dairy'), findsOneWidget);
// });

//   testWidgets('Add item to shopping list test', (WidgetTester tester) async {
//   when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
//       .thenAnswer((_) async => http.Response('{}', 200));

//   await tester.pumpWidget(MaterialApp(home: ShoppingListScreen(client: mockClient)));
//   await tester.pumpAndSettle();

//   // Tap the add item button
//   await tester.tap(find.byKey(ValueKey('Pantry')));
//   await tester.pumpAndSettle();

//   // Check if the dialog is open
//   expect(find.text('Add New Item To Shopping List'), findsOneWidget);

//   // Enter item details
//   await tester.enterText(find.byType(TypeAheadFormField).first, 'Dairy');
//   await tester.pumpAndSettle();

//   await tester.enterText(find.byType(TypeAheadFormField).last, 'Cheese');
//   await tester.pumpAndSettle();

//   // Tap the add button
//   await tester.tap(find.text('Add'));
//   await tester.pumpAndSettle();

//   // Verify that the mock was called to add the item
//   verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(2);

//   // Check if the new item is displayed
//   expect(find.text('Cheese'), findsOneWidget);
// });

//   testWidgets('Remove item from shopping list test', (WidgetTester tester) async {
//   when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
//       .thenAnswer((_) async => http.Response(
//           '{"shoppingList": [{"ingredientName": "Milk", "category": "Dairy"}]}', 200));

//   await tester.pumpWidget(MaterialApp(home: ShoppingListScreen(client: mockClient)));
//   await tester.pumpAndSettle(Duration(seconds: 3));

//   // Check if the item is displayed
//   expect(find.text('Milk'), findsOneWidget);

//   // Tap the delete button for the item
//   await tester.tap(find.byIcon(Icons.delete_outline));
//   await tester.pumpAndSettle();

//   // Check if the confirmation dialog is shown
//   expect(find.text('Confirm Remove'), findsOneWidget);

//   // Tap the remove button
//   await tester.tap(find.text('Remove'));
//   await tester.pumpAndSettle();

//   // Verify that the mock was called to remove the item
//   verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(2);

//   // Check if the item is removed
//   expect(find.text('Milk'), findsNothing);
// });

// testWidgets('Toggle checkbox test', (WidgetTester tester) async {
//   when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
//       .thenAnswer((_) async => http.Response(
//           '{"shoppingList": [{"ingredientName": "Milk", "category": "Dairy"}]}', 200));

//   await tester.pumpWidget(MaterialApp(home: ShoppingListScreen(client: mockClient)));
//   await tester.pumpAndSettle(Duration(seconds: 3));

//   // Find the checkbox
//   final checkbox = find.byType(Checkbox);
//   expect(checkbox, findsOneWidget);

//   // Tap the checkbox
//   await tester.tap(checkbox);
//   await tester.pump();

//   // Check if the checkbox is checked
//   expect((tester.widget(checkbox) as Checkbox).value, isTrue);
// });

//   testWidgets('Toggle checkbox test', (WidgetTester tester) async {
//   when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
//       .thenAnswer((_) async => http.Response(
//           '{"shoppingList": [{"ingredientName": "Milk", "category": "Dairy"}]}', 200));

//   await tester.pumpWidget(MaterialApp(home: ShoppingListScreen(client: mockClient)));
//   await tester.pumpAndSettle();

//   // Find the checkbox
//   final checkbox = find.byType(Checkbox).first;

//   // Tap the checkbox
//   await tester.tap(checkbox);
//   await tester.pump();

//   // Check if the checkbox is checked
//   expect((tester.widget(checkbox) as Checkbox).value, isTrue);
// });

  // testWidgets('Show help menu test', (WidgetTester tester) async {
  //   await tester.pumpWidget(MaterialApp(home: ShoppingListScreen(client: mockClient)));

  //   // Tap the help icon
  //   await tester.tap(find.byIcon(Icons.help));
  //   await tester.pumpAndSettle();

  //   // Check if the help menu is shown
  //   expect(find.byType(HelpMenu), findsOneWidget);
  // });
}
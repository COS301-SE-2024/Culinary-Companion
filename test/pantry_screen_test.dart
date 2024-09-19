import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/help_pantry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/widgets/pantry_screen.dart'; // Replace with actual import
//import 'package:flutter/foundation.dart';
import 'pantry_screen_test.mocks.dart';

void mockIsWeb() {
  // ignore: unused_local_variable
  bool kIsWeb = false;
}

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;

  setUp(() {
    mockIsWeb();
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


  testWidgets('Add button is present', (WidgetTester tester) async {
    await pumpPantryScreen(tester);

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Empty state message is shown when pantry is empty', (WidgetTester tester) async {
    await pumpPantryScreen(tester);

    expect(find.text("No ingredients have been added. Click the plus icon to add your first ingredient!"), findsOneWidget);
  });


  testWidgets('Add item dialog opens when add button is tapped', (WidgetTester tester) async {
    await pumpPantryScreen(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add Item to Pantry List'), findsOneWidget);
  });

    testWidgets('Help menu opens when help icon is tapped', (WidgetTester tester) async {
    await pumpPantryScreen(tester);

    await tester.tap(find.byIcon(Icons.help));
    await tester.pumpAndSettle();

    expect(find.byType(HelpMenu), findsOneWidget);
  });

///////////////////////////////
  //   testWidgets('Category headers are displayed correctly', (WidgetTester tester) async {
  //   // Mock the HTTP responses
  //   when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
  //       .thenAnswer((_) async => http.Response(
  //           '{"availableIngredients": [{"name": "Milk", "quantity": "1", "measurmentunit": "liter", "category": "Dairy"}]}', 200));

  //   await pumpPantryScreen(tester);
    
  //   expect(find.text('Dairy'), findsOneWidget);
  //   expect(find.byIcon(Icons.icecream), findsOneWidget);
  // });

  // testWidgets('Pantry items are displayed correctly', (WidgetTester tester) async {
  //   // Mock the HTTP responses
  //   when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
  //       .thenAnswer((_) async => http.Response(
  //           '{"availableIngredients": [{"name": "Milk", "quantity": "1", "measurmentunit": "liter", "category": "Dairy"}]}', 200));

  //   await pumpPantryScreen(tester);
    
  //   expect(find.text('Milk (1 liter)'), findsOneWidget);
  // });

  // testWidgets('Edit and delete buttons are present for pantry items', (WidgetTester tester) async {
  //   // Mock the HTTP responses
  //   when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
  //       .thenAnswer((_) async => http.Response(
  //           '{"availableIngredients": [{"name": "Milk", "quantity": "1", "measurmentunit": "liter", "category": "Dairy"}]}', 200));

  //   await pumpPantryScreen(tester);
    
  //   expect(find.byIcon(Icons.edit), findsOneWidget);
  //   expect(find.byIcon(Icons.delete), findsOneWidget);
  // });

  // testWidgets('Edit dialog opens when edit button is tapped', (WidgetTester tester) async {
  //   // Mock the HTTP responses
  //   when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
  //       .thenAnswer((_) async => http.Response(
  //           '{"availableIngredients": [{"name": "Milk", "quantity": "1", "measurmentunit": "liter", "category": "Dairy"}]}', 200));

  //   await pumpPantryScreen(tester);
    
  //   await tester.tap(find.byIcon(Icons.edit).first);
  //   await tester.pumpAndSettle();
    
  //   expect(find.text('Edit Item'), findsOneWidget);
  // });

  // testWidgets('Item is removed when delete button is tapped', (WidgetTester tester) async {
  //   // Mock the initial HTTP response
  //   when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
  //       .thenAnswer((_) async => http.Response(
  //           '{"availableIngredients": [{"name": "Milk", "quantity": "1", "measurmentunit": "liter", "category": "Dairy"}]}', 200));

  //   await pumpPantryScreen(tester);
    
  //   expect(find.text('Milk (1 liter)'), findsOneWidget);

  //   // Mock the delete response
  //   when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
  //       .thenAnswer((_) async => http.Response('{"availableIngredients": []}', 200));

  //   await tester.tap(find.byIcon(Icons.delete).first);
  //   await tester.pumpAndSettle();
    
  //   expect(find.text('Milk (1 liter)'), findsNothing);
  // });

  // testWidgets('Add item button shows dialog', (WidgetTester tester) async {
  //   await pumpPantryScreen(tester);
    
  //   await tester.tap(find.byType(ElevatedButton));
  //   await tester.pumpAndSettle();
    
  //   expect(find.text('Add New Item To Pantry List'), findsOneWidget);
  // });

  //  testWidgets('Adding an item to the pantry updates the UI', (WidgetTester tester) async {
  //   await pumpPantryScreen(tester);
    
  //   await tester.tap(find.byType(ElevatedButton));
  //   await tester.pumpAndSettle();
    
  //   await tester.enterText(find.byType(TypeAheadFormField<String>).first, 'Dairy');
  //   await tester.enterText(find.byType(TypeAheadFormField<String>).last, 'Cheese');
    
  //   await tester.tap(find.text('Add'));
  //   await tester.pumpAndSettle();

  //   expect(find.text('Cheese'), findsOneWidget);
  // });
}

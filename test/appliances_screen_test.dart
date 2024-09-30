import 'package:flutter/material.dart';
import 'package:culinary_companion/widgets/help_pantry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:culinary_companion/widgets/pantry_screen.dart'; // Replace with actual import

import 'pantry_screen_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApplianceScreen(WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: PantryScreen(client: mockClient)));
    await tester.pumpAndSettle();
  }

  testWidgets('Appliances initializes correctly', (WidgetTester tester) async {
    await pumpApplianceScreen(tester);

    expect(find.text('Pantry'), findsOneWidget);
    expect(find.byIcon(Icons.help), findsOneWidget);
  });

  testWidgets('Add button is present', (WidgetTester tester) async {
    await pumpApplianceScreen(tester);

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Empty state message is shown when Appliances is empty',
      (WidgetTester tester) async {
    await pumpApplianceScreen(tester);

    expect(
        find.text(
            "No ingredients have been added. Click the plus icon to add your first ingredient!"),
        findsOneWidget);
  });

  testWidgets('Add item dialog opens when add button is tapped',
      (WidgetTester tester) async {
    await pumpApplianceScreen(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add Item to Pantry List'), findsOneWidget);
  });

  testWidgets('Help menu opens when help icon is tapped',
      (WidgetTester tester) async {
    await pumpApplianceScreen(tester);

    await tester.tap(find.byIcon(Icons.help));
    await tester.pumpAndSettle();

    expect(find.byType(HelpMenu), findsOneWidget);
  });
}

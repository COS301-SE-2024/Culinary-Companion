import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/widgets/help_home.dart';

// Generate a MockClient using the Mockito package.
@GenerateMocks([http.Client])
import 'home_screen_test.mocks.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    // testWidgets('HomeScreen shows GridView after loading', (WidgetTester tester) async {
    //   // Mock successful HTTP response
    //   when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
    //       .thenAnswer((_) async => http.Response('[]', 200));

    //   await tester.pumpWidget(MaterialApp(home: HomeScreen()));
      
    //   // Wait for async operations and rebuild
    //   await tester.pumpAndSettle();

    //   expect(find.byType(GridView), findsOneWidget);
    // });

    testWidgets('HomeScreen displays help menu when help icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      // Find and tap the help icon
      await tester.tap(find.byIcon(Icons.help));
      await tester.pumpAndSettle();

      // Verify that the HelpMenu is displayed
      expect(find.byType(HelpMenu), findsOneWidget);
    });

  });
}

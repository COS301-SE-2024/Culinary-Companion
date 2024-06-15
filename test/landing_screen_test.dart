import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../lib/screens/landing_screen.dart'; // Adjust the import according to your project structure
import 'mock_navigator_observer.mocks.dart';
import 'package:flutter/services.dart' show rootBundle;


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LandingScreen Tests', () {
    testWidgets('should display logo, buttons, and text correctly', (WidgetTester tester) async {
      // Arrange: Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: LandingScreen(),
        ),
      );

      // Act: Let the widgets build
      await tester.pumpAndSettle();

      // Assert: Verify the UI elements
      expect(find.byType(Image), findsNWidgets(2)); // Background image and logo
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('or'), findsOneWidget);
    });

    testWidgets('should navigate to login screen when Log In button is pressed', (WidgetTester tester) async {
      // Arrange: Set up a mock navigation observer
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          home: LandingScreen(),
          navigatorObservers: [mockObserver],
          routes: {
            '/login': (context) => Scaffold(body: Text('Login Screen')),
          },
        ),
      );

      // Act: Tap the Log In button
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      // Assert: Verify navigation to login screen
      expect(find.text('Login Screen'), findsOneWidget);
      verify(mockObserver.didPush(argThat( isA<MaterialPageRoute>()), any));
    });

    testWidgets('should navigate to signup screen when Sign Up button is pressed', (WidgetTester tester) async {
      // Arrange: Set up a mock navigation observer
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          home: LandingScreen(),
          navigatorObservers: [mockObserver],
          routes: {
            '/signup': (context) => Scaffold(body: Text('Signup Screen')),
          },
        ),
      );

      // Act: Tap the Sign Up button
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Assert: Verify navigation to signup screen
      expect(find.text('Signup Screen'), findsOneWidget);
      verify(mockObserver.didPush(argThat(isA<MaterialPageRoute>()), any));
    });
  });
}
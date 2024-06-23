import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application_1/screens/landing_screen.dart'; // Adjust the import according to your project structure
import 'mock_navigator_observer.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LandingScreen Tests', () {
    testWidgets('should display logo, buttons, and text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LandingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Image), findsNWidgets(2)); // Assuming 2 images are used (background and logo)
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('or'), findsOneWidget);
    });

    testWidgets('should navigate to login screen when Log In button is pressed', (WidgetTester tester) async {
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

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
      verify(mockObserver.didPush(any, any));
    });

    testWidgets('should navigate to signup screen when Sign Up button is pressed', (WidgetTester tester) async {
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

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Signup Screen'), findsOneWidget);
      verify(mockObserver.didPush(any, any));
    });
  });
}

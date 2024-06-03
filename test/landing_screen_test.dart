import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/landing_screen.dart';

void main() {
  testWidgets('LandingScreen has a welcome message', (WidgetTester tester) async {
    // Build the LandingScreen widget.
    await tester.pumpWidget(MaterialApp(home: LandingScreen()));

    // Verify if the welcome message is displayed.
    expect(find.text('Welcome to Culinary Companion'), findsOneWidget);
  });

  testWidgets('LandingScreen has a login button and sign up button', (WidgetTester tester) async {
    // Build the LandingScreen widget.
    await tester.pumpWidget(MaterialApp(home: LandingScreen()));

    // Verify if the login button is displayed.
    expect(find.text('Login'), findsOneWidget);

    // Verify if the sign up button is displayed.
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Login button navigates to /login', (WidgetTester tester) async {
    // Build the LandingScreen widget with a navigator observer.
    await tester.pumpWidget(
      MaterialApp(
        home: LandingScreen(),
        routes: {
          '/login': (context) => Scaffold(body: Text('Login Screen')),
        },
      ),
    );

    // Tap the login button.
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify if the navigator pushed the login route.
    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('Sign Up button navigates to /signup', (WidgetTester tester) async {
    // Build the LandingScreen widget with a navigator observer.
    await tester.pumpWidget(
      MaterialApp(
        home: LandingScreen(),
        routes: {
          '/signup': (context) => Scaffold(body: Text('Sign Up Screen')),
        },
      ),
    );

    // Tap the sign up button.
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify if the navigator pushed the sign up route.
    expect(find.text('Sign Up Screen'), findsOneWidget);
  });
}

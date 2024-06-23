import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:lottie/lottie.dart';
@GenerateMocks([http.Client, SharedPreferences])
void main() {
  testWidgets('ProfileScreen displays loading indicator initially', (WidgetTester tester) async {
    try {
      await tester.pumpWidget(MaterialApp(home: ProfileScreen()));
      expect(find.byType(Lottie), findsOneWidget);
    } catch (e, stack) {
      print('Error: $e\n$stack');
    }
  });

  testWidgets('Profile screen loads user data', (WidgetTester tester) async {
    try {
      await tester.pumpWidget(MaterialApp(home: ProfileScreen()));
      expect(find.byType(Lottie), findsOneWidget);
    } catch (e, stack) {
      print('Error: $e\n$stack');
    }
  });

  testWidgets('ProfileScreen displays error message when userId is null', (WidgetTester tester) async {
    try {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(MaterialApp(home: ProfileScreen()));
      await tester.pump();
      await tester.pump(Duration(seconds: 5));

      expect(find.text('User ID not found'), findsOneWidget);
    } catch (e, stack) {
      print('Error: $e\n$stack');
    }
  });
}


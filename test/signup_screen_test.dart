import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/screens/signup_screen.dart'; // Replace 'your_app_name' with your actual app name

import 'signup_screen_test.mocks.dart';

@GenerateMocks([http.Client, SharedPreferences])
void main() {
  late MockClient mockHttpClient;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockHttpClient = MockClient();
    mockSharedPreferences = MockSharedPreferences();
  });

  testWidgets('SignupScreen widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: SignupScreen(
        httpClient: mockHttpClient,
        sharedPreferences: mockSharedPreferences,
      ),
    ));

    // Verify that the widget renders correctly
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Enter text in the email field
    await tester.enterText(find.widgetWithText(TextFormField, 'Email:'), 'test@example.com');
    expect(find.text('test@example.com'), findsOneWidget);

    // Enter text in the password fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Password:'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

    // Tap the signup button
    when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"user": {"id": "test_user_id"}}', 200));
    when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify that the post request was made
    verify(mockHttpClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).called(1);

    // Verify that the user ID was saved to SharedPreferences
    verify(mockSharedPreferences.setString('userId', 'test_user_id')).called(1);
  });

  testWidgets('SignupScreen shows error dialog on signup failure', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SignupScreen(
        httpClient: mockHttpClient,
        sharedPreferences: mockSharedPreferences,
      ),
    ));

    // Enter valid data
    await tester.enterText(find.widgetWithText(TextFormField, 'Email:'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password:'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

    // Mock a failed response
    when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"error": "Signup failed"}', 400));

    // Tap the signup button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify that the error dialog is shown
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Signup failed'), findsOneWidget);
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'login_screen_test.mocks.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LoginScreen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.byKey(ValueKey('email')), findsOneWidget);
    expect(find.byKey(ValueKey('password')), findsOneWidget);
    expect(find.byKey(ValueKey('Login')), findsOneWidget);
    expect(find.byKey(ValueKey('signupLink')), findsOneWidget);
  });

  testWidgets('Login successful', (WidgetTester tester) async {
    when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"user": {"id": "123"}}', 200));

    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(client: mockClient), // Pass the mock client to LoginScreen
      routes: {
        '/home': (context) => HomeScreen(),
      },
    ));

    await tester.enterText(find.byKey(ValueKey('email')), 'test@example.com');
    await tester.enterText(find.byKey(ValueKey('password')), 'password123');
    await tester.tap(find.byKey(ValueKey('Login')));
    await tester.pumpAndSettle();

    // Verify that the mock was called
    verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);

    // Check if HomeScreen is present
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Login failed', (WidgetTester tester) async {
    when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('{"error": "Invalid credentials"}', 400));

    await tester.pumpWidget(MaterialApp(home: LoginScreen(client: mockClient)));

    await tester.enterText(find.byKey(ValueKey('email')), 'test@example.com');
    await tester.enterText(find.byKey(ValueKey('password')), 'wrongpassword');
    await tester.tap(find.byKey(ValueKey('Login')));
    await tester.pump(); // Pump once to trigger the SnackBar
    await tester.pump(Duration(seconds: 1)); // Pump again to ensure SnackBar is visible

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Login failed: Invalid credentials'), findsOneWidget);
  });

  testWidgets('Navigate to signup screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(),
      routes: {
        '/signup': (context) => Scaffold(body: Text('Signup Screen')),
      },
    ));

    await tester.tap(find.byKey(ValueKey('signupLink')));
    await tester.pumpAndSettle();

    expect(find.text('Signup Screen'), findsOneWidget);
  });
}
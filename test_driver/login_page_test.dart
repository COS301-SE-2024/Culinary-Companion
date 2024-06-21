import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Login Page', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Login with Valid Credentials', () async {
      // Assuming valid credentials are already set up in your test environment
      final emailField = find.byValueKey('email');
      final passwordField = find.byValueKey('password');
      final loginButton = find.byValueKey('loginButton');

      await driver.tap(emailField);
      await driver.enterText('test@example.com');
      await driver.tap(passwordField);
      await driver.enterText('password123');
      await driver.tap(loginButton);

      // Add assertions based on expected behavior after login
      await driver.waitForAbsent(loginButton); // Example assertion
    });
  });
}

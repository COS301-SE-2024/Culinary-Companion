import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Culinary Companion App', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('landing page shows login and signup buttons', () async {
      // Verify if the login button is present
      expect(await driver.getText(find.text('Log In')), 'Log In');

      // Verify if the sign-up button is present
      expect(await driver.getText(find.text('Sign Up')), 'Sign Up');
    });

    test('navigates to login page', () async {
      await driver.tap(find.text('Log In'));

      // Verify if the login page is shown
      expect(await driver.getText(find.text('Welcome Back!')), 'Welcome Back!');
    });

    test('navigates to signup page', () async {
      await driver.tap(find.text('Sign Up'));

      // Verify if the sign-up page is shown
      expect(await driver.getText(find.text('Create an account')), 'Create an account');
    });

    test('performs login', () async {
      await driver.tap(find.text('Log In'));

      await driver.tap(find.byValueKey('emailField'));
      await driver.enterText('test@example.com');

      await driver.tap(find.byValueKey('passwordField'));
      await driver.enterText('password123');

      await driver.tap(find.text('Login'));

      // Verify navigation to home screen
      // Replace 'Home' with the actual text that appears on the home screen
      expect(await driver.getText(find.text('Home')), 'Home');
    });

    test('performs signup', () async {
      await driver.tap(find.text('Sign Up'));

      await driver.tap(find.byValueKey('emailField'));
      await driver.enterText('newuser@example.com');

      await driver.tap(find.byValueKey('passwordField'));
      await driver.enterText('newpassword123');

      await driver.tap(find.byValueKey('confirmPasswordField'));
      await driver.enterText('newpassword123');

      await driver.tap(find.text('Sign Up'));

      // Verify navigation to confirm details screen
      // Replace 'Confirm' with the actual text that appears on the confirm details screen
      expect(await driver.getText(find.text('Confirm')), 'Confirm');
    });
  });
}

// import 'package:flutter_driver/flutter_driver.dart';
// import 'package:test/test.dart';

// void main() {
//   group('Culinary Companion App', () {
//     late FlutterDriver driver;

//     setUpAll(() async {
//       driver = await FlutterDriver.connect();
//     });

//     tearDownAll(() async {
//       await driver.close();
//     });

//     test('Landing Page', () async {
//       await driver.waitFor(find.byValueKey('loginButton'));
//       await driver.waitFor(find.byValueKey('signupButton'));
//       print("landing pass");
//     });

//     test('Login Page', () async {
//       await driver.tap(find.byValueKey('loginButton'));
//       await driver.waitFor(find.byValueKey('email'));
//       await driver.waitFor(find.byValueKey('password'));
//       await driver.waitFor(find.text('Login'));
//       print("login pass");
//     });

//     test('Signup Page', () async {
//       //await driver.tap(find.text('Don\'t have an account? Sign up'));
//       await driver.tap(find.byValueKey('signupLink'));
//       await driver.waitFor(find.byValueKey('emailField'));
//       await driver.waitFor(find.byValueKey('passwordField'));
//       await driver.waitFor(find.byValueKey('confirmPasswordField'));
//       await driver.waitFor(find.byValueKey('signupSubmitButton'));
//       print("signup pass");
//     });

//   });
// }
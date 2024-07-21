import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Culinary Companion App', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      driver.close();
    });

    test('Verify navbar items', () async {
      // Wait for the app to load
      await driver.waitFor(find.text('Home'));

      // Verify navbar items
      expect(await driver.getText(find.text('Home')), 'Home');
      expect(await driver.getText(find.text('Add Recipe')), 'Add Recipe');
      expect(await driver.getText(find.text('Inventory')), 'Inventory');
      expect(await driver.getText(find.text('Favorite Recipes')),
          'Favorite Recipes');
      expect(await driver.getText(find.text('Profile')), 'Profile');
    });

    test('Navigate to Inventory screen and verify tabs', () async {
      // Tap on the Inventory item in the navbar
      await driver.tap(find.text('Inventory'));

      // Verify that we're on the Inventory screen
      await driver.waitFor(find.text('Shopping List'));
      await driver.waitFor(find.text('Pantry'));
      await driver.waitFor(find.text('Appliances'));
    });


    test('Navigate through Inventory tabs', () async {
      // // Verify and tap on Shopping List tab
      // expect(await driver.getText(find.text('Shopping List')), 'Shopping List');
      // await driver.tap(find.text('Shopping List'));
      // await driver.waitFor(find.byType('ShoppingListScreen'));

      // Verify and tap on Pantry tab
      expect(await driver.getText(find.text('Pantry')), 'Pantry');
      await driver.tap(find.text('Pantry'));
      await driver.waitFor(find.byValueKey('Pantry'));

      // // Verify and tap on Appliances tab
      // expect(await driver.getText(find.text('Appliances')), 'Appliances');
      // await driver.tap(find.text('Appliances'));
      // await driver.waitFor(find.byType('AppliancesScreen'));
    });
    // test('Navigate to Pantry screen', () async {
    //   // Tap on the Pantry item in the navbar
    //   await driver.tap(find.byValueKey(('Pantry')));
    //   // Verify that we're on the Pantry screen
    //   //expect(await driver.getText(find.text('Pantry')), 'Pantry');
    //   await driver.waitFor(find.byValueKey('Pantry'));
    // });
    //     test('Navigate to ShoppingList screen', () async {
    //   // Tap on the Pantry item in the navbar
    //   await driver.tap(find.byValueKey(('ShoppingList')));
    //   // Verify that we're on the Pantry screen
    //   //expect(await driver.getText(find.text('Pantry')), 'Pantry');
    //   await driver.waitFor(find.text('Shopping List'));
    // });
  });
}

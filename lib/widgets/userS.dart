import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String _userIdKey = 'userId';

  // Make the method public by removing the underscore prefix
  Future<void> saveUserIdToSharedPrefs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserIdFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
}

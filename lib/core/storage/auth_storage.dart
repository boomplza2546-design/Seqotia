import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'seqotia_auth_token';
  static const String _rememberKey = 'seqotia_auth_remember_me';
  static const String _userEmailKey = 'seqotia_auth_user_email';
  static const String _userNameKey = 'seqotia_auth_user_name';

  static String? _inMemoryToken;

  static Future<void> saveToken(
    String token, {
    required bool rememberMe,
    String? userEmail,
    String? userName,
  }) async {
    _inMemoryToken = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, rememberMe);

    if (rememberMe) {
      await prefs.setString(_tokenKey, token);
      if (userEmail != null && userEmail.isNotEmpty) {
        await prefs.setString(_userEmailKey, userEmail);
      }
      if (userName != null && userName.isNotEmpty) {
        await prefs.setString(_userNameKey, userName);
      }
    } else {
      await prefs.remove(_tokenKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
    }
  }

  static Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberKey) ?? true;

    if (!rememberMe) {
      return _inMemoryToken;
    }

    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      _inMemoryToken = token;
      return token;
    }

    return _inMemoryToken;
  }

  static Future<String?> readUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<String?> readUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> clear() async {
    _inMemoryToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.setBool(_rememberKey, false);
  }
}

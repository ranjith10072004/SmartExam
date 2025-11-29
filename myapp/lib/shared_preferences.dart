import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class SharedPrefs {
  // ========================
  // SAVE TOKEN
  // ========================
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // ========================
  // GET TOKEN
  // ========================
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ========================
  // REMOVE TOKEN
  // ========================
  static Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}

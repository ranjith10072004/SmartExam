import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Config.dart';

class ApiService {
  // ================= HELPER: GET TOKEN =================
  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? "";
  }

  // ================= HELPER: JSON CHECK =================
  static bool _isJsonResponse(String body) {
    try {
      jsonDecode(body);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final url = Uri.parse(Config.registerUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role.toLowerCase(),
        }),
      );

      print("REGISTER RAW: ${response.body}");

      if (!_isJsonResponse(response.body)) {
        return {"error": "Server returned non-JSON response"};
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse(Config.loginUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      if (!_isJsonResponse(response.body)) {
        return {"error": "Server returned non-JSON response"};
      }

      final data = jsonDecode(response.body);

      if (data["token"] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        print("TOKEN SAVED: ${data['token']}");
      }

      return data;
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  // ================= CREATE EXAM =================
  static Future<Map<String, dynamic>> createExam(
      Map<String, dynamic> examData) async {
    final token = await getToken();

    final url = Uri.parse(Config.createexamUrl);

    print("=== CREATING EXAM ===");
    print("Exam Data: $examData");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(examData),
      );

      print("EXAM CREATE STATUS: ${response.statusCode}");
      print("EXAM CREATE BODY: ${response.body}");

      if (!_isJsonResponse(response.body)) {
        return {"error": "Server returned non-JSON response"};
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  // ================= GET EXAM BY ID =================
  static Future<Map<String, dynamic>> getExamById(String examId) async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse("${Config.studentexamUrl}$examId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (!_isJsonResponse(res.body)) {
      return {"error": "Server returned non-JSON response"};
    }

    return jsonDecode(res.body);
  }

  // ================= SUBMIT EXAM =================
  static Future<Map<String, dynamic>> submitExam(
      String examId, List answers) async {
    final token = await getToken();

    final res = await http.post(
      Uri.parse("${Config.ngrokBase}/student/submit/$examId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"answers": answers}),
    );

    if (!_isJsonResponse(res.body)) {
      return {"error": "Server returned non-JSON response"};
    }

    return jsonDecode(res.body);
  }

  // ================= GET ALL EXAMS =================
  static Future<List<Map<String, dynamic>>> getAllExams() async {
    try {
      final response = await http.get(
        Uri.parse(Config.studentexamUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(body);
      } else {
        print("ERROR FETCHING EXAMS: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("ERROR FETCHING EXAMS: $e");
      return [];
    }
  }
}

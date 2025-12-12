import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  // ================= HELPERS =====================
  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? "";
  }

  static bool _isJsonResponse(String body) {
    try {
      jsonDecode(body);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Map<String, String> _defaultHeaders(String token) {
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // ================= REGISTER =====================
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final url = Uri.parse("${Config.baseUrl}/register");

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

      if (!_isJsonResponse(response.body)) {
        return {"error": "Server returned non-JSON response"};
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  // ================= LOGIN ======================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse(Config.loginUrl);

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (!_isJsonResponse(res.body)) {
        return {"error": "Invalid response"};
      }

      final data = jsonDecode(res.body);

      if (data["token"] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
      }

      return data;
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  // ================= CREATE EXAM ======================
  static Future<Map<String, dynamic>> createExam(
      Map<String, dynamic> examData) async {
    final token = await getToken();
    final url = Uri.parse(Config.createexamUrl);

    try {
      final res = await http.post(
        url,
        headers: _defaultHeaders(token),
        body: jsonEncode(examData),
      );

      if (!_isJsonResponse(res.body)) {
        return {"error": "Server returned non-JSON response"};
      }

      return jsonDecode(res.body);
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  // ================= GET EXAM BY ID ======================
  static Future<Map<String, dynamic>> getExamById(
    String examId, {
    String? proctorCode,
  }) async {
    final token = await getToken();

    final uri = Uri.parse("${Config.baseUrl}/student/exam/$examId")
        .replace(queryParameters: {
      if (proctorCode != null && proctorCode.isNotEmpty)
        "proctorCode": proctorCode
    });

    try {
      final res = await http
          .get(uri, headers: _defaultHeaders(token))
          .timeout(const Duration(seconds: 15));

      print("DEBUG: GET $uri -> ${res.statusCode}");
      print("DEBUG: Response: ${res.body}");

      if (!_isJsonResponse(res.body)) {
        return {"error": "Invalid server response"};
      }
      final decoded = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(decoded);
      } else {
        return {"error": decoded["msg"] ?? "Failed to load exam"};
      }
    } catch (e) {
      return {"error": "Exception: $e"};
    }
  }

  // ================= VERIFY PROCTOR CODE ====================
  static Future<Map<String, dynamic>> verifyProctorCode(
      String examId, String proctorCode) async {
    final token = await getToken();

    final uri = Uri.parse("${Config.baseUrl}/student/verify-proctor/$examId");

    try {
      final res = await http
          .post(uri,
              headers: _defaultHeaders(token),
              body: jsonEncode({"proctorCode": proctorCode}))
          .timeout(const Duration(seconds: 15));

      if (!_isJsonResponse(res.body)) {
        return {"success": false, "error": "Invalid server response"};
      }

      final data = jsonDecode(res.body);

      return {
        "success": res.statusCode == 200 &&
            (data["success"] == true || data["status"] == "ok"),
        "data": data,
      };
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // ================= SUBMIT FINAL EXAM ======================
  static Future<Map<String, dynamic>> submitExam(
      String examId, List<Map<String, dynamic>> answers) async {
    final token = await getToken();

    final uri = Uri.parse("${Config.baseUrl}/student/submit/$examId");

    try {
      final res = await http
          .post(uri,
              headers: _defaultHeaders(token),
              body: jsonEncode({"answers": answers}))
          .timeout(const Duration(seconds: 20));

      if (!_isJsonResponse(res.body)) {
        return {"success": false, "error": "Invalid server response"};
      }

      final decoded = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {
          "success": true,
          "message": decoded["msg"] ?? "Submitted successfully"
        };
      }

      return {"success": false, "error": decoded["msg"] ?? "Submit failed"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // ============================================================
  //                     ADMIN FUNCTIONS
  // ============================================================

  // ================= GET ADMIN EXAMS ======================
  static Future<Map<String, dynamic>> getAdminExams() async {
    final token = await getToken();
    final uri = Uri.parse("${Config.baseUrl}/admin/exams");

    try {
      final res = await http.get(uri, headers: _defaultHeaders(token));

      if (!_isJsonResponse(res.body)) {
        return {"error": "Invalid server response", "exams": []};
      }

      return jsonDecode(res.body);
    } catch (e) {
      return {"error": e.toString(), "exams": []};
    }
  }

  // ================= DELETE EXAM ======================
  static Future<Map<String, dynamic>> deleteExam(String id) async {
    final token = await getToken();

    final uri = Uri.parse("${Config.baseUrl}/admin/exam/$id");

    try {
      final res = await http.delete(uri, headers: _defaultHeaders(token));

      if (!_isJsonResponse(res.body)) {
        return {"error": "Invalid server response"};
      }

      return jsonDecode(res.body);
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  static Map<String, String> defaultHeaders(String token) {
  return {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };
}

  // ================= UPDATE EXAM ======================
  static Future<Map<String, dynamic>> updateExam(
      String examId, Map<String, dynamic> data) async {
    final token = await getToken();

    final uri = Uri.parse("${Config.baseUrl}/admin/updateexam/$examId");

    try {
      final res = await http.put(uri,
          headers: _defaultHeaders(token), body: jsonEncode(data));

      if (!_isJsonResponse(res.body)) {
        return {"error": "Invalid server response"};
      }

      return jsonDecode(res.body);
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  // ===============EXAM DETAILS (ADMIN)==============================

  static Future<Map<String, dynamic>> getExamByIdAdmin(String examId) async {
  final token = await getToken();
  final uri = Uri.parse("${Config.baseUrl}/admin/exam/$examId");

  try {
    final res = await http.get(uri, headers: _defaultHeaders(token));
    if (!_isJsonResponse(res.body)) return {};
    return jsonDecode(res.body);
  } catch (e) {
    return {};
  }
  }

  // ============== STUDENT DETAILS =======================

  static Future<Map<String, dynamic>> getStudentById(String studentId) async {
  final token = await getToken();
  final uri = Uri.parse("${Config.baseUrl}/admin/student/$studentId");

  try {
    final res = await http.get(uri, headers: _defaultHeaders(token));
    if (!_isJsonResponse(res.body)) return {};
    return jsonDecode(res.body);
  } catch (e) {
    return {};
  }
  }

  // ================= GET ALL STUDENTS ======================
static Future<Map<String, dynamic>> getAllStudents() async {
  final token = await getToken();
  final uri = Uri.parse("${Config.baseUrl}/admin/students");

  try {
    final res = await http.get(uri, headers: _defaultHeaders(token));

    if (!_isJsonResponse(res.body)) {
      return {"error": "Invalid server response", "students": []};
    }

    return jsonDecode(res.body);
  } catch (e) {
    return {"error": e.toString(), "students": []};
  }
}


  // ================= UPLOAD ANSWER FILE =================
static Future<Map<String, dynamic>> uploadAnswer({
  required String examId,
  required String questionId,
  required File file,
}) async {
  final token = await getToken();

  final uri = Uri.parse(
      "${Config.baseUrl}/student/upload-answer/$examId/$questionId");

  try {
    final request = http.MultipartRequest("POST", uri);
    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath("file", file.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("UPLOAD STATUS: ${response.statusCode}");
    print("UPLOAD BODY: ${response.body}");

    if (response.statusCode == 200) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {"success": false, "error": response.body};
    }
  } catch (e) {
    return {"success": false, "error": e.toString()};
  }
}

  // ================= ASSIGN EXAM TO STUDENT ======================
  static Future<Map<String, dynamic>> assignExamToStudent(
      String examId, List<String> studentIds) async {
    final token = await getToken();

    final uri = Uri.parse("${Config.baseUrl}/admin/exam/$examId/assign");

    try {
      final res = await http.post(uri,
          headers: _defaultHeaders(token),
          body: jsonEncode({"studentIds": studentIds}));

      if (!_isJsonResponse(res.body)) {
        return {"error": "Invalid server response"};
      }

      return jsonDecode(res.body);
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  // ================= UNASSIGN EXAM FROM STUDENT ======================
  static Future<Map<String, dynamic>> unassignExamFromStudent(
      String examId, List<String> studentIds) async {
    final token = await getToken();

    final uri =
        Uri.parse("${Config.baseUrl}/admin/exam/$examId/unassign");

    try {
      final res = await http.post(uri,
          headers: _defaultHeaders(token),
          body: jsonEncode({"studentIds": studentIds}));

      if (!_isJsonResponse(res.body)) {
        return {"error": "Invalid server response"};
      }

      return jsonDecode(res.body);
    } catch (e) {
      return {"error": e.toString()};
    }
  }
}

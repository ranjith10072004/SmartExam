import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Config.dart';
import 'dart:io';

class ApiService {
  // ================= GET TOKEN =================
  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? "";
  }

  // ================= CHECK JSON =================
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
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (!_isJsonResponse(res.body)) return {"error": "Invalid response"};

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

  // ================= CREATE EXAM =================
  static Future<Map<String, dynamic>> createExam(
      Map<String, dynamic> examData) async {
    final token = await getToken();
    final url = Uri.parse(Config.createexamUrl);

    try {
      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
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

  // ================= GET EXAM BY ID =================
  static Future<Map<String, dynamic>> getExamById(String examId) async {
    final token = await getToken();

    try {
      final res = await http.get(
        Uri.parse("${Config.studentexamUrl}$examId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (!_isJsonResponse(res.body)) {
        return {"error": "Server returned non-JSON response"};
      }

      return jsonDecode(res.body);
    } catch (e) {
      return {"error": "Failed to fetch exam: $e"};
    }
  }

  // ================= SUBMIT EXAM =================
  static Future<Map<String, dynamic>> submitExam(
      String examId, List answers) async {
    final token = await getToken();

    try {
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
    } catch (e) {
      return {"error": "Submission failed: $e"};
    }
  }

  // ================= GET ALL EXAMS (STUDENT) =================
  static Future<List<dynamic>> getAllExams() async {
  try {
    final token = await getToken();

    final res = await http.get(
      Uri.parse(Config.studentexamUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data is Map && data["exams"] is List) {
        return data["exams"];
      }

      return []; // unexpected format
    }

    print("EXAM LOAD FAILED: ${res.statusCode}: ${res.body}");
    return [];
  } catch (e) {
    print("EXAM LOAD ERROR: $e");
    return [];
  }
}

  // ---------------- Admin: get all exams (for evaluator)
  static Future<List<dynamic>> getAdminExams() async {
    try {
      final token = await getToken();
      final url = Uri.parse("${Config.ngrokBase}/admin/exams");
      final res = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });

      if (!_isJsonResponse(res.body)) {
        return [];
      }
      final data = jsonDecode(res.body);
      // assume { exams: [...] } or return the array directly
      if (data is Map && data['exams'] != null) return List.from(data['exams']);
      if (data is List) return data;
      return [];
    } catch (e) {
      print("getAdminExams error: $e");
      return [];
    }
  }

  // ---------------- Admin: update exam
  static Future<Map<String, dynamic>> updateExam(String examId, Map body) async {
  try {
    final token = await getToken();
    final url = Uri.parse("${Config.ngrokBase}/admin/updateexam/$examId");

    final res = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("UPDATE STATUS: ${res.statusCode}");
    print("UPDATE BODY RAW: '${res.body}'");

    if (!_isJsonResponse(res.body)) {
      return {"error": "Invalid response", "raw": res.body};
    }

    return jsonDecode(res.body);
  } catch (e) {
    return {"error": "Network error: $e"};
  }
}

  // ---------------- Admin: delete exam
  static Future<Map<String, dynamic>> deleteExam(String examId) async {
    try {
      final token = await getToken();
      final url = Uri.parse("${Config.ngrokBase}/admin/exams/$examId");
      final res = await http.delete(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      if (!_isJsonResponse(res.body)) return {"error": "Invalid response"};
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": "Network error: $e"};
    }
  }

  // ---------------- Admin: students list
  static Future<List<dynamic>> getAllStudents() async {
    try {
      final token = await getToken();
      final url = Uri.parse("${Config.ngrokBase}/admin/students");
      final res = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      if (!_isJsonResponse(res.body)) return [];
      final data = jsonDecode(res.body);
      if (data is Map && data['students'] != null) return List.from(data['students']);
      if (data is List) return data;
      return [];
    } catch (e) {
      print("getAllStudents error: $e");
      return [];
    }
  }

  // ---------------- Admin: assign exam to student
static Future<Map<String, dynamic>> assignExamToStudent(
    String examId, List<String> studentIds) async {
  try {
    final token = await getToken();

    final url = Uri.parse("${Config.ngrokBase}/admin/assignexam/$examId");

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"studentIds": studentIds}),
    );

    print("ASSIGN STATUS: ${res.statusCode}");
    print("ASSIGN RESPONSE: ${res.body}");

    if (res.statusCode != 200) {
      return {"error": "Failed", "raw": res.body};
    }

    return jsonDecode(res.body);
  } catch (e) {
    return {"error": e.toString()};
  }
}


  // ---------------- Admin: unassign
  static Future<Map<String, dynamic>> unassignExamFromStudent(
    String examId, List<String> studentIds) async {
  try {
    final token = await getToken();
    final url = Uri.parse("${Config.ngrokBase}/admin/unassignexam/$examId");

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"studentIds": studentIds}),
    );

    return jsonDecode(res.body);
  } catch (e) {
    return {"error": e.toString()};
  }
}

//Student writing exam

static Future<Map<String, dynamic>> getStudentExam(String examId) async {
  try {
    final token = await getToken();
    
    // 1. EARLY EXIT CHECK: Ensure token is present
    if (token == null || token.isEmpty) {
      print("❌ TOKEN MISSING. Exiting.");
      return {"success": false, "error": "Token missing. Please login again."};
    }

    final url = Uri.parse("${Config.ngrokBase}/student/exam/$examId");
    print("🌍 ATTEMPTING TO FETCH URL: $url"); // Log the exact URL being called

    final res = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        // Content-Type is optional for GET requests, but harmless.
        "Content-Type": "application/json", 
      },
    );

    // --- LOG RESPONSE DETAILS ---
    print("✅ EXAM FETCH STATUS: ${res.statusCode}");
    print("📝 EXAM FETCH RAW: ${res.body}");

    // 2. NON-JSON CHECK: If the body is clearly not JSON (e.g., HTML error page)
    if (!_isJsonResponse(res.body)) {
      print("❌ Non-JSON Response Detected. Likely a 404/500 HTML page.");
      return {
        "success": false,
        "error": "Unexpected server response (Code ${res.statusCode}). Check Ngrok/Backend routing.",
        "raw": res.body,
      };
    }

    final decoded = jsonDecode(res.body);

    // 3. SUCCESS CASE (Status 200-299)
    if (res.statusCode >= 200 && res.statusCode < 300) {
      // Check for the expected data structure within the successful response
      if (decoded["exam"] != null) {
        return {
          "success": true,
          "exam": decoded["exam"],
        };
      } else {
        // Successful status code, but data is missing/malformed.
        print("⚠️ 200 OK, but 'exam' field is missing in JSON.");
        return {
          "success": false,
          "error": "Server returned success but missing required 'exam' data.",
        };
      }
    }

    // 4. CLIENT/SERVER ERROR CASE (Status 4xx, 5xx)
    // Assumes the 4xx/5xx errors return a JSON object with a 'msg' or 'error' field.
    return {
      "success": false,
      "error": decoded["msg"] ?? decoded["error"] ?? "Error ${res.statusCode}: Failed to load exam",
      "raw": res.body, // Include raw body for inspection
    };

  } on SocketException catch (e) {
    // This catches network errors (e.g., No Internet, Ngrok URL unreachable)
    print("🚨 NETWORK ERROR: SocketException: $e");
    return {"success": false, "error": "Connection failed. Check your network or Ngrok tunnel status."};
  } catch (e) {
    // This catches all other unhandled errors (e.g., FormatException from jsonDecode, etc.)
    print("💣 UNHANDLED CATCH ERROR: $e"); 
    return {"success": false, "error": "An unexpected error occurred: ${e.toString()}"};
  }
}
}

 
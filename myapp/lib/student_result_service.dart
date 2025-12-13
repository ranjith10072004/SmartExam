import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Config.dart';

class StudentResultService {
  static Future<Map<String, dynamic>> getAllResults(String token) async {
    final url = Uri.parse("${Config.baseUrl}/results");

    final res = await http.get(url, headers: {
      "Authorization": "Bearer $token",
    });

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getSingleResult(
      String examId, String token) async {
    final url = Uri.parse("${Config.baseUrl}/result/$examId");

    final res = await http.get(url, headers: {
      "Authorization": "Bearer $token",
    });

    return jsonDecode(res.body);
  }
}

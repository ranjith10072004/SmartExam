import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'Config.dart';

class EvaluationService {
  /// GET /admin/pendingresults
  static Future<Map<String, dynamic>> getPendingResults() async {
    try {
      final token = await ApiService.getToken();
      final uri = Uri.parse("${Config.baseUrl}/admin/pendingresults");

      final res = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
      });

      final decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        if (decoded["results"] is List) {
          return {
            "success": decoded["success"] ?? true,
            "results": decoded["results"],
          };
        }
        if (decoded["pending"] is List) {
          return {
            "success": decoded["success"] ?? true,
            "results": decoded["pending"],
          };
        }
        // Fallback: whole map but without list key
        return {
          "success": decoded["success"] ?? false,
          "results": [],
          "raw": decoded,
        };
      } else if (decoded is List) {
        return {"success": true, "results": decoded};
      }

      return {
        "success": false,
        "results": [],
        "error": "Unexpected response format",
      };
    } catch (e) {
      return {"success": false, "results": [], "error": e.toString()};
    }
  }

  /// GET /admin/evaluate/:resultId   (or your equivalent endpoint)
  static Future<Map<String, dynamic>> getResult(String resultId) async {
    try {
      final token = await ApiService.getToken();
      final uri =
          Uri.parse("${Config.baseUrl}/admin/evaluate/$resultId");

      final res = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
      });

      final decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (e) {
      return {};
    }
  }

  /// POST /admin/evaluate/:resultId
  static Future<Map<String, dynamic>> submitEvaluation(
      String resultId, List<int> scores) async {
    try {
      final token = await ApiService.getToken();
      final uri =
          Uri.parse("${Config.baseUrl}/admin/evaluate/$resultId");

      final res = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"scores": scores}),
      );

      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {"success": false, "msg": "Unexpected response"};
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }
}

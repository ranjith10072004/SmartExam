import 'package:flutter/material.dart';
import 'evaluation_screen.dart';
import 'evaluation_service.dart';

class PendingResultsPage extends StatefulWidget {
  const PendingResultsPage({Key? key}) : super(key: key);

  @override
  State<PendingResultsPage> createState() => _PendingResultsPageState();
}

class _PendingResultsPageState extends State<PendingResultsPage> {
  bool loading = true;
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    setState(() => loading = true);

    try {
      // 🔹 Make this dynamic so we can safely check its shape
      final dynamic res = await EvaluationService.getPendingResults();
      final List<Map<String, dynamic>> extracted = [];

      // CASE 1: backend returns { results: [ ... ] }
      if (res is Map && res["results"] is List) {
        for (final item in res["results"]) {
          if (item is Map<String, dynamic>) {
            extracted.add(item);
          } else if (item is Map) {
            extracted.add(Map<String, dynamic>.from(item));
          }
        }
      }
      // CASE 2: backend returns { pending: [ ... ] }
      else if (res is Map && res["pending"] is List) {
        for (final item in res["pending"]) {
          if (item is Map<String, dynamic>) {
            extracted.add(item);
          } else if (item is Map) {
            extracted.add(Map<String, dynamic>.from(item));
          }
        }
      }
      // CASE 3: backend directly returns a List
      else if (res is List) {
        for (final item in res) {
          if (item is Map<String, dynamic>) {
            extracted.add(item);
          } else if (item is Map) {
            extracted.add(Map<String, dynamic>.from(item));
          }
        }
      }
      // CASE 4: single object (very rare)
      else if (res is Map) {
        extracted.add(Map<String, dynamic>.from(res));
      }

      setState(() {
        loading = false;
        results = extracted;
      });

      // Optional debug
      // print("PENDING RESULTS PARSED: $results");
    } catch (e) {
      setState(() {
        loading = false;
        results = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load pending results: $e")),
        );
      }
    }
  }

  /// Helper to safely extract Mongo ObjectId / plain string / anything.
  String _extractId(dynamic value) {
    if (value is Map && value.containsKey("\$oid")) {
      return value["\$oid"].toString();
    }
    return value?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Pending Results")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? const Center(child: Text("No pending results"))
              : RefreshIndicator(
                  onRefresh: loadResults,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final item = results[i];

                      // Try to get a friendly exam title / student name if backend sends them
                      final examTitle = item["examTitle"] ??
                          "Exam: ${_extractId(item["examId"])}";
                      final studentName = item["studentName"] ??
                          _extractId(item["studentId"]);

                      final resultId = _extractId(item["_id"]);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(examTitle),
                          subtitle: Text("Student: $studentName"),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            if (resultId.isEmpty) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EvaluateScreen(resultId: resultId),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

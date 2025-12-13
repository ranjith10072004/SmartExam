import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Config.dart';

class StudentResultsPage extends StatefulWidget {
  final String token;

  const StudentResultsPage({required this.token});

  @override
  State<StudentResultsPage> createState() => _StudentResultsPageState();
}

class _StudentResultsPageState extends State<StudentResultsPage> {
  bool loading = true;
  List<dynamic> results = [];

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    try {
      final url = Uri.parse("${Config.baseUrl}/student/results");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          results = data["results"];
          loading = false;
        });
      } else {
        loading = false;
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (results.isEmpty) {
      return const Center(child: Text("No Results Found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final r = results[i];
        final exam = r["examId"] ?? {};

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(exam["title"] ?? "Unknown Exam",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              "Score: ${r["score"]}/${r["totalMarks"]}\n"
              "Status: ${r["status"]}",
            ),
          ),
        );
      },
    );
  }
}
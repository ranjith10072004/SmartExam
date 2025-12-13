import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'Config.dart';
import 'ProctorCode.dart';
import 'student_results_page.dart';

class StudentDashboard extends StatefulWidget {
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  List<dynamic> exams = [];
  bool loadingExams = true;

  late TabController _tabController;

  String? token;               // <-- FIX 1: store token
  bool tokenLoaded = false;    // <-- FIX 2

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    loadToken();
    loadExams();
  }

  Future<void> loadToken() async {
    token = await ApiService.getToken();
    setState(() => tokenLoaded = true); // <-- allow Results tab to load
  }

  Future<void> loadExams() async {
    final t = await ApiService.getToken();
    final url = Uri.parse("${Config.baseUrl}/student/exams");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $t",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          exams = data["exams"];
          loadingExams = false;
        });
      } else {
        loadingExams = false;
      }
    } catch (e) {
      loadingExams = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.blueAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Exams"),
            Tab(text: "My Results"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // ----------- TAB 1: Exams --------------------
          loadingExams
              ? const Center(child: CircularProgressIndicator())
              : buildExamList(),

          // ----------- TAB 2: Results -------------------
          tokenLoaded
              ? StudentResultsPage(token: token!)
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget buildExamList() {
    if (exams.isEmpty) {
      return const Center(child: Text("No exams available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam["title"],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(exam["description"] ?? ""),
                const SizedBox(height: 10),
                Text("Start: ${exam['examStartTime']}"),
                Text("End: ${exam['examEndTime']}"),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProctorCodeScreen(examId: exam["_id"]),
                      ),
                    );
                  },
                  child: const Text("Start Exam"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

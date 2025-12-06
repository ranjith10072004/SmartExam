import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart';
import 'student_exam_view.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool loading = true;
  List<dynamic> exams = [];

  @override
  void initState() {
    super.initState();
    loadExams();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> loadExams() async {
    setState(() => loading = true);

    final data = await ApiService.getAllExams();

    setState(() {
      exams = data;
      loading = false;
    });
  }

  String getExamStatus(DateTime start, DateTime end) {
    final now = DateTime.now();

    if (now.isBefore(start)) return "Upcoming";
    if (now.isAfter(end)) return "Completed";
    return "Live Now";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new notifications')));
              }),
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : exams.isEmpty
              ? const Center(child: Text("No exams available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];

                    final start = DateTime.parse(exam["examStartTime"]);
                    final end = DateTime.parse(exam["examEndTime"]);

                    final status = getExamStatus(start, end);

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
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

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Duration: ${exam["duration"]} mins"),
                                Chip(
                                  label: Text(
                                    status,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: status == "Upcoming"
                                      ? Colors.blue
                                      : status == "Live Now"
                                          ? Colors.green
                                          : Colors.grey,
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Start: ${start.toLocal().toString().substring(0, 16)}"),
                                Text("End: ${end.toLocal().toString().substring(0, 16)}"),
                              ],
                            ),

                            const SizedBox(height: 16),

                            if (status == "Live Now")
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StudentExamView(
                                          examId: exam["_id"].toString()),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: const Text("Start Exam"),
                              ),

                            if (status == "Upcoming")
                              const Text(
                                "Exam has not started yet",
                                style: TextStyle(color: Colors.blue),
                              ),

                            if (status == "Completed")
                              const Text(
                                "Exam is closed",
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// Navigate back to login screen 
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("You have been logged out."),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock),
              label: const Text("Log Back In"),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MyApp()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
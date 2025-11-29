import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// THEME
// ---------------------------------------------------------------------------
class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
}

// ---------------------------------------------------------------------------
// EXAM MODEL (Dummy Data)
// ---------------------------------------------------------------------------
class Exam {
  final String id;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final int duration;

  Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });
}

// ---------------------------------------------------------------------------
// DASHBOARD DEMO UI
// ---------------------------------------------------------------------------
class SmartExamDashboard extends StatefulWidget {
  const SmartExamDashboard({Key? key}) : super(key: key);

  @override
  _SmartExamDashboardState createState() => _SmartExamDashboardState();
}

class _SmartExamDashboardState extends State<SmartExamDashboard> {
  List<Exam> availableExams = [
    Exam(
      id: "1",
      title: "Mathematics Mid-Term",
      description: "Algebra + Geometry + Trigonometry",
      startTime: "2025-01-10 10:00 AM",
      endTime: "2025-01-10 11:00 AM",
      duration: 60,
    ),
    Exam(
      id: "2",
      title: "Physics Unit Test",
      description: "Laws of Motion + Gravitation",
      startTime: "2025-01-11 09:00 AM",
      endTime: "2025-01-11 09:45 AM",
      duration: 45,
    ),
    Exam(
      id: "3",
      title: "English Grammar Test",
      description: "Tenses + Active/Passive + Essays",
      startTime: "2025-01-12 02:00 PM",
      endTime: "2025-01-12 03:00 PM",
      duration: 60,
    ),
  ];

  // ---------------- NAVIGATION ----------------
  void joinExam(String examId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Opening Exam ID: $examId")),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("SmartExam Dashboard",
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),

      // ---------------- BODY ----------------
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: availableExams.length,
        itemBuilder: (context, index) {
          final exam = availableExams[index];

          return Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    exam.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 15),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Start: ${exam.startTime}",
                              style: const TextStyle(fontSize: 13)),
                          Text("End: ${exam.endTime}",
                              style: const TextStyle(fontSize: 13)),
                          Text("Duration: ${exam.duration} mins",
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => joinExam(exam.id),
                        child: const Text("Start",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
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

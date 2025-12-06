import 'package:flutter/material.dart';
import 'api_service.dart';
import 'student_exam_submit.dart';

class StudentExamView extends StatefulWidget {
  final String examId;

  const StudentExamView({required this.examId, Key? key}) : super(key: key);

  @override
  State<StudentExamView> createState() => _StudentExamViewState();
}

class _StudentExamViewState extends State<StudentExamView> {
  Map<String, dynamic> exam = {};
  bool loading = true;
  String errorMessage = "Exam Failed to Load";

  @override
  void initState() {
    super.initState();
    loadExam();
  }

  // ------------------ FETCH EXAM BY ID ------------------
  Future<void> loadExam() async {
    final data = await ApiService.getExamById(widget.examId);

    if (data == null || data["error"] != null) {
      setState(() {
        errorMessage = data?["error"] ?? "Failed to load exam";
        loading = false;
      });
      return;
    }

    setState(() {
      exam = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(errorMessage, style: const TextStyle(fontSize: 18)),
        ),
      );
    }

    // SAFE JSON READ
    final title = exam["title"] ?? "Untitled Exam";
    final description = exam["description"] ?? "";
    final duration = exam["duration"] ?? 0;

    // FIX: Parse normal ISO strings: "2025-01-01T10:00:00.000Z"
    late DateTime start;
    late DateTime end;

    try {
      start = DateTime.parse(exam["examStartTime"]);
      end = DateTime.parse(exam["examEndTime"]);
    } catch (e) {
      start = DateTime.now();
      end = DateTime.now();
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            Text("🕒 Duration: $duration minutes",
                style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 8),
            Text("📅 Start: $start", style: const TextStyle(fontSize: 16)),
            Text("📅 End:   $end", style: const TextStyle(fontSize: 16)),

            const Spacer(),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text(
                  "Start Exam",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentExamSubmit(
                        examId: widget.examId,
                        questions: exam["questions"] ?? [],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

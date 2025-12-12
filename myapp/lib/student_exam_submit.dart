import 'package:flutter/material.dart';
import 'api_service.dart';

class StudentExamSubmit extends StatefulWidget {
  final String examId;

  // ✅ Use correct type: List<Map<String, dynamic>>
  final List<Map<String, dynamic>> uploadedAnswers;

  const StudentExamSubmit({
    required this.examId,
    required this.uploadedAnswers,
    Key? key,
  }) : super(key: key);

  @override
  State<StudentExamSubmit> createState() => _StudentExamSubmitState();
}

class _StudentExamSubmitState extends State<StudentExamSubmit> {
  bool loading = false;
  String message = "";

  Future<void> submitExam() async {
    setState(() {
      loading = true;
      message = "";
    });

    // ✅ Matches API signature: List<Map<String, dynamic>>
    final res = await ApiService.submitExam(
      widget.examId,
      widget.uploadedAnswers,
    );

    setState(() {
      loading = false;
      message = res["message"] ?? res["error"] ?? "Unknown response";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Exam")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Files ready to upload:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.uploadedAnswers.length,
                itemBuilder: (_, i) {
                  return ListTile(
                    title: Text(widget.uploadedAnswers[i]["filePath"]),
                    subtitle: Text("QID: ${widget.uploadedAnswers[i]["questionId"]}"),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submitExam,
                    child: const Text("Submit"),
                  ),
            const SizedBox(height: 20),
            Text(message, style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class StudentExamView extends StatefulWidget {
  final String examId;
  final String proctorCode;

  const StudentExamView({
    Key? key,
    required this.examId,
    required this.proctorCode,
  }) : super(key: key);

  @override
  State<StudentExamView> createState() => _StudentExamViewState();
}

class _StudentExamViewState extends State<StudentExamView> {
  Map<String, dynamic>? exam;
  bool loading = true;

  // Store answers
  Map<String, String> writtenAnswers = {};       // questionId => text answer
  Map<String, String> uploadedFiles = {};        // questionId => fileUrl

  @override
  void initState() {
    super.initState();
    loadExam();
  }

  Future<void> loadExam() async {
    setState(() => loading = true);

    final res = await ApiService.getExamById(
      widget.examId,
      proctorCode: widget.proctorCode,
    );

    print("EXAM LOADED → $res");

    if (mounted) {
      setState(() {
        exam = res["exam"] ?? res;
        loading = false;
      });
    }
  }

  Future<void> uploadFile(String questionId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    File file = File(picked.path);

    final res = await ApiService.uploadAnswer(
      examId: widget.examId,
      questionId: questionId,
      file: file,
    );

    if (res["success"] == true) {
      final url = res["data"]["fileUrl"] ?? res["data"]["url"];

      setState(() {
        uploadedFiles[questionId] = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File uploaded successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: ${res['error']}")),
      );
    }
  }

  Future<void> submitExam() async {
    List<Map<String, dynamic>> finalAnswers = [];

    for (var q in exam!["questions"]) {
      final questionId = q["_id"] is Map ? q["_id"]["\$oid"] : q["_id"];

      finalAnswers.add({
        "questionId": questionId,
        "writtenAnswer": writtenAnswers[questionId] ?? "",
        "fileUrl": uploadedFiles[questionId] ?? "",
      });
    }

    final res = await ApiService.submitExam(widget.examId, finalAnswers);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exam Submitted Successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submit failed: ${res['error']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (exam == null || exam!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No exam found")),
      );
    }

    final questions = exam!["questions"] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(exam!["title"] ?? "Exam"),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];

                final questionId = q["_id"] is Map
                    ? q["_id"]["\$oid"]
                    : q["_id"].toString();

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// QUESTION TEXT
                        Text(
                          "Q${index + 1}: ${q['questionText'] ?? q['text']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// ✍ WRITTEN ANSWER TEXT FIELD
                        TextField(
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: "Write your answer here...",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            writtenAnswers[questionId] = value;
                          },
                        ),

                        const SizedBox(height: 12),

                        /// 📁 FILE UPLOAD BUTTON
                        ElevatedButton.icon(
                          onPressed: () => uploadFile(questionId),
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Upload File"),
                        ),

                        if (uploadedFiles.containsKey(questionId))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "File uploaded ✔",
                              style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// SUBMIT BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitExam,
                child: const Text(
                  "Submit Exam",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'api_service.dart';

class StudentExamSubmit extends StatefulWidget {
  final String examId;
  final List questions;

  const StudentExamSubmit({
    super.key,
    required this.examId,
    required this.questions,
  });

  @override
  State<StudentExamSubmit> createState() => _StudentExamSubmitState();
}

class _StudentExamSubmitState extends State<StudentExamSubmit> {
  late List<dynamic> answers;

  @override
  void initState() {
    super.initState();

    // Fill answers array with null values for each question
    answers = List.filled(widget.questions.length, null);
  }

  // ------------------ SUBMIT ANSWERS ------------------
  Future<void> submit() async {
    // VALIDATION
    bool hasEmpty =
        answers.any((val) => val == null || val.toString().trim().isEmpty);

    if (hasEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please answer all questions before submitting."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // API CALL
    final res = await ApiService.submitExam(widget.examId, answers);

    if (res["error"] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Exam Submitted Successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission failed: ${res["error"]}")),
      );
    }
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(
          "Answer Questions",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.questions.length,
        itemBuilder: (context, index) {
          final q = widget.questions[index];
          final qType = q["type"] ?? "mcq";
          final options = q["options"] ?? [];

          return Card(
            elevation: 3,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QUESTION TEXT
                  Text(
                    "${index + 1}. ${q["questionText"] ?? "No Question"}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ------------ MCQ / TRUE-FALSE ------------
                  if (qType == "mcq" || qType == "truefalse")
                    ...options.asMap().entries.map((entry) {
                      int optionIndex = entry.key;
                      String optionValue = entry.value.toString();

                      return RadioListTile(
                        title: Text(optionValue),
                        activeColor: Colors.blue,
                        value: optionValue,
                        groupValue: answers[index],
                        onChanged: (val) {
                          setState(() => answers[index] = val);
                        },
                      );
                    }),

                  // ------------ SHORT ANSWER ------------
                  if (qType == "short")
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Your Answer",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (val) => answers[index] = val,
                    ),

                  // ------------ LONG ANSWER ------------
                  if (qType == "long")
                    TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Your Answer",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (val) => answers[index] = val,
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),

      // SUBMIT BUTTON
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            "Submit Exam",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

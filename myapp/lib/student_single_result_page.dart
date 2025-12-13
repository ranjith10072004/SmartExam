import 'package:flutter/material.dart';
import 'student_result_service.dart';

class StudentSingleResultPage extends StatefulWidget {
  final String examId;
  final String token;

  const StudentSingleResultPage({
    required this.examId,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  State<StudentSingleResultPage> createState() =>
      _StudentSingleResultPageState();
}

class _StudentSingleResultPageState extends State<StudentSingleResultPage> {
  Map result = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSingleResult();
  }

  Future<void> fetchSingleResult() async {
    final res = await StudentResultService.getSingleResult(
        widget.examId, widget.token);

    if (res["success"] == true) {
      setState(() {
        result = res["result"];
        loading = false;
      });
    } else {
      setState(() => loading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res["msg"].toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final exam = result["examId"] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(exam["title"] ?? "Result"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Exam: ${exam["title"] ?? ""}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Text("Score: ${result["score"]}"),
                  Text("Total Marks: ${result["totalMarks"]}"),
                  Text("Status: ${result["status"]}"),
                  const SizedBox(height: 20),

                  const Text(
                    "Submitted Answers:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: ListView.builder(
                      itemCount: (result["answers"] ?? []).length,
                      itemBuilder: (_, i) {
                        final ans = result["answers"][i];

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Question ${i + 1}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),

                                Text("Written Answer: ${ans["writtenAnswer"]}"),
                                const SizedBox(height: 8),

                                if (ans["fileUploads"] != null &&
                                    ans["fileUploads"].isNotEmpty)
                                  Text("Uploaded Files: " +
                                      ans["fileUploads"].join(", ")),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

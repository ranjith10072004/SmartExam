import 'package:flutter/material.dart';
import 'evaluation_service.dart';
import 'Config.dart';

class EvaluateScreen extends StatefulWidget {
  final String resultId;

  const EvaluateScreen({Key? key, required this.resultId}) : super(key: key);

  @override
  State<EvaluateScreen> createState() => _EvaluateScreenState();
}

class _EvaluateScreenState extends State<EvaluateScreen> {
  Map<String, dynamic>? result;
  List<int> scores = [];
  bool loading = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    setState(() => loading = true);

    final data = await EvaluationService.getResult(widget.resultId);
    debugPrint("EVALUATION RESULT → $data");

    if (!mounted) return;

    Map<String, dynamic>? normalized;
    if (data is Map<String, dynamic>) {
      // if service returned {success, result: {...}}
      if (data["result"] is Map<String, dynamic>) {
        normalized = Map<String, dynamic>.from(data["result"]);
      } else {
        normalized = Map<String, dynamic>.from(data);
      }
    }

    final answers = (normalized?["answers"] as List?) ?? [];

    setState(() {
      result = normalized;
      scores = List<int>.filled(answers.length, 0);
      loading = false;
    });
  }

  Future<void> _submitMarks() async {
    setState(() => submitting = true);
    final response =
        await EvaluationService.submitEvaluation(widget.resultId, scores);
    setState(() => submitting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response["msg"] ?? "Error")),
    );

    if (response["success"] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (result == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Failed to load result")),
      );
    }

    final answers = (result!["answers"] as List?) ?? [];

    // Build a nice exam title if possible
    String examTitle = "Evaluate";
    final examField = result!["exam"] ?? result!["examId"];
    if (result!["examTitle"] != null) {
      examTitle = result!["examTitle"].toString();
    } else if (examField is Map && examField["title"] != null) {
      examTitle = examField["title"].toString();
    }

    return Scaffold(
      appBar: AppBar(title: Text(examTitle)),
      body: answers.isEmpty
          ? const Center(child: Text("No answers to evaluate"))
          : ListView.builder(
              itemCount: answers.length,
              itemBuilder: (_, i) {
                final ans = answers[i] as Map<dynamic, dynamic>;

                final written = ans["writtenAnswer"]?.toString() ?? "";
                final uploads = ans["fileUploads"] as List? ?? [];
                final uploadText =
                    uploads.isNotEmpty ? uploads.join(", ") : "None";

                return Card(
                  margin: EdgeInsets.all(12),
                  child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Question ${i + 1}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                  // Written answer
                  Text("Written Answer: ${ans["writtenAnswer"] ?? ""}"),
                  SizedBox(height: 12),

                  // --- IMAGE PREVIEW SECTION ---
                  if (ans["fileUploads"] != null && ans["fileUploads"].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text("Uploaded Files:", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),

                  for (var path in ans["fileUploads"])
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        "${Config.baseUrl}$path",
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Text("Image not available"),
                    ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

        SizedBox(height: 12),

        // MARKS ENTRY
        TextField(
          decoration: InputDecoration(
            labelText: "Enter marks for Q${i + 1}",
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            scores[i] = int.tryParse(value) ?? 0;
          },
        ),
      ],
    ),
  ),
);

              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: submitting ? null : _submitMarks,
            child: submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("Submit Evaluation"),
          ),
        ),
      ),
    );
  }
}

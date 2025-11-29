import 'package:flutter/material.dart';
import 'api_service.dart';
import 'shared_preferences.dart';

class AdminCreateExam extends StatefulWidget {
  @override
  State<AdminCreateExam> createState() => _AdminCreateExamState();
}

class _AdminCreateExamState extends State<AdminCreateExam> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();

  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  List<Map<String, dynamic>> questions = [];

  // ------------------- QUESTION HANDLING -------------------
  void addQuestion() {
    setState(() {
      questions.add({
        "questionText": "",
        "type": "mcq",
        "options": [],
        "correctAnswer": "",
      });
    });
  }

  void removeQuestion(int index) {
    setState(() => questions.removeAt(index));
  }

  // ------------------- DATE & TIME PICKERS -------------------
  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => startTime = picked);
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) setState(() => endDate = picked);
  }

  Future<void> pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => endTime = picked);
  }

  // ------------------- CONVERT TO BACKEND DATE -------------------
  String toBackendDate(DateTime dt) => dt.toUtc().toIso8601String();

  // ------------------- SUBMIT EXAM -------------------
  Future<void> submitExam() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        durationController.text.isEmpty ||
        startDate == null ||
        startTime == null ||
        endDate == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final examStart = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    final examEnd = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    final mappedQuestions = questions.map((q) {
      return {
        "questionText": q["questionText"] ?? "",
        "type": q["type"] ?? "mcq",
        "options": List<String>.from(q["options"] ?? []),
        "correctAnswer": q["correctAnswer"] ?? "",
      };
    }).toList();

    final examData = {
      "title": titleController.text,
      "description": descriptionController.text,
      "duration": int.tryParse(durationController.text) ?? 60,
      "examStartTime": toBackendDate(examStart),
      "examEndTime": toBackendDate(examEnd),
      "questions": mappedQuestions,
    };

    print("Submitting exam data: $examData"); // debug log

    final res = await ApiService.createExam(examData);

    if (res["msg"] == "Exam Created Successfully") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Exam Created Successfully")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["error"] ?? "Failed to create exam")),
      );
    }
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Exam")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: submitExam,
        child: const Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Exam Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Duration (minutes)"),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text("Exam Start Date & Time",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: pickStartDate,
                    child: Text(startDate == null
                        ? "Pick Start Date"
                        : "${startDate!.day}/${startDate!.month}/${startDate!.year}"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: pickStartTime,
                    child: Text(startTime == null
                        ? "Pick Start Time"
                        : "${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Exam End Date & Time",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: pickEndDate,
                    child: Text(endDate == null
                        ? "Pick End Date"
                        : "${endDate!.day}/${endDate!.month}/${endDate!.year}"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: pickEndTime,
                    child: Text(endTime == null
                        ? "Pick End Time"
                        : "${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Questions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: addQuestion, child: const Text("Add Question"))
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (_, index) => QuestionCard(
                index: index,
                question: questions[index],
                onUpdate: (updated) => setState(() => questions[index] = updated),
                onRemove: () => removeQuestion(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- QUESTION CARD -------------------
class QuestionCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> question;
  final Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onRemove;

  const QuestionCard({
    required this.index,
    required this.question,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late TextEditingController questionTextController;
  late List<String> options;
  late List<TextEditingController> optionControllers;
  late String correctAnswer;

  @override
  void initState() {
    super.initState();
    questionTextController =
        TextEditingController(text: widget.question["questionText"]);
    options = List<String>.from(widget.question["options"] ?? []);
    optionControllers =
        List.generate(options.length, (i) => TextEditingController(text: options[i]));
    correctAnswer = widget.question["correctAnswer"]?.toString() ?? "";
  }

  void update() {
    widget.onUpdate({
      "questionText": questionTextController.text,
      "type": widget.question["type"],
      "options": options,
      "correctAnswer": correctAnswer,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Question ${widget.index + 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onRemove)
              ],
            ),
            TextField(
              controller: questionTextController,
              decoration: const InputDecoration(labelText: "Question Text"),
              onChanged: (_) => update(),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: widget.question["type"],
              decoration: const InputDecoration(labelText: "Question Type"),
              items: const [
                DropdownMenuItem(value: "mcq", child: Text("MCQ")),
                DropdownMenuItem(value: "multiple", child: Text("Multiple Select")),
                DropdownMenuItem(value: "truefalse", child: Text("True/False")),
                DropdownMenuItem(value: "short", child: Text("Short Answer")),
                DropdownMenuItem(value: "long", child: Text("Long Answer")),
              ],
              onChanged: (val) {
                setState(() => widget.question["type"] = val);
                update();
              },
            ),
            const SizedBox(height: 10),
            if (["mcq", "multiple", "truefalse"].contains(widget.question["type"]))
              _buildOptionEditor(),
            if (["short", "long"].contains(widget.question["type"])) _buildAnswerField(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionEditor() {
    return Column(
      children: [
        ...options.asMap().entries.map((entry) {
          int idx = entry.key;
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: optionControllers[idx],
                  decoration: InputDecoration(labelText: "Option ${idx + 1}"),
                  onChanged: (val) {
                    options[idx] = val;
                    update();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    options.removeAt(idx);
                    optionControllers.removeAt(idx);
                  });
                  update();
                },
              ),
            ],
          );
        }),
        ElevatedButton(
          onPressed: () {
            setState(() {
              options.add("");
              optionControllers.add(TextEditingController());
            });
            update();
          },
          child: const Text("Add Option"),
        ),
        TextField(
          decoration: const InputDecoration(labelText: "Correct Answer"),
          onChanged: (val) {
            correctAnswer = val;
            update();
          },
        ),
      ],
    );
  }

  Widget _buildAnswerField() {
    return TextField(
      decoration: const InputDecoration(labelText: "Correct Answer"),
      onChanged: (val) {
        correctAnswer = val;
        update();
      },
    );
  }
}

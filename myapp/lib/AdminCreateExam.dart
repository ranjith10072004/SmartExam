import 'package:flutter/material.dart';
import 'api_service.dart';
import 'Evaluator_Dashboard.dart';
 
class CreateExamScreen extends StatefulWidget {
  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}
 
class _CreateExamScreenState extends State<CreateExamScreen> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final startC = TextEditingController();
  final endC = TextEditingController();
  final proctorC = TextEditingController();
  final durationC = TextEditingController();

 
  List<Map> questions = [];
 
  DateTime? startDateTime;
  DateTime? endDateTime;
  int durationMinutes = 0;
 
  // Pick date and time together
  Future<DateTime?> pickDateTime(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
 
    if (date == null) return null;
 
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
 
    if (time == null) return null;
 
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
 
  void addQuestion() {
    questions.add({"questionText": "", "type": "subjective"});
    setState(() {});
  }
 
  saveExam() async {
    final data = {
      "title": titleC.text,
      "description": descC.text,
      "examStartTime": startDateTime?.toIso8601String(),
      "examEndTime": endDateTime?.toIso8601String(),
      "proctorCode": proctorC.text,
      "questions": questions,
    };
 
    final res = await ApiService.createExam(data);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(res["msg"] ?? "Created")));
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Create Exam")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: titleC, decoration: InputDecoration(labelText: "Title")),
          TextField(controller: descC, decoration: InputDecoration(labelText: "Description")),
 
          // ---------------------------
          // Start Time Picker
          // ---------------------------
          TextField(
            controller: startC,
            readOnly: true,
            decoration: InputDecoration(labelText: "Start Time"),
            onTap: () async {
            DateTime? picked = await pickDateTime(context);

            if (picked != null) {
              setState(() {
              startDateTime = picked;
              startC.text = "${picked.toLocal()}".split('.')[0];  
            });
          }
        },
      ),

          // ---------------------------
          // End Time Picker
          // ---------------------------
          TextField(
            controller: endC,
            readOnly: true,
            decoration: InputDecoration(labelText: "End Time"),
          onTap: () async {
          DateTime? picked = await pickDateTime(context);

          if (picked != null) {
          setState(() {
          endDateTime = picked;
          endC.text = "${picked.toLocal()}".split('.')[0];
        });
      }
    },
  ),

 
        // ---------------------------
        // Duration (in minutes)
        // ---------------------------
        TextField(
        controller: durationC,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Duration (minutes)",
        ),
        onChanged: (value) {
        if (value.isNotEmpty) {
        durationMinutes = int.tryParse(value) ?? 0;
      }
      },
    ),
          TextField(controller: proctorC, decoration: InputDecoration(labelText: "Proctor Code")),
          ElevatedButton(onPressed: addQuestion, child: Text("Add Question")),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (_, i) => ListTile(
                title: TextField(
                  onChanged: (v) => questions[i]["questionText"] = v,
                  decoration: InputDecoration(labelText: "Question ${i + 1}"),
                ),
              ),
            ),
          ),
          ElevatedButton(onPressed: saveExam, child: Text("Save"))
        ]),
      ),
    );
  }
}
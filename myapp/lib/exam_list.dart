import 'package:flutter/material.dart';
import 'api_service.dart';
import 'student_exam_view.dart';
 
class StudentExamList extends StatefulWidget {
  @override
  State<StudentExamList> createState() => _StudentExamListState();
}
 
class _StudentExamListState extends State<StudentExamList> {
  List exams = [];
 
  @override
  void initState() {
    super.initState();
    loadExams();
  }
 
  Future<void> loadExams() async {
    final data = await ApiService.getAllExamsForStudent();
 
    if (data["error"] == null) {
      setState(() => exams = data["exams"]);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Exams")),
      body: ListView.builder(
        itemCount: exams.length,
        itemBuilder: (_, index) {
          final exam = exams[index];
 
          return ListTile(
            title: Text(exam["title"]),
            subtitle: Text(exam["description"] ?? ""),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentExamView(examId: exam["_id"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
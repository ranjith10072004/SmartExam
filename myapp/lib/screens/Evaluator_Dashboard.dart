import 'package:flutter/material.dart';
import 'main.dart';

void main() {
  runApp(EvaluatorDashboard());
}

class EvaluatorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evaluator Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<String> exams = [];
  Map<String, List<String>> examAssignments = {};
  List<String> students = ["Alice", "Bob", "Charlie", "David"];

  final TextEditingController examController = TextEditingController();

  void _createExam() {
    if (examController.text.isNotEmpty) {
      setState(() {
        exams.add(examController.text);
        examAssignments[examController.text] = [];
      });
      examController.clear();
    }
  }

  void _assignStudent(String exam, String student) {
    setState(() {
      examAssignments[exam]?.add(student);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Evaluator Dashboard")),
      body: Column(
        children: [
          // Exam creation
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: examController,
              decoration: InputDecoration(
                labelText: "Enter Exam Name",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _createExam,
                ),
              ),
            ),
          ),

          // Exams list
          Expanded(
            child: ListView.builder(
              itemCount: exams.length,
              itemBuilder: (context, index) {
                String exam = exams[index];
                return Card(
                  child: ExpansionTile(
                    title: Text(exam),
                    children: [
                      Text("Assigned Students: ${examAssignments[exam]?.join(", ")}"),
                      Wrap(
                        children: students.map((student) {
                          return ElevatedButton(
                            onPressed: () => _assignStudent(exam, student),
                            child: Text("Assign $student"),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

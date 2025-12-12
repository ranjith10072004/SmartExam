import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'Config.dart';
import 'ProctorCode.dart';
 
class StudentDashboard extends StatefulWidget {
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}
 
class _StudentDashboardState extends State<StudentDashboard> {
  List<dynamic> exams = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    loadExams();
  }

  // ---------------------------------------------------
  // FETCH STUDENT EXAMS
  // ---------------------------------------------------

  Future<void> loadExams() async {
    final token = await ApiService.getToken();
    final url = Uri.parse("${Config.baseUrl}/student/exams");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      print("EXAMS LOAD STATUS: ${response.statusCode}");
      print("EXAMS LOAD BODY: ${response.body}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          exams = data["exams"];
          loading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["msg"] ?? "Failed to load exams")),
        );
        setState(() => loading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => loading = false);
    }
  }
  // ---------------------------------------------------
  // UI
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text("Student Dashboard"),

        backgroundColor: Colors.blueAccent,

      ),
 
      body: loading

          ? Center(child: CircularProgressIndicator())

          : exams.isEmpty

              ? Center(

                  child: Text(

                    "No exams available.",

                    style: TextStyle(fontSize: 18),

                  ),

                )

              : ListView.builder(

                  padding: EdgeInsets.all(16),

                  itemCount: exams.length,

                  itemBuilder: (context, index) {

                    final exam = exams[index];
 
                    return Card(

                      elevation: 3,

                      margin: EdgeInsets.only(bottom: 15),

                      child: Padding(

                        padding: EdgeInsets.all(16),

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(

                              exam["title"],

                              style: TextStyle(

                                  fontSize: 20, fontWeight: FontWeight.bold),

                            ),

                            SizedBox(height: 6),
 
                            Text(exam["description"] ?? ""),
 
                            SizedBox(height: 10),

                            Text(

                              "Start: ${exam['examStartTime']}",

                              style: TextStyle(color: Colors.grey[700]),

                            ),

                            Text(

                              "End: ${exam['examEndTime']}",

                              style: TextStyle(color: Colors.grey[700]),

                            ),
 
                            SizedBox(height: 12),
 
                            ElevatedButton(

                              style: ElevatedButton.styleFrom(

                                backgroundColor: Colors.green,

                                padding: EdgeInsets.symmetric(vertical: 12),

                              ),

                              child: Text("Start Exam"),

                              onPressed: () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) => ProctorCodeScreen(

                                      examId: exam["_id"],

                                    ),

                                  ),

                                );

                              },

                            ),

                          ],

                        ),

                      ),

                    );

                  },

                ),

    );

  }

}

 
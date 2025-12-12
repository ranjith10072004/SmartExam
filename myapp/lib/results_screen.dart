import 'package:flutter/material.dart';
import 'evaluation_service.dart';
import 'evaluate_screen.dart';

class PendingResultsScreen extends StatefulWidget {
  @override
  _PendingResultsScreenState createState() => _PendingResultsScreenState();
}

class _PendingResultsScreenState extends State<PendingResultsScreen> {
  List results = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    try {
      final data = await EvaluationService.getPendingResults();
      setState(() {
        results = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Evaluations")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? Center(child: Text("No pending results"))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final r = results[i];
                    return Card(
                      child: ListTile(
                        title: Text(r["examId"]["title"]),
                        subtitle: Text("Student: ${r["studentId"]["name"]}"),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EvaluateScreen(resultId: r["_id"]),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
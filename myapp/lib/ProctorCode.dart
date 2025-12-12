import 'package:flutter/material.dart';
import 'api_service.dart';
import 'student_exam_view.dart';

class ProctorCodeScreen extends StatefulWidget {
  final String examId;

  const ProctorCodeScreen({Key? key, required this.examId}) : super(key: key);

  @override
  State<ProctorCodeScreen> createState() => _ProctorCodeScreenState();
}

class _ProctorCodeScreenState extends State<ProctorCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    setState(() => _loading = true);

    try {
      final result = await ApiService.verifyProctorCode(
        widget.examId,
        _codeController.text.trim(),
      );

      if (!mounted) return;

      if (result["success"] == true) {
        // ⬅ DIRECTLY NAVIGATE TO EXAM WITHOUT POP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentExamView(
              examId: widget.examId,
              proctorCode: _codeController.text.trim(),
            ),
          ),
        );
      } else {
        final msg = result["data"]?["msg"] ??
            result["msg"] ??
            result["error"] ??
            "Invalid code";

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Proctor Code")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "Proctor Code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _loading ? null : _verifyCode,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Verify Code"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

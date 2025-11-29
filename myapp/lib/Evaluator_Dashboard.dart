import 'package:flutter/material.dart';
import 'main.dart';
import 'Config.dart';
import 'api_service.dart';
import 'AdminCreateExam.dart';

// -------------------- THEME --------------------
class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
}

class AppTextStyles {
  static const TextStyle headlineLarge =
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

  static const TextStyle headlineMedium =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  static const TextStyle bodyLarge =
      TextStyle(fontSize: 16, fontWeight: FontWeight.normal);

  static const TextStyle bodyMedium =
      TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
}

// -------------------- DASHBOARD ROOT --------------------
class EvaluatorDashboard extends StatelessWidget {
  const EvaluatorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage();
  }
}

// -------------------- DASHBOARD PAGE --------------------
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Exam> _exams = [];

  int _selectedTabIndex = 0;

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluator Dashboard'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('No new notifications')));
              }),
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),

      body: Column(
        children: [
          Row(
            children: [
              _buildTab("Create Exam", 0),
              _buildTab("Manage Exams", 1),
              _buildTab("Students", 2),
              _buildTab("Grades", 3),
            ],
          ),

          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildCreateExamTab(),
                _buildManageExamsTab(),
                _buildStudentsTab(),
                _buildStudentsGradesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTabIndex == index ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedTabIndex == index ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- CREATE EXAM TAB --------------------
  Widget _buildCreateExamTab() {
    return Center(
      child: ElevatedButton(
        child: const Text("Create New Exam"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminCreateExam()),
          );
        },
      ),
    );
  }

  // -------------------- MANAGE EXAMS TAB --------------------
  Widget _buildManageExamsTab() {
    if (_exams.isEmpty) {
      return const Center(child: Text("No Exams Created"));
    }
    return const Center(child: Text("Exam List Here"));
  }

  Widget _buildStudentsTab() {
    return const Center(child: Text("Students Tab"));
  }

  Widget _buildStudentsGradesTab() {
    return const Center(child: Text("Grades Tab"));
  }
}

// -------------------- MODELS --------------------
class Exam {
  final String id, name, duration, totalMarks;
  ExamStatus status;
  final List<String> assignedStudents;
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.name,
    required this.duration,
    required this.totalMarks,
    required this.status,
    required this.assignedStudents,
    required this.createdAt,
  });
}

class Student {
  final String id, name, email, grade;
  Student({required this.id, required this.name, required this.email, required this.grade});
}

enum ExamStatus { draft, active, completed }

// -------------------- LOGIN SCREEN --------------------
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Login")),
        body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("You have been logged out."),
          ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyApp()));
              },
              child: const Text("Log Back In"))
        ])));
  }
}

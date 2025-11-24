import 'package:flutter/material.dart';
// Remove: import 'main.dart'; - This causes circular dependency

// --- Theme and Utility Classes (Kept as is) ---
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
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceVariant,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceVariant,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}


class EvaluatorDashboard extends StatelessWidget {
  const EvaluatorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evaluator Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // --- State Variables and Initial Data ---
  final List<Exam> _exams = [];
  final List<Student> _students = [
    Student(id: '1', name: 'P Varsha', email: 'Varsha@bitswilp.com', grade: '80'),
    Student(id: '2', name: 'Ch Ranjith', email: 'Ranjith@bitswilp.com', grade: '80'),
    Student(id: '3', name: 'Ch Lakshitha', email: 'Lakshitha@bitswilp.com', grade: '80'),
    Student(id: '4', name: 'G Lakshitha', email: 'Lakshitha@bitswilp.com', grade: '80'),
    Student(id: '5', name: 'G Dharaninath', email: 'Dharaninath@bitswilp.com', grade: '80'),
  ];

  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _examDurationController = TextEditingController();
  final TextEditingController _totalMarksController = TextEditingController();

  int _selectedTabIndex = 0;

  // --- Utility Methods ---

  void _createExam() {
    if (_examNameController.text.isNotEmpty) {
      setState(() {
        _exams.add(Exam(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _examNameController.text,
          duration: _examDurationController.text.isEmpty ? '60 min' : '${_examDurationController.text} min',
          totalMarks: _totalMarksController.text.isEmpty ? '100' : _totalMarksController.text,
          assignedStudents: [],
          createdAt: DateTime.now(),
          status: ExamStatus.draft,
        ));
      });
      _examNameController.clear();
      _examDurationController.clear();
      _totalMarksController.clear();
    }
  }

  void _assignStudent(String examId, String studentId) {
    setState(() {
      final exam = _exams.firstWhere((exam) => exam.id == examId);
      if (!exam.assignedStudents.contains(studentId)) {
        exam.assignedStudents.add(studentId);
      }
    });
  }

  void _removeStudent(String examId, String studentId) {
    setState(() {
      final exam = _exams.firstWhere((exam) => exam.id == examId);
      exam.assignedStudents.remove(studentId);
    });
  }

  void _deleteExam(String examId) {
    setState(() {
      _exams.removeWhere((exam) => exam.id == examId);
    });
  }

  void _updateExamStatus(String examId, ExamStatus status) {
    setState(() {
      final exam = _exams.firstWhere((exam) => exam.id == examId);
      exam.status = status;
    });
  }

  List<Student> _getAssignedStudents(String examId) {
    final exam = _exams.firstWhere((exam) => exam.id == examId);
    return _students.where((student) => exam.assignedStudents.contains(student.id)).toList();
  }

  List<Student> _getAvailableStudents(String examId) {
    final exam = _exams.firstWhere((exam) => exam.id == examId);
    return _students.where((student) => !exam.assignedStudents.contains(student.id)).toList();
  }

  // *FIXED*: Moved _handleLogout outside of the build method
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to LoginScreen and clear the route stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluator Dashboard'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout, // Call the moved method
          ),
        ],
      ),
      body: Column( // *FIXED*: Now `body` is correctly the property of Scaffold
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTab('Create Exam', 0),
                _buildTab('Manage Exams', 1),
                _buildTab('Students', 2),
                _buildTab('Grades', 3),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildCreateExamTab(),
                _buildManageExamsTab(),
                _buildStudentsTab(),
                _buildStudentsGrades(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Builders for Tabs and Components (Kept as is) ---
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
              fontWeight: _selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
              color: _selectedTabIndex == index ? Colors.blue : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateExamTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Exam',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fill in the exam details below',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Exam Name
          TextField(
            controller: _examNameController,
            decoration: const InputDecoration(
              labelText: 'Exam Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.assignment),
            ),
          ),
          const SizedBox(height: 16),

          // Duration and Marks in Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _examDurationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (min)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _totalMarksController,
                  decoration: const InputDecoration(
                    labelText: 'Total Marks',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.grade),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Create Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createExam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create Exam',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageExamsTab() {
    if (_exams.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No exams created yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Create your first exam in the "Create Exam" tab',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _exams.length,
      itemBuilder: (context, index) {
        final exam = _exams[index];
        final assignedStudents = _getAssignedStudents(exam.id);
        final availableStudents = _getAvailableStudents(exam.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ExpansionTile(
            leading: _getStatusIcon(exam.status),
            title: Text(
              exam.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${exam.duration} • ${exam.totalMarks} marks'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exam Info
                    Row(
                      children: [
                        _buildInfoChip(Icons.timer, exam.duration),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.grade, '${exam.totalMarks} marks'),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.people, '${assignedStudents.length} students'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status Actions
                    const Text(
                      'Exam Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildStatusButton('Draft', ExamStatus.draft, exam),
                        _buildStatusButton('Active', ExamStatus.active, exam),
                        _buildStatusButton('Completed', ExamStatus.completed, exam),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Assigned Students
                    const Text(
                      'Assigned Students:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (assignedStudents.isEmpty)
                      const Text('No students assigned yet', style: TextStyle(color: Colors.grey))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: assignedStudents.map((student) {
                          return Chip(
                            label: Text(student.name),
                            deleteIcon: const Icon(Icons.remove_circle, size: 16),
                            onDeleted: () => _removeStudent(exam.id, student.id),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 16),

                    // Available Students
                    const Text(
                      'Available Students:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (availableStudents.isEmpty)
                      const Text('All students assigned', style: TextStyle(color: Colors.grey))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableStudents.map((student) {
                          return FilterChip(
                            label: Text(student.name),
                            selected: false,
                            onSelected: (_) => _assignStudent(exam.id, student.id),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 16),

                    // Delete Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteExam(exam.id),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete Exam', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final assignedExams = _exams.where((exam) => exam.assignedStudents.contains(student.id)).toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(student.name[0], style: const TextStyle(color: Colors.blue)),
            ),
            title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.email),
                const SizedBox(height: 4),
                Text(
                  'Assigned to ${assignedExams.length} exam(s)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Chip(
              label: Text('${assignedExams.length} exams'),
              backgroundColor: Colors.blue[50],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsGrades() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(student.name[0], style: const TextStyle(color: Colors.blue)),
            ),
            title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grade: ${student.grade}'),
                const SizedBox(height: 4),
                Text(
                  'Total Marks: ${student.grade}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildStatusButton(String label, ExamStatus status, Exam exam) {
    final isSelected = exam.status == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _updateExamStatus(exam.id, status),
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _getStatusIcon(ExamStatus status) {
    switch (status) {
      case ExamStatus.draft:
        return const Icon(Icons.drafts, color: Colors.orange);
      case ExamStatus.active:
        return const Icon(Icons.play_arrow, color: Colors.green);
      case ExamStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.blue);
    }
  }
}

// --- Data Models ---
class Exam {
  final String id;
  final String name;
  final String duration;
  final String totalMarks;
  final List<String> assignedStudents;
  final DateTime createdAt;
  ExamStatus status;

  Exam({
    required this.id,
    required this.name,
    required this.duration,
    required this.totalMarks,
    required this.assignedStudents,
    required this.createdAt,
    required this.status,
  });
}

class Student {
  final String id;
  final String name;
  final String email;
  final String grade;

  Student({
    required this.id, 
    required this.name, 
    required this.email,
    required this.grade
  });
}

enum ExamStatus { draft, active, completed }

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                "You have been logged out.",
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const EvaluatorDashboard()),
                    );
                  },
                  child: const Text("Log Back In"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
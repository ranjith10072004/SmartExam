// lib/Evaluator_Dashboard.dart

import 'package:flutter/material.dart';
import 'main.dart';
import 'api_service.dart';
import 'AdminCreateExam.dart';

// -------------------- THEME / STYLES --------------------

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color background = Color(0xFFFAFAFA);
}

class AppTextStyles {
  static const TextStyle title = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle subtitle = TextStyle(fontSize: 14);
}

// -------------------- ROOT DASHBOARD --------------------

class EvaluatorDashboard extends StatelessWidget {
  const EvaluatorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage();
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTabIndex = 0;

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MyApp()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          )
        ],
      ),
    );
  }

  Widget _tab(String title, int index) {
    final selected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: selected ? AppColors.primary : Colors.transparent, width: 3)),
          ),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: selected ? AppColors.primary : Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Evaluator Dashboard'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          )
        ],
      ),
      body: Column(
        children: [
          Row(children: [
            _tab('Create Exam', 0),
            _tab('Manage Exams', 1),
            _tab('Students', 2),
            _tab('Grades', 3),
          ]),
          const Divider(height: 1),
          Expanded(
          child: IndexedStack(
            index: _selectedTabIndex,
          children: [
          AdminCreateExam(),           // index 0
          ManageExamsPage(),            // index 1
          ManageStudentsPage(),         // index 2
          Center(child: Text('Grades - coming soon')),  // index 3
          ],
        ),
      ),
        ],
      ),
    );
  }
}

// -------------------- CREATE EXAM SCREEN --------------------

Widget _buildCreateExamTab(BuildContext context) {
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

// -------------------- MANAGE EXAMS --------------------

class ManageExamsPage extends StatefulWidget {
  const ManageExamsPage({super.key});
  
  @override
  State<ManageExamsPage> createState() => _ManageExamsPageState();
}

class _ManageExamsPageState extends State<ManageExamsPage> {
  bool loading = true;
  List<dynamic> exams = [];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.getAdminExams();
      setState(() {
        exams = data ?? [];
      });
    } catch (e) {
      debugPrint('Failed to load exams: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load exams: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _deleteExam(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete exam'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(_, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    final res = await ApiService.deleteExam(id);
    if (res != null && res['error'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
      _loadExams();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: ${res?['error'] ?? 'unknown'}')));
    }
  }

  Future<void> _editExamDialog(Map<String, dynamic> exam) async {
    final titleCtl = TextEditingController(text: exam['title'] ?? '');
    final descCtl = TextEditingController(text: exam['description'] ?? '');
    final durationCtl = TextEditingController(text: (exam['duration'] ?? 60).toString());

    DateTime? start;
    DateTime? end;
    try {
      final s = exam['examStartTime'];
      if (s is String) start = DateTime.tryParse(s);
      else if (s is Map && s[r'$date'] != null) start = DateTime.parse(s[r'$date']);
    } catch (_) {}
    
    try {
      final e = exam['examEndTime'];
      if (e is String) end = DateTime.tryParse(e);
      else if (e is Map && e[r'$date'] != null) end = DateTime.parse(e[r'$date']);
    } catch (_) {}

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setStateSB) {
          return AlertDialog(
            title: const Text('Edit exam'),
            content: SingleChildScrollView(
              child: Column(children: [
                TextField(controller: titleCtl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 8),
                TextField(controller: descCtl, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 8),
                TextField(controller: durationCtl, decoration: const InputDecoration(labelText: 'Duration (mins)'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Text('Start: ${start?.toLocal().toString().substring(0, 16) ?? 'Not set'}')),
                  TextButton(
                    onPressed: () async {
                      final dt = await showDatePicker(context: ctx2, initialDate: start ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365 * 3)));
                      if (dt == null) return;
                      final tm = await showTimePicker(context: ctx2, initialTime: TimeOfDay.fromDateTime(start ?? DateTime.now()));
                      if (tm == null) return;
                      setStateSB(() => start = DateTime(dt.year, dt.month, dt.day, tm.hour, tm.minute));
                    },
                    child: const Text('Pick'),
                  )
                ]),
                Row(children: [
                  Expanded(child: Text('End: ${end?.toLocal().toString().substring(0, 16) ?? 'Not set'}')),
                  TextButton(
                    onPressed: () async {
                      final dt = await showDatePicker(context: ctx2, initialDate: end ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 3)));
                      if (dt == null) return;
                      final tm = await showTimePicker(context: ctx2, initialTime: TimeOfDay.fromDateTime(end ?? DateTime.now()));
                      if (tm == null) return;
                      setStateSB(() => end = DateTime(dt.year, dt.month, dt.day, tm.hour, tm.minute));
                    },
                    child: const Text('Pick'),
                  )
                ]),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final body = {
                    "title": titleCtl.text.trim(),
                    "description": descCtl.text.trim(),
                    "duration": int.tryParse(durationCtl.text.trim()) ?? 60,
                    "examStartTime": start?.toIso8601String(),
                    "examEndTime": end?.toIso8601String(),
                  };
                  Navigator.pop(ctx2);
                  final res = await ApiService.updateExam(exam['_id']?.toString() ?? exam['id']?.toString() ?? '', body);
                  if (res != null && res['error'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
                    _loadExams();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: ${res?['error'] ?? 'unknown'}')));
                  }
                },
                child: const Text('Save'),
              )
            ],
          );
        });
      },
    );
  }

  Future<void> _openAssignDialog(Map<String, dynamic> exam) async {
    final students = await ApiService.getAllStudents();
    final assigned = List<String>.from((exam['assignedTo'] as List?)?.map((a) {
          if (a is Map && a[r'$oid'] != null) return a[r'$oid'].toString();
          if (a is String) return a;
          if (a is Map && a['_id'] != null) return a['_id'].toString();
          return a?.toString() ?? '';
        }) ??
        []);
    final selected = <String>{...assigned};

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Assign — ${exam['title'] ?? ''}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: students.map((s) {
                final sid = (s['_id']?.toString() ?? s['id']?.toString() ?? '').toString();
                final name = s['name'] ?? s['email'] ?? 'Student';
                return StatefulBuilder(builder: (ctx, setStateSB) {
                  return CheckboxListTile(
                    value: selected.contains(sid),
                    title: Text(name),
                    subtitle: Text(s['email'] ?? ''),
                    onChanged: (v) {
                      setStateSB(() {
                        if (v == true && sid.isNotEmpty) selected.add(sid);
                        else selected.remove(sid);
                      });
                    },
                  );
                });
              }).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final toAssign = selected.difference(assigned.toSet());
                final toUnassign = assigned.toSet().difference(selected);
                final examId = exam['_id']?.toString() ?? exam['id']?.toString() ?? '';

                for (final sid in toAssign) {
                if (sid.isNotEmpty) {
                  await ApiService.assignExamToStudent(examId, [sid]); // wrap into list
                  }
                }

                for (final sid in toUnassign) {
                if (sid.isNotEmpty) {
                await ApiService.unassignExamFromStudent(examId, [sid]); // wrap into list
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignments updated')));
                _loadExams();
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          loading
              ? const Center(child: CircularProgressIndicator())
              : exams.isEmpty
                  ? const Center(child: Text('No exams'))
                  : RefreshIndicator(
                      onRefresh: _loadExams,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: exams.length,
                        itemBuilder: (context, i) {
                          final ex = exams[i];
                          final title = ex['title'] ?? 'Untitled';
                          final desc = ex['description'] ?? '';
                          String start = '';
                          try {
                            final s = ex['examStartTime'];
                            if (s is String) start = s;
                            else if (s is Map && s[r'$date'] != null) start = s[r'$date'];
                          } catch (_) {}
                          final assignedCount = (ex['assignedTo'] as List?)?.length ?? 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('$desc\nStart: $start\nAssigned: $assignedCount'),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'edit') _editExamDialog(ex);
                                  if (v == 'delete') _deleteExam(ex['_id']?.toString() ?? ex['id']?.toString() ?? '');
                                  if (v == 'assign') _openAssignDialog(ex);
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'assign', child: Text('Assign')),
                                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          
          // Refresh button overlay - positioned at top right
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _loadExams,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- MANAGE STUDENTS --------------------

class ManageStudentsPage extends StatefulWidget {
  const ManageStudentsPage({super.key});
  
  @override
  State<ManageStudentsPage> createState() => _ManageStudentsPageState();
}

class _ManageStudentsPageState extends State<ManageStudentsPage> {
  bool loading = true;
  List<dynamic> students = [];
  List<dynamic> exams = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    try {
      final s = await ApiService.getAllStudents();
      final e = await ApiService.getAdminExams();
      setState(() {
        students = s ?? [];
        exams = e ?? [];
      });
    } catch (e) {
      debugPrint('loadAll error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _openAssignToStudent(dynamic student) async {
    final assigned = List<String>.from((student['assignedExams'] as List?)?.map((a) {
          if (a is Map && a[r'$oid'] != null) return a[r'$oid'].toString();
          if (a is String) return a;
          if (a is Map && a['_id'] != null) return a['_id'].toString();
          return a?.toString() ?? '';
        }) ??
        []);
    final selected = <String>{...assigned};

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Assign exams — ${student['name'] ?? student['email'] ?? ''}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: exams.map((ex) {
                final id = ex['_id']?.toString() ?? ex['id']?.toString() ?? '';
                return StatefulBuilder(builder: (ctx, setStateSB) {
                  return CheckboxListTile(
                    title: Text(ex['title'] ?? ''),
                    value: selected.contains(id),
                    onChanged: (v) {
                      setStateSB(() {
                        if (v == true && id.isNotEmpty) selected.add(id);
                        else selected.remove(id);
                      });
                    },
                  );
                });
              }).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final toAssign = selected.difference(assigned.toSet());
                final toUnassign = assigned.toSet().difference(selected);
                final studentId = student['_id']?.toString() ?? student['id']?.toString() ?? '';

                for (final exId in toAssign) {
                if (exId.isNotEmpty && studentId.isNotEmpty) {
                  await ApiService.assignExamToStudent(exId, [studentId]); // list
                  }
                }

                for (final exId in toUnassign) {
                if (exId.isNotEmpty && studentId.isNotEmpty) {
                await ApiService.unassignExamFromStudent(exId, [studentId]); // list
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
                _loadAll();
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(child: Text('No students'))
              : RefreshIndicator(
                onRefresh: _loadAll,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: students.length,
                  itemBuilder: (context, i) {
                    final s = students[i];
                    final name = s['name'] ?? s['email'] ?? 'Student';
                    final assignedCount = (s['assignedExams'] as List?)?.length ?? 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text('Assigned exams: $assignedCount'),
                        trailing: ElevatedButton(onPressed: () => _openAssignToStudent(s), child: const Text('Assign')),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
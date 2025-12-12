import 'package:flutter/material.dart';
import 'main.dart';
import 'api_service.dart';
import 'AdminCreateExam.dart';
import 'pending_results.dart';

// -------------------- THEME / STYLES --------------------

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color background = Color(0xFFFAFAFA);
}

class AppTextStyles {
  static const TextStyle title =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          Row(
            children: [
              _tab('Create Exam', 0),
              _tab('Manage Exams', 1),
              _tab('Students', 2),
              _tab('Grades', 3),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                CreateExamScreen(),      // 0
                ManageExamsPage(),       // 1
                ManageStudentsPage(),    // 2
                PendingResultsPage(),    // 3  <-- GRADES TAB
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- CREATE EXAM TAB (unused helper) --------------------

Widget _buildCreateExamTab(BuildContext context) {
  return Center(
    child: ElevatedButton(
      child: const Text("Create New Exam"),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CreateExamScreen()),
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
      final response = await ApiService.getAdminExams();

      if (response is Map<String, dynamic>) {
        if (response['exams'] is List) {
          exams = response['exams'] as List<dynamic>;
        } else if (response['data'] is List) {
          exams = response['data'] as List<dynamic>;
        } else {
          final values = response.values.toList();
          if (values.isNotEmpty && values.first is List) {
            exams = values.first as List<dynamic>;
          } else {
            exams = [];
          }
        }
      } else {
        exams = [];
      }
    } catch (e) {
      debugPrint('Failed to load exams: $e');
      exams = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load exams: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _deleteExam(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete exam'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final res = await ApiService.deleteExam(id);
    if (!res.containsKey('error') || res['error'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleted')),
        );
      }
      _loadExams();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${res['error'] ?? 'unknown'}')),
        );
      }
    }
  }

  Future<void> _editExamDialog(Map<String, dynamic> exam) async {
    final titleCtl =
        TextEditingController(text: exam['title']?.toString() ?? '');
    final descCtl =
        TextEditingController(text: exam['description']?.toString() ?? '');
    final durationCtl =
        TextEditingController(text: exam['duration']?.toString() ?? '60');

    DateTime? start;
    DateTime? end;

    try {
      final s = exam['examStartTime'];
      if (s is String) {
        start = DateTime.tryParse(s);
      } else if (s is Map && s[r'$date'] != null) {
        start = DateTime.tryParse(s[r'$date'].toString());
      }
    } catch (_) {}

    try {
      final e = exam['examEndTime'];
      if (e is String) {
        end = DateTime.tryParse(e);
      } else if (e is Map && e[r'$date'] != null) {
        end = DateTime.tryParse(e[r'$date'].toString());
      }
    } catch (_) {}

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setStateSB) {
            return AlertDialog(
              title: const Text('Edit exam'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleCtl,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descCtl,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: durationCtl,
                      decoration: const InputDecoration(
                          labelText: 'Duration (mins)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Start: ${start?.toLocal().toString().substring(0, 16) ?? 'Not set'}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final dt = await showDatePicker(
                              context: ctx2,
                              initialDate: start ?? DateTime.now(),
                              firstDate:
                                  DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 3)),
                            );
                            if (dt == null) return;
                            final tm = await showTimePicker(
                              context: ctx2,
                              initialTime: TimeOfDay.fromDateTime(
                                  start ?? DateTime.now()),
                            );
                            if (tm == null) return;
                            setStateSB(
                              () => start = DateTime(
                                dt.year,
                                dt.month,
                                dt.day,
                                tm.hour,
                                tm.minute,
                              ),
                            );
                          },
                          child: const Text('Pick'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'End: ${end?.toLocal().toString().substring(0, 16) ?? 'Not set'}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final dt = await showDatePicker(
                              context: ctx2,
                              initialDate: end ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 3)),
                            );
                            if (dt == null) return;
                            final tm = await showTimePicker(
                              context: ctx2,
                              initialTime: TimeOfDay.fromDateTime(
                                  end ?? DateTime.now()),
                            );
                            if (tm == null) return;
                            setStateSB(
                              () => end = DateTime(
                                dt.year,
                                dt.month,
                                dt.day,
                                tm.hour,
                                tm.minute,
                              ),
                            );
                          },
                          child: const Text('Pick'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx2),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final body = {
                      "title": titleCtl.text.trim(),
                      "description": descCtl.text.trim(),
                      "duration":
                          int.tryParse(durationCtl.text.trim()) ?? 60,
                      "examStartTime": start?.toIso8601String(),
                      "examEndTime": end?.toIso8601String(),
                    };
                    Navigator.pop(ctx2);
                    final examId =
                        exam['_id']?.toString() ?? exam['id']?.toString() ?? '';
                    final res = await ApiService.updateExam(examId, body);
                    if (!res.containsKey('error') || res['error'] == null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Updated')),
                        );
                      }
                      _loadExams();
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Update failed: ${res['error'] ?? 'unknown'}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openAssignDialog(Map<String, dynamic> exam) async {
    final response = await ApiService.getAllStudents();
    List<dynamic> studentsList = [];

    if (response is Map<String, dynamic>) {
      if (response['students'] is List) {
        studentsList = response['students'] as List<dynamic>;
      } else if (response['data'] is List) {
        studentsList = response['data'] as List<dynamic>;
      } else {
        for (final value in response.values) {
          if (value is List) {
            studentsList = value;
            break;
          }
        }
      }
    }

    final assigned = List<String>.from(
      (exam['assignedTo'] as List?)
              ?.map((a) {
                if (a is Map && a[r'$oid'] != null) {
                  return a[r'$oid'].toString();
                }
                if (a is Map && a['_id'] != null) {
                  return a['_id'].toString();
                }
                if (a is String) return a;
                return '';
              })
              .where((e) => e.isNotEmpty) ??
          [],
    );

    final selected = <String>{...assigned};

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Assign — ${exam['title'] ?? ''}'),
          content: SizedBox(
            width: double.maxFinite,
            child: studentsList.isEmpty
                ? const Center(child: Text('No students available'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: studentsList.length,
                    itemBuilder: (context, index) {
                      final s = studentsList[index];
                      if (s is! Map<String, dynamic>) {
                        return ListTile(
                          title: Text('Invalid student at index $index'),
                        );
                      }

                      final sid =
                          s['_id']?.toString() ?? s['id']?.toString() ?? '';
                      final name =
                          s['name']?.toString() ?? s['email']?.toString() ?? 'Student';

                      return StatefulBuilder(
                        builder: (ctx2, setStateSB) {
                          final isSelected = selected.contains(sid);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(name),
                            subtitle: Text(s['email']?.toString() ?? ''),
                            onChanged: (bool? v) {
                              if (v == true && sid.isNotEmpty) {
                                selected.add(sid);
                              } else {
                                selected.remove(sid);
                              }
                              setStateSB(() {});
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final toAssign = selected.difference(assigned.toSet());
                final toUnassign = assigned.toSet().difference(selected);
                final examId =
                    exam['_id']?.toString() ?? exam['id']?.toString() ?? '';

                for (final sid in toAssign) {
                  if (sid.isNotEmpty) {
                    await ApiService.assignExamToStudent(examId, [sid]);
                  }
                }
                for (final sid in toUnassign) {
                  if (sid.isNotEmpty) {
                    await ApiService.unassignExamFromStudent(examId, [sid]);
                  }
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Assignments updated')),
                  );
                }
                _loadExams();
              },
              child: const Text('Save'),
            ),
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
                          if (ex is! Map<String, dynamic>) {
                            return const Card(
                              child: ListTile(
                                title: Text('Invalid exam data'),
                              ),
                            );
                          }

                          final title =
                              ex['title']?.toString() ?? 'Untitled';
                          final desc =
                              ex['description']?.toString() ?? '';
                          String start = '';
                          try {
                            final s = ex['examStartTime'];
                            if (s is String) {
                              start = s;
                            } else if (s is Map && s[r'$date'] != null) {
                              start = s[r'$date'].toString();
                            }
                          } catch (_) {}

                          final assignedCount =
                              (ex['assignedTo'] as List?)?.length ?? 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '$desc\nStart: $start\nAssigned: $assignedCount',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'edit') _editExamDialog(ex);
                                  if (v == 'delete') {
                                    final id = ex['_id']?.toString() ??
                                        ex['id']?.toString() ??
                                        '';
                                    _deleteExam(id);
                                  }
                                  if (v == 'assign') _openAssignDialog(ex);
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                      value: 'assign',
                                      child: Text('Assign')),
                                  PopupMenuItem(
                                      value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete')),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
      final sResponse = await ApiService.getAllStudents();
      final eResponse = await ApiService.getAdminExams();

      if (sResponse is Map<String, dynamic>) {
        if (sResponse['students'] is List) {
          students = sResponse['students'] as List<dynamic>;
        } else if (sResponse['data'] is List) {
          students = sResponse['data'] as List<dynamic>;
        } else {
          for (final v in sResponse.values) {
            if (v is List) {
              students = v;
              break;
            }
          }
        }
      } else {
        students = [];
      }

      if (eResponse is Map<String, dynamic>) {
        if (eResponse['exams'] is List) {
          exams = eResponse['exams'] as List<dynamic>;
        } else if (eResponse['data'] is List) {
          exams = eResponse['data'] as List<dynamic>;
        } else {
          for (final v in eResponse.values) {
            if (v is List) {
              exams = v;
              break;
            }
          }
        }
      } else {
        exams = [];
      }
    } catch (e) {
      debugPrint('loadAll error: $e');
      students = [];
      exams = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openAssignToStudent(dynamic student) async {
    final studentData = student as Map<String, dynamic>;
    final assigned = List<String>.from(
      (studentData['assignedExams'] as List?)
              ?.map((a) {
                if (a is Map && a[r'$oid'] != null) {
                  return a[r'$oid'].toString();
                }
                if (a is Map && a['_id'] != null) {
                  return a['_id'].toString();
                }
                if (a is String) return a;
                return '';
              })
              .where((e) => e.isNotEmpty) ??
          [],
    );

    final selected = <String>{...assigned};

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Assign exams — ${studentData['name'] ?? studentData['email'] ?? ''}',
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: exams.isEmpty
                ? const Center(child: Text('No exams available'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: exams.length,
                    itemBuilder: (context, index) {
                      final ex = exams[index];
                      if (ex is! Map<String, dynamic>) {
                        return ListTile(
                          title: Text('Invalid exam at index $index'),
                        );
                      }

                      final id =
                          ex['_id']?.toString() ?? ex['id']?.toString() ?? '';
                      return StatefulBuilder(
                        builder: (ctx2, setStateSB) {
                          final isSelected = selected.contains(id);
                          return CheckboxListTile(
                            title: Text(ex['title']?.toString() ?? ''),
                            value: isSelected,
                            onChanged: (bool? v) {
                              if (v == true && id.isNotEmpty) {
                                selected.add(id);
                              } else {
                                selected.remove(id);
                              }
                              setStateSB(() {});
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
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
                      if (s is! Map<String, dynamic>) {
                        return Card(
                          child: ListTile(
                            title:
                                Text('Invalid student data at index $i'),
                          ),
                        );
                      }

                      final name = s['name']?.toString() ??
                          s['email']?.toString() ??
                          'Student';
                      final assignedCount =
                          (s['assignedExams'] as List?)?.length ?? 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(name),
                          subtitle:
                              Text('Assigned exams: $assignedCount'),
                          trailing: ElevatedButton(
                            onPressed: () => _openAssignToStudent(s),
                            child: const Text('Assign'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'main.dart';

// ---------------------------------------------------------------------------
// APP THEMES
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------------------------
class Exam {
  final String id;
  final String title;
  final DateTime dateTime;
  final String instructor;
  final String? duration;
  final bool isActive;

  const Exam({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.instructor,
    this.duration,
    this.isActive = false,
  });
}

class StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// ---------------------------------------------------------------------------
// MOCK DATA SERVICE
// ---------------------------------------------------------------------------
class MockDataService {
  static final List<Exam> upcomingExams = [
    Exam(
      id: '1',
      title: 'Mathematics Final',
      dateTime: DateTime(2024, 1, 20, 14, 0),
      instructor: 'Dr. Smith',
    ),
    Exam(
      id: '2',
      title: 'Physics Midterm',
      dateTime: DateTime(2024, 1, 22, 10, 0),
      instructor: 'Prof. Johnson',
    ),
    Exam(
      id: '3',
      title: 'Chemistry Quiz',
      dateTime: DateTime(2024, 1, 25, 15, 30),
      instructor: 'Dr. Williams',
    ),
  ];

  static final List<Exam> activeExams = [
    Exam(
      id: '4',
      title: 'Science Weekly Quiz',
      dateTime: DateTime(2024, 1, 18, 10, 0),
      instructor: 'Dr. Brown',
      duration: '25:30',
      isActive: true,
    ),
  ];

  static final List<StatItem> stats = [
    const StatItem(
      title: 'Exams Taken',
      value: '12',
      icon: Icons.assignment,
      color: AppColors.primary,
    ),
    const StatItem(
      title: 'Avg Score',
      value: '84%',
      icon: Icons.bar_chart,
      color: AppColors.success,
    ),
    const StatItem(
      title: 'Study Hours',
      value: '24h',
      icon: Icons.timer,
      color: AppColors.warning,
    ),
    const StatItem(
      title: 'Rank',
      value: 'A',
      icon: Icons.leaderboard,
      color: Color(0xFF7B1FA2),
    ),
  ];
}

// ---------------------------------------------------------------------------
// MAIN DASHBOARD
// ---------------------------------------------------------------------------
class SmartExamDashboard extends StatefulWidget {
  const SmartExamDashboard({super.key});

  @override
  State<SmartExamDashboard> createState() => _SmartExamDashboardState();
}

class _SmartExamDashboardState extends State<SmartExamDashboard> {
  final String userName = 'John';
  final int upcomingExamCount = 3;

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

  void _handleJoinExam(Exam exam) {
    // TODO: Implement exam joining logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining ${exam.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleViewExamDetails(Exam exam) {
    // TODO: Implement exam details navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for ${exam.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'SmartExam',
        style: TextStyle(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      actions: [
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_outlined, color: AppColors.onPrimary),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const NotificationDialog(),
          ),
        ),
        IconButton(
          tooltip: 'Log Out',
          icon: const Icon(Icons.logout, color: AppColors.onPrimary),
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh logic
        await Future.delayed(const Duration(seconds: 1));
        setState(() {});
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: AppSpacing.lg),
            
            _buildSectionTitle('Quick Stats'),
            const SizedBox(height: AppSpacing.sm),
            _buildStatsGrid(context),
            
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Upcoming Exams'),
            const SizedBox(height: AppSpacing.sm),
            _buildUpcomingExams(context),
            
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Active Exams'),
            const SizedBox(height: AppSpacing.sm),
            _buildActiveExams(context),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Semantics(
      header: true,
      child: Text(
        title,
        style: AppTextStyles.titleLarge,
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $userName! 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'You have $upcomingExamCount upcoming exam${upcomingExamCount != 1 ? 's' : ''} this week.',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.5,
      ),
      itemCount: MockDataService.stats.length,
      itemBuilder: (context, index) {
        final stat = MockDataService.stats[index];
        return _StatCard(stat: stat);
      },
    );
  }

  Widget _buildUpcomingExams(BuildContext context) {
    if (MockDataService.upcomingExams.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_outlined,
        message: 'No upcoming exams',
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: MockDataService.upcomingExams
            .map((exam) => _ExamListTile(
                  exam: exam,
                  onTap: () => _handleViewExamDetails(exam),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildActiveExams(BuildContext context) {
    if (MockDataService.activeExams.isEmpty) {
      return _buildEmptyState(
        icon: Icons.play_circle_outline,
        message: 'No active exams',
      );
    }

    return Column(
      children: MockDataService.activeExams
          .map((exam) => _ActiveExamCard(
                exam: exam,
                onJoinPressed: () => _handleJoinExam(exam),
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REUSABLE WIDGETS
// ---------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  final StatItem stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "${stat.title}: ${stat.value}",
      button: true,
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            // TODO: Handle stat card tap
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(stat.icon, color: stat.color, size: 28),
                const SizedBox(height: AppSpacing.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    stat.value,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Text(
                  stat.title,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamListTile extends StatelessWidget {
  final Exam exam;
  final VoidCallback onTap;

  const _ExamListTile({
    required this.exam,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          title: Text(
            exam.title,
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${_formatDateTime(exam.dateTime)} • ${exam.instructor}',
            style: AppTextStyles.bodyMedium,
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.onSurfaceVariant),
          onTap: onTap,
        ),
        if (MockDataService.upcomingExams.last != exam)
          const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)}, ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12;
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }
}

class _ActiveExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onJoinPressed;

  const _ActiveExamCard({
    required this.exam,
    required this.onJoinPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.success.withOpacity(0.05),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
              title: Text(
                exam.title,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Time left: ${exam.duration} • ${exam.instructor}',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onJoinPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Join Exam Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NOTIFICATION DIALOG
// ---------------------------------------------------------------------------
class NotificationDialog extends StatelessWidget {
  const NotificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: AppTextStyles.headlineMedium,
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No new notifications',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOGIN SCREEN
// ---------------------------------------------------------------------------
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
              Text(
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
                      MaterialPageRoute(builder: (context) => const MyApp()),
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
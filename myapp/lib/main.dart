import 'package:flutter/material.dart';
import 'Student_Dashboard.dart';
import 'Evaluator_Dashboard.dart';
import 'Config.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartExam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.blue.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

//////////////////////////////////////////////
// HOME SCREEN
//////////////////////////////////////////////

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.school, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              'SmartExam',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your exams efficiently',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Sign In',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//////////////////////////////////////////////
// SIGN IN SCREEN
//////////////////////////////////////////////

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final _formKeyStudent = GlobalKey<FormState>();
  final _formKeyEvaluator = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _handleSignIn(String userType) async {
  final result = await ApiService.login(
    _emailController.text.trim(),
    _passwordController.text.trim(),
  );

  if (result["error"] != null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result["error"])));
    return;
  }

  if (result["msg"] == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Unexpected response")));
    return;
  }

  // SAFE role extraction
  dynamic roleRaw = result["role"]; // <-- FIXED HERE
  if (roleRaw == null || roleRaw is! String) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Server did not return a valid role")),
    );
    return;
  }

  String backendRole = roleRaw.toLowerCase();

  // Map backend admin to evaluator
  if (backendRole == "admin") {
    backendRole = "evaluator";
  }

  String selectedRole = userType.toLowerCase();

  if (selectedRole != backendRole) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("This account is not a $userType account")),
    );
    return;
  }

  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(result["msg"])));

  if (backendRole == "student") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => StudentDashboard()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => EvaluatorDashboard()),
    );
  }
}

  Widget _buildLoginForm(
      GlobalKey<FormState> key, String type, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: key,
        child: Column(
          children: [
            Text('Sign in as $type',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold)),

            const SizedBox(height: 30),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "$type Email",
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? "Enter email" : null,
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? "Enter password" : null,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
  onPressed: () => _handleSignIn(type),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // <-- Correct
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text(
    "Sign In as $type",
    style: const TextStyle(color: Colors.white),
  ),
),

        ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SmartExam Sign In"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: "Student"),
            Tab(icon: Icon(Icons.verified_user), text: "Evaluator"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginForm(_formKeyStudent, "Student", context),
          _buildLoginForm(_formKeyEvaluator, "Evaluator", context),
        ],
      ),
    );
  }
}
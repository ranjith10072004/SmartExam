import 'package:flutter/material.dart';
import 'Student_Dashboard.dart';
import 'Evaluator_Dashboard.dart';
import 'Config.dart';

// MAIN ENTRY POINT

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
        primarySwatch: Colors.blue,
        // Using Material 3 color scheme for a modern look
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
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

// LANDING PAGE (HOME)

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
            // Logo / Icon
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
            const SizedBox(height: 48),

            // Sign Up Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text(
                'Create Account',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Sign In Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: Text(
                'Sign In',
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SIGN UP SCREEN

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isPasswordVisible = false;

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      // 💡 NGrok Compatibility: Use the Config.BASE_URL for the signup API call
      String signUpUrl = Config.getSignInUrl("Student").replaceFirst('login', 'register');
      print('Attempting to register to: $signUpUrl'); 

      // Logic for signing up would go here (e.g., using http.post to signUpUrl)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Account Created. API Endpoint: $signUpUrl')),
      );
      // Go back to Home screen to login
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.length < 6) return 'Must be at least 6 chars';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmController,
                  obscureText: !_isPasswordVisible,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SIGN IN SCREEN - NOW WITH TABS

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

// Add TickerProviderStateMixin to manage the TabController
class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final _formKeyStudent = GlobalKey<FormState>();
  final _formKeyEvaluator = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with 2 tabs
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn(String userType) {
    // NGrok Compatibility: Get the dynamic API URL using the Config class
    final String signInUrl = Config.getSignInUrl(userType);
    print('Attempting to sign in to: $signInUrl'); // Print for debugging

    if (userType == 'Student') {
      // SIGN IN AS STUDENT
      if (_formKeyStudent.currentState!.validate()) {
        // Here you would make your HTTP call using the signInUrl
        // e.g., http.post(Uri.parse(signInUrl), body: {...})

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('$userType Sign In Successful. API: $signInUrl')),
        );

        // Navigate to Dashboard and remove previous routes so user can't "back" to login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SmartExamDashboard()),
          (route) => false,
        );
      }
    } else {
      // SIGN IN AS EVALUATOR
      // Here you would make your HTTP call using the signInUrl
      // e.g., http.post(Uri.parse(signInUrl), body: {...})
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$userType Sign In Successful. API: $signInUrl')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => EvaluatorDashboard()),
        (route) => false,
      );
    }
  }

  // --- Login Form Structure (Reused for both tabs) ---
  Widget _buildLoginForm(
      GlobalKey<FormState> formKey, String userType, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Text(
              'Sign in as $userType',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '$userType Email',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleSignIn(userType),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sign In as $userType',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- End Login Form Structure ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartExam Sign In'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        // The TabBar is placed in the bottom property of the AppBar
        bottom: TabBar(
          indicatorColor: Colors.white,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            controller: _tabController,
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.person), text: 'Student'),
            Tab(icon: Icon(Icons.verified_user), text: 'Evaluator'),
          ],
        ),
      ),
      // The TabBarView uses the controller and holds the content
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          // Tab 1: Student Login Content
          _buildLoginForm(_formKeyStudent, 'Student', context),

          // Tab 2: Evaluator Login Content
          _buildLoginForm(_formKeyEvaluator, 'Evaluator', context),
        ],
      ),
    );
  }
}
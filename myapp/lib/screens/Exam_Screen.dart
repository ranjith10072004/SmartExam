import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExamScreenWithCamera extends StatefulWidget {
  final String examTitle;
  final int totalQuestions;
  final int examDuration; // in minutes

  const ExamScreenWithCamera({
    super.key,
    required this.examTitle,
    required this.totalQuestions,
    required this.examDuration,
  });

  @override
  State<ExamScreenWithCamera> createState() => _ExamScreenWithCameraState();
}

class _ExamScreenWithCameraState extends State<ExamScreenWithCamera> {
  // Camera variables
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = false;

  // Exam variables
  int _currentQuestion = 1;
  int _timeRemaining = 0; // in seconds
  late List<QuestionAnswer> _answers;
  bool _isExamStarted = false;
  bool _isExamFinished = false;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.examDuration * 60;
    _answers = List.generate(widget.totalQuestions, (index) => QuestionAnswer());
    _initializeCamera();
    _startExamTimer();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Initialize camera
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _initializeCameraController(_cameras!.first);
    }
  }

  Future<void> _initializeCameraController(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  // Switch between front and back camera
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isCameraInitialized = false;
    });

    await _cameraController?.dispose();

    final newCamera = _isFrontCamera ? _cameras!.first : _cameras!.last;
    _isFrontCamera = !_isFrontCamera;

    await _initializeCameraController(newCamera);
  }

  // Take picture
  Future<void> _takePicture() async {
    if (!_isCameraInitialized || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile picture = await _cameraController!.takePicture();
      
      // Save the picture path for the current question
      setState(() {
        _answers[_currentQuestion - 1].imagePath = picture.path;
        _answers[_currentQuestion - 1].answeredAt = DateTime.now();
      });

      // Show preview
      _showImagePreview(picture.path);
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  // Show image preview
  void _showImagePreview(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Captured'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(imagePath)),
            const SizedBox(height: 16),
            const Text('Do you want to keep this photo?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete the image if not satisfied
              File(imagePath).delete();
              setState(() {
                _answers[_currentQuestion - 1].imagePath = null;
              });
            },
            child: const Text('Retake'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Keep'),
          ),
        ],
      ),
    );
  }

  // Exam timer
  void _startExamTimer() {
    Future.doWhile(() async {
      if (_timeRemaining > 0 && _isExamStarted && !_isExamFinished) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _timeRemaining--;
        });
        return true;
      }
      return false;
    });
  }

  // Navigation between questions
  void _goToNextQuestion() {
    if (_currentQuestion < widget.totalQuestions) {
      setState(() {
        _currentQuestion++;
      });
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestion > 1) {
      setState(() {
        _currentQuestion--;
      });
    }
  }

  // Start exam
  void _startExam() {
    setState(() {
      _isExamStarted = true;
    });
  }

  // Submit exam
  void _submitExam() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Exam'),
        content: const Text('Are you sure you want to submit your exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isExamFinished = true;
              });
              _showExamSummary();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showExamSummary() {
    final answeredCount = _answers.where((answer) => answer.imagePath != null).length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exam Submitted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Questions: ${widget.totalQuestions}'),
            Text('Answered: $answeredCount'),
            Text('Unanswered: ${widget.totalQuestions - answeredCount}'),
            const SizedBox(height: 16),
            const Text('Your answers have been submitted successfully.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Format time display
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExamStarted) {
      return _buildExamStartScreen();
    }

    if (_isExamFinished) {
      return _buildExamFinishedScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examTitle),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _timeRemaining < 300 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatTime(_timeRemaining),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Question Progress
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question $_currentQuestion of ${widget.totalQuestions}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: List.generate(widget.totalQuestions, (index) {
                    final isAnswered = _answers[index].imagePath != null;
                    final isCurrent = index + 1 == _currentQuestion;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.blue
                            : isAnswered
                                ? Colors.green
                                : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Question Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Solve the following problem and take a photo of your solution:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getQuestionText(_currentQuestion),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_answers[_currentQuestion - 1].imagePath != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Answer:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.file(
                          File(_answers[_currentQuestion - 1].imagePath!),
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Camera Preview
          Expanded(
            flex: 3,
            child: _isCameraInitialized
                ? Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: FloatingActionButton(
                          onPressed: _switchCamera,
                          child: const Icon(Icons.switch_camera),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Initializing Camera...'),
                      ],
                    ),
                  ),
          ),

          // Navigation and Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.top: BorderSide(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _goToPreviousQuestion,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture Answer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                _currentQuestion == widget.totalQuestions
                    ? ElevatedButton.icon(
                        onPressed: _submitExam,
                        icon: const Icon(Icons.send),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _goToNextQuestion,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamStartScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examTitle),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              widget.examTitle,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildExamInfoItem('Total Questions', '${widget.totalQuestions}'),
            _buildExamInfoItem('Duration', '${widget.examDuration} minutes'),
            _buildExamInfoItem('Answer Format', 'Photo of written solutions'),
            _buildExamInfoItem('Camera Required', 'Yes'),
            const SizedBox(height: 40),
            const Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '• Solve each problem on paper\n• Use the camera to capture your solution\n• Make sure your writing is clear and readable\n• You can retake photos if needed\n• Submit before time runs out',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Start Exam',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamFinishedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Completed'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            SizedBox(height: 24),
            Text(
              'Exam Submitted Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your answers have been submitted for evaluation.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getQuestionText(int questionNumber) {
    // Sample questions - replace with your actual questions
    final questions = [
      'Solve the quadratic equation: x² + 5x + 6 = 0',
      'Find the derivative of f(x) = 3x³ - 2x² + 5x - 1',
      'Calculate the integral of ∫(2x + 3) dx',
      'Prove that the sum of angles in a triangle is 180 degrees',
      'Solve the system of equations: 2x + 3y = 7, x - y = 1',
    ];
    return questions[(questionNumber - 1) % questions.length];
  }
}

class QuestionAnswer {
  String? imagePath;
  DateTime? answeredAt;
  String? textAnswer; // For optional text answers

  QuestionAnswer({
    this.imagePath,
    this.answeredAt,
    this.textAnswer,
  });
}
import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Field and Button Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Edit Field and Button'),
        ),
        body: MyForm(),
      ),
    );flutter pub get
  }
}

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController _controller = TextEditingController();

  void _onPressed() {
    // You can handle the button press here
    String enteredText = _controller.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You entered: $enteredText')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter something',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onPressed,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
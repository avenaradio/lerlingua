import 'package:flutter/material.dart';
import '../resources/mirror.dart';
import '../resources/settings.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  _initializeApp() async {
    // Load persistent data
    await Settings().loadSettings();
    await Mirror().initDatabase();
    // Mounted check because inside of async function
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    _initializeApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Circular progress indicator
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

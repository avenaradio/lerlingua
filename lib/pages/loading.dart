import 'package:flutter/material.dart';

import '../resources/settings.dart';
import 'home.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  _initializeApp() async {
    // Loading dummy
    await Settings().loadSettings();
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

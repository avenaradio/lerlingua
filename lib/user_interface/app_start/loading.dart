import 'package:flutter/material.dart';
import '../../resources/database/mirror/mirror.dart';
import '../../resources/settings/settings.dart';
import '../../resources/settings/updater.dart';

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
    // Check for updates
    Updater.update();
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
        body: Center(child: CircularProgressIndicator()), // ThemeColorsDisplay(),
      ),
    );
  }
}

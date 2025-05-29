import 'package:feedback_gitlab/feedback_gitlab.dart';
import 'package:flutter/material.dart';
import 'package:json_theme/json_theme.dart';

import 'package:flutter/services.dart'; // For rootBundle
import 'package:lerlingua/pages/home.dart';
import 'dart:convert';

import 'package:lerlingua/pages/loading.dart';
import 'package:lerlingua/pages/read/library.dart';
import 'package:lerlingua/pages/settings/settings_translation_services.dart';

import 'feedback_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeStr = await rootBundle.loadString('assets/appainter_theme_bright.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  runApp(BetterFeedback(child: MyApp(theme: theme)));
}

class MyApp extends StatelessWidget {
  final ThemeData theme;

  const MyApp({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Named Routes',
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(),
        '/settings/translation_services': (context) => TranslationServicesList(),
        '/library': (context) => Library(),
      },
      //theme: theme,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? Container(), // Main content of the app
            FeedbackButton(), // Global Feedback button
          ],
        );
      },
    );
  }
}
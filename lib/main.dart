import 'package:feedback_gitlab/feedback_gitlab.dart';
import 'package:flutter/material.dart';
import 'package:json_theme/json_theme.dart';

import 'package:flutter/services.dart'; // For rootBundle
import 'package:lerlingua/pages/home.dart';
import 'dart:convert';

import 'package:lerlingua/pages/loading.dart';
import 'package:lerlingua/pages/settings/settings_translation_services.dart';

import 'global_variables.dart'; // For jsonDecode

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Draggable(
        feedback: FloatingActionButton.small(
          onPressed: () {},
          tooltip: 'Send Feedback',
          child: const Icon(Icons.feedback_rounded),
        ),
        childWhenDragging: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          child: const Icon(Icons.feedback_rounded),
        ),
        child: FloatingActionButton.small(
          onPressed: () {
            BetterFeedback.of(context).showAndUploadToGitLab(
              projectId: '5990',
              gitlabUrl: 'gitlab.iue.fh-kiel.de',
              apiToken: feedbackToken,
            );
          },
          tooltip: 'Send Feedback',
          child: const Icon(Icons.feedback_rounded),
        ),
      ),
      body: MaterialApp(
        title: 'Named Routes',
        initialRoute: '/',
        routes: {
          '/': (context) => Loading(),
          '/home': (context) => Home(),
          '/settings/translation_services': (context) => TranslationServicesList(),
        },
        //theme: theme,
      ),
    );
  }
}
import 'package:feedback_gitlab/feedback_gitlab.dart';
import 'package:flutter/material.dart';
import 'package:lerlingua/pages/home.dart';
import 'package:lerlingua/pages/loading.dart';
import 'package:lerlingua/pages/read/library.dart';
import 'package:lerlingua/pages/settings/settings_sync_log.dart';
import 'package:lerlingua/pages/settings/settings_translation_services.dart';
import 'package:lerlingua/theme_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final bool isDarkMode = sharedPreferences.getBool('isDarkMode') ?? false;
  runApp(BetterFeedback(child: MyApp(isDarkMode: isDarkMode)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isDarkMode});
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: isDarkMode ? ThemeFilter.dark : ThemeFilter.light,
      child: MaterialApp(
        title: 'Named Routes',
        initialRoute: '/',
        routes: {
          '/': (context) => Loading(),
          '/home': (context) => Home(),
          '/settings/translation_services': (context) => TranslationServicesList(),
          'settings/sync_log': (context) => SettingsSyncLog(),
          '/library': (context) => Library(),
        },
      ),
    );
  }
}
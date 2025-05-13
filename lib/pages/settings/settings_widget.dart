import 'package:flutter/material.dart';

import '../../resources/mirror.dart';
import '../../resources/sql_database.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton(onPressed: () {
                    SqlDatabase().deleteSqlDatabase();
                    Mirror().initDatabase();
                    }, child: const Text('Delete Datebase'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

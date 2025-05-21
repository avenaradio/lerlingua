import 'package:flutter/material.dart';
import 'package:lerlingua/pages/settings/credentials_dialog.dart';

import '../../resources/mirror.dart';
import '../../resources/sql_database.dart';
import '../../resources/sync.dart';
import '../../resources/vocab_entry.dart';
import '../loading.dart';

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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  CredentialsDialog().show(context);
                },
                child: const Text('Edit GitHub Credentials'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                  });
                },
                child: const Text('SetState'),
              ),
              ElevatedButton(
                onPressed: () {
                  SqlDatabase().deleteSqlDatabase();
                  Mirror().initDatabase();
                },
                child: const Text('Delete Datebase'),
              ),
              ElevatedButton(
                onPressed: () {
                  for (VocabEntry entry in Mirror().dbMirror) {
                    entry.boxNumber = 0;
                    Mirror().writeEntry(entry: entry);
                  }
                },
                child: const Text('Move all to first box'),
              ),
              ElevatedButton(
                onPressed: () {
                  Mirror().dbMirror.clear();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Loading()));
                },
                child: const Text('Reload app'),
              ),
              ElevatedButton(
                onPressed: () {
                  Sync().uploadJsonToGitHub(jsonString: '{"test": "test3"}', fileType: FileType.test);
                },
                child: const Text('Sync upload test'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Sync().downloadJsonFromGithub(fileType: FileType.test);
                },
                child: const Text('Sync download test'),
              ),
              Text(Sync().syncLog),
            ],
          ),
        ),
      ),
    );
  }
}

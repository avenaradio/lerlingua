import 'package:flutter/material.dart';
import 'package:lerlingua/pages/settings/credentials_dialog.dart';

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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const ListTile(
                title: Text('Synchronization', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('GitHub Credentials'),
                subtitle: const Text('Edit your GitHub credentials'),
                onTap: () {
                  CredentialsDialog().show(context);
                },
              ),
              ListTile(
                title: const Text('Log'),
                subtitle: const Text('View the synchronization log'),
                onTap: () {
                  Navigator.pushNamed(context, 'settings/sync_log');
                },
              ),
              const Divider(),
              const ListTile(
                title: Text('Translation', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Translation Services'),
                subtitle: const Text('Edit your translation services'),
                onTap: () {
                  Navigator.pushNamed(context, '/settings/translation_services');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
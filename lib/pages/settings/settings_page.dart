import 'package:flutter/material.dart';
import 'package:lerlingua/pages/settings/credentials_dialog.dart';
import '../../resources/settings.dart';
import '../updater.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              const Divider(),
              const ListTile(
                title: Text('App Updates', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Auto Update'),
                subtitle: const Text('Get app updates automatically'),
                trailing: Switch(
                    value: Settings().autoUpdate,
                    onChanged: (value) {
                      setState(() {
                        Settings().autoUpdate = value;
                      });
                    }),
                // add switch
              ),
              ListTile(
                title: Settings().updateAvailable ? const Text('Update Available') : const Text('No Update Available'),
                subtitle: Settings().updateAvailable ? const Text('Download and install the latest update') : const Text('You are up to date'),
                onTap: () {
                  Updater.update(forceUpdate: true);
                }
              ),
              const Divider(),
              const ListTile(
                title: Text('Tutorial', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Load Tutorial Book'),
                subtitle: const Text('Tap to load the manual'),
                onTap: () {
                  Settings().currentBook = null;
                  Navigator.pushNamed(context, '/home');
                },
                // add switch
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
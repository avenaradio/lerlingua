import 'package:flutter/material.dart';
import 'package:lerlingua/user_interface/settings/credentials_dialog.dart';
import '../../resources/settings/settings.dart';
import '../../resources/settings/updater.dart';

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
                title: Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark mode'),
                trailing: Switch(
                    value: Settings().isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        Settings().isDarkMode = value;
                        setState(() {});
                        // Show alert dialog to restart the app
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Theme changed'),
                            content: const Text('You need to restart the app to apply the theme.'),
                            actions: [
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      });
                    }),
                // add switch
              ),
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
                title: Text('Learning', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Set number of cards to add to first box at once'),
                subtitle: Text('Actual: ${Settings().stackSize}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Set number of cards to add to first box'),
                      content: TextField(
                        controller: TextEditingController(text: Settings().stackSize.toString()),
                        onChanged: (value) {
                          int newSize = int.tryParse(value) ?? Settings().stackSize;
                          Settings().stackSize = newSize;
                          setState(() {});
                        },
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text('Save'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),
              const ListTile(
                title: Text('Reader', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: Text('Font Size: ${Settings().fontSize}'),
                subtitle: const Text('If you change this, you loose your reading positions.'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Set font size'),
                      content: TextField(
                        controller: TextEditingController(text: Settings().fontSize.toString()),
                        onChanged: (value) {
                          int newSize = int.tryParse(value) ?? Settings().fontSize;
                          newSize < 10 ? newSize = 10 : newSize = newSize;
                          newSize > 30 ? newSize = 30 : newSize = newSize;
                          Settings().fontSize = newSize;
                          setState(() {});
                        },
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text('Save'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
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
                title: Text('Feedback Button', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Show Feedback Button'),
                subtitle: const Text('Feedback button to submit screenshots'),
                trailing: Switch(
                    value: Settings().showFeedbackButton,
                    onChanged: (value) {
                      setState(() {
                        Settings().showFeedbackButton = value;
                        setState(() {});
                      });
                    }),
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
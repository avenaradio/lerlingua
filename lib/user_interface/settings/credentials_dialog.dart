import 'package:flutter/material.dart';
import '../../resources/settings/settings.dart';

class CredentialsDialog {
  void show(BuildContext context) {
    final TextEditingController tokenController = TextEditingController();
    final TextEditingController repoOwnerController = TextEditingController(text: Settings().repoOwner);
    final TextEditingController repoNameController = TextEditingController(text: Settings().repoName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter GitHub Credentials'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: tokenController,
                  decoration: const InputDecoration(labelText: 'GitHub Token (leave empty to keep current token)'),
                  obscureText: true,
                ),
                TextField(
                  controller: repoOwnerController,
                  decoration: const InputDecoration(labelText: 'Repository Owner'),
                ),
                TextField(
                  controller: repoNameController,
                  decoration: const InputDecoration(labelText: 'Repository Name'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the credentials
                String token = tokenController.text;
                String repoOwner = repoOwnerController.text;
                String repoName = repoNameController.text;

                // Call the saveCredentials function
                Settings().saveCredentials(token: token, repoOwner: repoOwner, repoName: repoName);

                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
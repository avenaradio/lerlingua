import 'package:flutter/material.dart';
import '../../resources/settings/settings.dart';

Future<String?> editLanguageDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    // Text field to set book language
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Set language'),
      content: TextField(
        controller: TextEditingController(text: Settings().currentBook?.languageB ?? ''),
        onChanged: (value) {
          Settings().currentBook?.languageB = value;
          Settings().addOrUpdateBook(Settings().currentBook!);
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, 'Cancel'),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () => Navigator.pop(context, 'Save'),
        ),
      ],
    ),
  );
}
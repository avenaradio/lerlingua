import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class FileHandler {
  /// Lets user pick an epub file and copies it to the app's document directory
  static Future<File?> importEpubFile() async {
    // Use file_picker to allow the user to select an EPUB file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'], // Restrict to EPUB files
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      // Get the selected EPUB file
      final File file = File(result.files.first.path!);
      // Get the app's document directory
      final Directory directory = await getAppDirectory();
      // Define the target directory for books
      final Directory booksDirectory = Directory('${directory.path}/books');
      // Create the books directory if it doesn't exist
      if (!await booksDirectory.exists()) {
        await booksDirectory.create(recursive: true);
      }
      // Define the new file path
      String newFilePath = '${booksDirectory.path}/${file.path.split('/').last}';
      final String fileExtension = file.path.split('.').last;
      newFilePath = newFilePath.replaceAll('.$fileExtension', '${DateTime.now().millisecondsSinceEpoch}.$fileExtension'); // Add timestamp to file name
      // Copy the file to the new location with a timestamp
      return await file.copy(newFilePath);
    }
    // Return null if no file was selected
    return null;
  }

  /// Returns the app's document directory
  static Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Saves a file to the app's document directory
  static Future<void> saveBookFile(String fileName, String content) async {
    final directory = await getAppDirectory();
    final file = File('${directory.path}/books/$fileName'); // Save to the "books" directory
    await file.writeAsString(content);
  }

  /// Reads a file from the app's document directory
  static Future<String?> readBookFile(String fileName) async {
    try {
      final directory = await getAppDirectory();
      final file = File('${directory.path}/books/$fileName');
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      if(kDebugMode) print(e);
      return null;
    }
  }

  /// Deletes a file from the app's document directory
  static Future<int> deleteFile({required String filePath}) async {
    final file = File(filePath);
    try {
      await file.delete();
      return 1;
    } catch (e) {
      if(kDebugMode) print(e);
      return 0;
    }
  }
}

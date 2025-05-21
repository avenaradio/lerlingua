import 'dart:convert';
import 'package:http/http.dart' as http;

enum FileType { test, cards, settings }

class Sync {
  String syncLog = 'Sync Log:\n';
  String token = '';
  String repoOwner = '';
  String repoName = '';
  final String filePath = 'lerlingua.json'; // Path in the repo

  // Private constructor
  Sync._internal();

  // Static instance of the class
  static final Sync _instance = Sync._internal();

  // Factory constructor to always return the same instance
  factory Sync() {
    return _instance;
  }

  Sync credentials({required String token, required String repoOwner, required String repoName}) {
    this.token = token;
    this.repoOwner = repoOwner;
    this.repoName = repoName;
    return this;
  }

  String url({required FileType fileType}) {
    switch (fileType) {
      case FileType.test:
        return 'https://api.github.com/repos/$repoOwner/$repoName/contents/test.json';
      case FileType.cards:
        return 'https://api.github.com/repos/$repoOwner/$repoName/contents/cards.json';
      case FileType.settings:
        return 'https://api.github.com/repos/$repoOwner/$repoName/contents/settings.json';
    }
  }
  void clearLog() => syncLog = 'Sync Log:\n';

  /// Converts an upload response to a string
  String stringFromUploadResponse({required int uploadResponse}) {
    switch (uploadResponse) {
      case -2:
        return 'Repo not found but token accepted';
      case -1:
        return 'Bad credentials';
      case 0:
        return 'Unknown error';
      default:
        return 'Success';
    }
  }

  /// Uploads a json string to GitHub <br>
  /// Returns 1 if file created, 2 if file updated, -1 if bad credentials, -2 if repo not found but token accepted, 0 if error
  /// - Tested
  Future<int> uploadJsonToGitHub({required String jsonString, required FileType fileType}) async {
    int result = 0;
    // First, check if the file exists to get its sha
    final responseGet = await http.get(
      Uri.parse(url(fileType: fileType)),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    String? sha;
    if (responseGet.statusCode == 200) {
      // File exists, get the sha
      final Map<String, dynamic> fileData = jsonDecode(responseGet.body);
      sha = fileData['sha'];
      result = 2;
      syncLog += ('File already exists, will be updated...\n');
    } else if (responseGet.statusCode == 404) {
      // File does not exist, create it
      result = 1;
      syncLog += ('File does not exist, will be created...\n');
    } else if (responseGet.statusCode == 401) {
      // Bad credentials
      syncLog += ('Bad credentials: ${responseGet.body}\n\n');
      return -1;
    } else {
      syncLog += ('Failed to check if file exists: ${responseGet.body}\n\n');
      return 0;
    }
    // Prepare the request body
    final Map<String, dynamic> body = {
      'message': 'Lerlingua Sync',
      'content': base64Encode(utf8.encode(jsonString)),
    };
    // Include sha if the file exists
    if (sha != null) {
      body['sha'] = sha;
    }
    // Make the PUT request to upload the file
    final responsePut = await http.put(
      Uri.parse(url(fileType: fileType)),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
      body: jsonEncode(body),
    );
    if (responsePut.statusCode == 201 || responsePut.statusCode == 200) {
      syncLog += ('File uploaded successfully!\n');
      return result;
    } else if (responsePut.statusCode == 404) {
      if (result == 1) {
        // Repo not found
        syncLog += ('Repo not found.\n');
        syncLog += ('Failed to upload file: ${responsePut.body}\n\n');
        return -2;
      }
      return 0;
    } else {
      syncLog += ('Failed to upload file: ${responsePut.body}\n\n');
      return 0;
    }
  }

  /// Downloads JSON file from GitHub <br>
  /// Returns null if error occurs, '&#91;&#93;' if file not found
  /// - Tested
  Future<String?> downloadJsonFromGithub({required FileType fileType}) async {
    final response = await http.get(
      Uri.parse(url(fileType: fileType)),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      String content = jsonResponse['content'];
      content = content.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), ''); // Remove invalid characters
      String decodedContent = '';
      try {
        decodedContent = utf8.decode(base64Decode(content));
      } catch (e) {
        syncLog += ('Failed to decode file content: $e\n\n');
        return null;
      }
      syncLog += ('File downloaded successfully!\n');
      syncLog += ('Raw file content: $content\n\n');
      syncLog += ('Decoded file content: $decodedContent\n\n');
      return decodedContent;
    } else if (response.statusCode == 404) {
      syncLog += ('File not found: ${response.body}\n\n');
      return '[]';
    }
    else {
      syncLog += ('Failed to download file: ${response.body}\n\n');
      return null;
    }
  }

  /// Deletes a file from GitHub repository via GitHub API. <br>
  /// Returns 1 if the file was deleted successfully, 2 if the file was not found, and 0 otherwise.
  /// - Tested
  Future<int> deleteFileOnGithub({required FileType fileType}) async {
    try {
      // Step 1: Get the file SHA
      final getResponse = await http.get(
        Uri.parse(url(fileType: fileType)),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      if (getResponse.statusCode == 200) {
        final fileData = jsonDecode(getResponse.body);
        final String sha = fileData['sha'];
        // Step 2: Send DELETE request to delete the file with SHA
        final deleteResponse = await http.delete(
          Uri.parse(url(fileType: fileType)),
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'message': 'Deleting file',
            'sha': sha,
          }),
        );
        if (deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204) {
          syncLog += 'File deleted successfully!\n';
          return 1;
        } else {
          syncLog += 'Failed to delete file: ${deleteResponse.statusCode} ${deleteResponse.body}\n';
          return 0;
        }
      } else if (getResponse.statusCode == 404) {
        syncLog += 'File not found: ${getResponse.body}\n';
        return 2;
      } else {
        syncLog += 'Failed to get file info: ${getResponse.statusCode} ${getResponse.body}\n';
        return 0;
      }
    } catch (e) {
      syncLog += 'Error during file delete: $e\n';
      return 0;
    }
  }
}
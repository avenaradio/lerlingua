import 'dart:convert';
import 'package:http/http.dart' as http;

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

  String get url => 'https://api.github.com/repos/$repoOwner/$repoName/contents/$filePath';

  /// Function to upload map to GitHub
  Future<bool> uploadJsonToGitHub(String jsonString) async {
    // First, check if the file exists to get its sha
    final responseGet = await http.get(
      Uri.parse(url),
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
      Uri.parse(url),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
      body: jsonEncode(body),
    );
    if (responsePut.statusCode == 201 || responsePut.statusCode == 200) {
      syncLog += ('File uploaded successfully!');
      return true;
    } else {
      syncLog += ('Failed to upload file: ${responsePut.body}\n\n');
      return false;
    }
  }

  /// Function to download JSON file from GitHub
  Future<String?> downloadJsonFromGithub() async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      String content = jsonResponse['content'];
      /*
      // Cut off if length is not a multiple of 4
      int contentModulo = content.length % 4;
      if (contentModulo != 0) {
        content = content.substring(0, content.length - contentModulo);
      }*/
      final String decodedContent = utf8.decode(base64Decode(content));
      syncLog += ('File downloaded successfully!\n');
      syncLog += ('File content: $decodedContent\n\n');
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

  /// Deletes a file from GitHub repository via GitHub API.
  /// Returns 1 if the file was deleted successfully, 2 if the file was not found, and 0 otherwise.
  Future<int> deleteFileOnGithub() async {
    try {
      // Step 1: Get the file SHA
      final getResponse = await http.get(
        Uri.parse(url),
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
          Uri.parse(url),
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
        return 1;
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

import 'dart:convert';
import 'package:http/http.dart' as http;

class Github {

  // Private constructor
  Github._internal();

  // Static instance of the class
  static final Github _instance = Github._internal();

  // Factory constructor to always return the same instance
  factory Github() {
    return _instance;
  }

  /// Function to test GitHub API

  /// Function to upload map to github
  Future<void> uploadJsonToGitHub(String jsonString) async {
    final String token = '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';
    final String repoOwner = 'avenaradio';
    final String repoName = 'lerlingua_sync';
    final String filePath = 'lerlingua.json'; // Path in the repo

    final String url = 'https://api.github.com/repos/$repoOwner/$repoName/contents/$filePath';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
      body: jsonEncode({
        'message': 'Upload JSON file',
        'content': base64Encode(utf8.encode(jsonString)),
      }),
    );

    if (response.statusCode == 201) {
      print('File uploaded successfully!');
    } else {
      print('Failed to upload file: ${response.body}');
    }
  }
}
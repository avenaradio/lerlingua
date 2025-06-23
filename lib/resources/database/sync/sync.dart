import 'dart:convert';
import 'package:http/http.dart' as http;

enum FileType { test, cards, settings }

class Sync {
  String syncLog = 'Sync Log:\n';
  String token = '';
  String repoOwner = '';
  String repoName = '';

  // Private constructor
  Sync._internal();

  // Static instance of the class
  static final Sync _instance = Sync._internal();

  // Factory constructor to always return the same instance
  factory Sync() {
    return _instance;
  }

  /// Sets credentials for the sync
  Sync credentials({
    required String token,
    required String repoOwner,
    required String repoName,
  }) {
    this.token = token;
    this.repoOwner = repoOwner;
    this.repoName = repoName;
    return this;
  }

  /// Returns the URL for the given file usage type
  String url({required FileType fileType}) {
    switch (fileType) {
      case FileType.test:
        return 'https://api.github.com/repos/$repoOwner/$repoName/contents/test.csv';
      case FileType.cards:
        return 'https://api.github.com/repos/$repoOwner/$repoName/contents/cards.csv';
      case FileType.settings:
        return 'https://api.github.com/repos/$repoOwner/$repoName/contents/settings.csv';
    }
  }

  void clearLog() => syncLog = 'Sync Log:\n';

  /// Converts a response to a string <br>
  /// Returns a [String]
  /// - -3 Error while decoding
  /// - -2 Repo not found but token accepted
  /// - -1 Bad credentials
  /// - 0 Unknown error
  /// - 1 Success
  /// - 2 File updated
  /// - else Unknown response
  /// <br> <br>
  /// - Tested
  String stringFromResponse({required int response}) {
    switch (response) {
      case -3:
        return 'Error while decoding';
      case -2:
        return 'Repo not found but token accepted';
      case -1:
        return 'Bad credentials';
      case 0:
        return 'Unknown error';
      case 1:
        return 'Success';
      case 2:
        return 'File updated';
      default:
        return 'Unknown response';
    }
  }

  /// Uploads a csv string to GitHub <br>
  /// Returns [int] status:
  /// - -2 Repo not found but token accepted
  /// - -1 Bad credentials
  /// - 0 Unknown error
  /// - 1 File created
  /// - 2 File updated
  /// - Tested
  Future<int> uploadCsvToGitHub({
    required String csvString,
    required FileType fileType,
  }) async {
    int result = 0;
    // First, check if the file exists to get its sha
    String? sha;
    try {
      final responseGet = await http.get(
        Uri.parse(url(fileType: fileType)),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );
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
    } catch (e) {
      syncLog += 'Unknown error: $e\n';
      return 0;
    }
    // Prepare the request body
    final Map<String, dynamic> body = {
      'message': 'Lerlingua Sync',
      'content': base64Encode(utf8.encode(csvString)),
    };
    // Include sha if the file exists
    if (sha != null) {
      body['sha'] = sha;
    }
    // Make the PUT request to upload the file
    try {
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
    } catch (e) {
      syncLog += 'Unknown error: $e\n';
      return 0;
    }
  }

  /// Downloads csv file from GitHub <br>
  /// Returns [Map&lt;int, String?&gt;] where [int] is the status and [String] is the content <br>
  /// - -3 Error while decoding
  /// - -2 Repo / file not found but token accepted
  /// - -1 Bad credentials
  /// - 0 Unknown error
  /// - 1 Success
  /// <br> <br>
  /// - Tested
  Future<Map<int, String?>> downloadCsvFromGithub({required FileType fileType}) async {
    try {
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
        content = content.replaceAll(
          RegExp(r'[^A-Za-z0-9+/=]'),
          '',
        ); // Remove invalid characters
        String decodedContent = '';
        try {
          decodedContent = utf8.decode(base64Decode(content));
        } catch (e) {
          syncLog += ('Failed to decode base64 file content: $e\n\n');
          return {-3: null};
        }
        syncLog += ('File downloaded successfully!\n');
        //syncLog += ('Raw file content: $content\n\n');
        //syncLog += ('Decoded file content: $decodedContent\n\n');
        return {1: decodedContent};
      } else if (response.statusCode == 404) {
        syncLog += ('File not found: ${response.body}\n\n');
        return {-2: null};
      } else if (response.statusCode == 401) {
        syncLog += ('Bad credentials: ${response.body}\n\n');
        return {-1: null};
      } else {
        syncLog += ('Failed to download file: ${response.body}\n\n');
        return {0: null};
      }
    } catch (e) {
      syncLog += 'Unknown error: $e\n';
      return {0: null};
    }
  }

  /// Deletes a file from GitHub repository via GitHub API. <br>
  /// Returns [int] status:
  /// - 0 Unknown error
  /// - 1 Deleted successfully
  /// - 2 Repo / file not found
  /// <br> <br>
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
          body: jsonEncode({'message': 'Deleting file', 'sha': sha}),
        );
        if (deleteResponse.statusCode == 200 ||
            deleteResponse.statusCode == 204) {
          syncLog += 'File deleted successfully!\n';
          return 1;
        } else {
          syncLog +=
              'Failed to delete file: ${deleteResponse.statusCode} ${deleteResponse.body}\n';
          return 0;
        }
      } else if (getResponse.statusCode == 404) {
        syncLog += 'File not found: ${getResponse.body}\n';
        return 2;
      } else {
        syncLog +=
            'Failed to get file info: ${getResponse.statusCode} ${getResponse.body}\n';
        return 0;
      }
    } catch (e) {
      syncLog += 'Unknown error: $e\n';
      return 0;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/global_variables/global_variables.dart';
import 'package:lerlingua/resources/database/sync/sync.dart';

void main() {
  test('token variable from enviroment should not be empty', () {
    expect(syncTestToken, isNot(''));
  });
  test('credentials should be set', () {
    Sync syncSingleton = Sync().credentials(token: 'test_token', repoOwner: 'test_owner', repoName: 'test_repo');
    expect(syncSingleton.token, 'test_token');
    expect(syncSingleton.repoOwner, 'test_owner');
    expect(syncSingleton.repoName, 'test_repo');
  });
  group('deleteFileOnGithub Tests', () {
    test('deleteFileOnGithub should return 1 if file exists', () async {
      Sync().clearLog();
      Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test');
      await Sync().uploadCsvToGitHub(csvString: 'Name,Description\nTest,Test', fileType: FileType.test);
      int result = await Sync().deleteFileOnGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndeleteFileOnGithub should return 1 if file exists');
        print(Sync().syncLog);
      }
      expect(result, 1);
    });
    test('deleteFileOnGithub should return 2 if file does not exist', () async {
      Sync().clearLog();
      Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test');
      await Sync().deleteFileOnGithub(fileType: FileType.test);
      // Repo should be empty at this point
      int result = await Sync().deleteFileOnGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndeleteFileOnGithub should return 2 if file does not exist');
        print(Sync().syncLog);
      }
      expect(result, 2);
    });
    test('deleteFileOnGithub wrong token should return 0', () async {
      Sync().clearLog();
      int result = await Sync().credentials(token: 'wrong_token', repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndeleteFileOnGithub wrong token should return 0');
        print(Sync().syncLog);
      }
      expect(result, 0);
    });
    test('deleteFileOnGithub non-existant repo should return 2', () async {
      Sync().clearLog();
      int result = await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test_non_existant_repo').deleteFileOnGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndeleteFileOnGithub non-existant repo should return 2');
        print(Sync().syncLog);
      }
      expect(result, 2);
    });
  });
  group('downloadCsvFromGithub Tests', () {
    test('downloadCsvFromGithub if file / repo not found should return -2', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      Map<int, String?> map = await Sync().downloadCsvFromGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndownloadCsvFromGithub if file / repo not found should return -2');
        print(Sync().syncLog);
      }
      expect(map, {-2: null});
    });
    test('downloadCsvFromGithub if wrong token should return -1', () async {
      Sync().clearLog();
      Map<int, String?> map = await Sync().credentials(token: 'wrong_token', repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').downloadCsvFromGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndownloadCsvFromGithub if wrong token should return -1');
        print(Sync().syncLog);
      }
      expect(map, {-1: null});
    });
    test('downloadCsvFromGithub if file exists should return 1 and file content', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      await Sync().uploadCsvToGitHub(csvString: 'Name,Description\nTest,Test', fileType: FileType.test);
      Map<int, String?> map = await Sync().downloadCsvFromGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndownloadCsvFromGithub if file exists should return 1 and file content');
        print(Sync().syncLog);
      }
      expect(map, {1: 'Name,Description\nTest,Test'});
    });
    test('downloadCsvFromGithub if file is empty should return 1 and ""', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      await Sync().uploadCsvToGitHub(csvString: '', fileType: FileType.test); // Upload empty file
      Map<int, String?> map = await Sync().downloadCsvFromGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndownloadCsvFromGithub if file is empty should return 1 and null');
        print(Sync().syncLog);
      }
      expect(map, {1: ''});
    });
  });
  group('uploadCsvToGitHub Tests', () {
    test('uploadCsvToGitHub if wrong token should return -1', () async {
      Sync().clearLog();
      await Sync().credentials(token: 'wrong_token', repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      int result = await Sync().uploadCsvToGitHub(csvString: 'Name,Description\nTest,Test', fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\nuploadCsvToGitHub if wrong token should return -1');
        print(Sync().syncLog);
      }
      expect(result, -1);
    });
    test('uploadCsvToGitHub if correct token and wrong repo should return -2', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'non_existant', repoName: 'non_existant').deleteFileOnGithub(fileType: FileType.test);
      int result = await Sync().uploadCsvToGitHub(csvString: 'Name,Description\nTest,Test', fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\nuploadCsvToGitHub if correct token and wrong repo should return -2');
        print(Sync().syncLog);
      }
      expect(result, -2);
    });
    test('uploadCsvToGitHub if created should return 1', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      int result = await Sync().uploadCsvToGitHub(csvString: 'Name,Description\nTest,Test', fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\nuploadCsvToGitHub if created should return 1');
        print(Sync().syncLog);
      }
      expect(result, 1);
      expect(await Sync().downloadCsvFromGithub(fileType: FileType.test), {1: 'Name,Description\nTest,Test'});
    });
    test('uploadCsvToGitHub if updated should return 2', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      await Sync().uploadCsvToGitHub(csvString: 'Name,Description\nTest,Test1', fileType: FileType.test);
      int result = await Sync().uploadCsvToGitHub(csvString: 'Name,Description\nTest,Test2', fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\nuploadCsvToGitHub if updated should return 2');
        print(Sync().syncLog);
      }
      expect(result, 2);
      expect(await Sync().downloadCsvFromGithub(fileType: FileType.test), {1: 'Name,Description\nTest,Test2'});
    });
  });
  test('stringFromResponse Test', () async {
    expect(Sync().stringFromResponse(response: -3), 'Error while decoding');
    expect(Sync().stringFromResponse(response: -2), 'Repo not found but token accepted');
    expect(Sync().stringFromResponse(response: -1), 'Bad credentials');
    expect(Sync().stringFromResponse(response: 0), 'Unknown error');
    expect(Sync().stringFromResponse(response: 1), 'Success');
    expect(Sync().stringFromResponse(response: 2), 'File updated');
    expect(Sync().stringFromResponse(response: 3), 'Unknown response');
  });
}
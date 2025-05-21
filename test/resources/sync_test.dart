import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/global_variables.dart';
import 'package:lerlingua/resources/sync.dart';

void main() {
  group('deleteFileOnGithub Tests', () {
    test('token variable from enviroment should not be empty', () {
      expect(syncTestToken, isNot(''));
    });
    test('credentials should be set', () {
      Sync syncSingleton = Sync().credentials(token: 'test_token', repoOwner: 'test_owner', repoName: 'test_repo');
      expect(syncSingleton.token, 'test_token');
      expect(syncSingleton.repoOwner, 'test_owner');
      expect(syncSingleton.repoName, 'test_repo');
    });
    test('deleteFileOnGithub should return 1 if file exists', () async {
      Sync().clearLog();
      Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test');
      await Sync().uploadJsonToGitHub(jsonString: '[{"test":"test"}]', fileType: FileType.test);
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
  group('downloadJsonFromGithub Tests', () {
    test('downloadJsonFromGithub if file does not exist should return "[]"', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      String? jsonString = await Sync().downloadJsonFromGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndownloadJsonFromGithub if file does not exist should return "[]"');
        print(Sync().syncLog);
      }
      expect(jsonString, '[]');
    });
    test('downloadJsonFromGithub if file exists should return file content', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      await Sync().uploadJsonToGitHub(jsonString: '[{"test":"test"}]', fileType: FileType.test);
      String? jsonString = await Sync().downloadJsonFromGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndownloadJsonFromGithub if file exists should return file content');
        print(Sync().syncLog);
      }
      expect(jsonString, '[{"test":"test"}]');
    });
    test('downloadJsonFromGithub if error should return null', () async {
      Sync().clearLog();
      await Sync().credentials(token: 'wrong_token', repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      String? jsonString = await Sync().downloadJsonFromGithub(fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\ndownloadJsonFromGithub if error should return null');
        print(Sync().syncLog);
      }
      expect(jsonString, null);
    });
  });
  group('uploadJsonToGitHub Tests', () {
    test('uploadJsonToGitHub if wrong token should return -1', () async {
      Sync().clearLog();
      await Sync().credentials(token: 'wrong_token', repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      int result = await Sync().uploadJsonToGitHub(jsonString: '[{"test":"test"}]', fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\nuploadJsonToGitHub if wrong token should return -1');
        print(Sync().syncLog);
      }
      expect(result, -1);
    });
    test('uploadJsonToGitHub if correct token and wrong repo should return -2', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'non_existant', repoName: 'non_existant').deleteFileOnGithub(fileType: FileType.test);
      int result = await Sync().uploadJsonToGitHub(jsonString: '[{"test":"test"}]', fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\nuploadJsonToGitHub if correct token and wrong repo should return -2');
        print(Sync().syncLog);
      }
      expect(result, -2);
    });
    test('uploadJsonToGitHub if created should return 1', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      int result = await Sync().uploadJsonToGitHub(jsonString: '[{"test":"test"}]', fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\nuploadJsonToGitHub if created should return 1');
        print(Sync().syncLog);
      }
      expect(result, 1);
      expect(await Sync().downloadJsonFromGithub(fileType: FileType.test), '[{"test":"test"}]');
    });
    test('uploadJsonToGitHub if updated should return 2', () async {
      Sync().clearLog();
      await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub(fileType: FileType.test);
      await Sync().uploadJsonToGitHub(jsonString: '[{"test":"test1"}]', fileType: FileType.test);
      int result = await Sync().uploadJsonToGitHub(jsonString: '[{"test":"test2"}]', fileType: FileType.test);
      // Assert
      if (kDebugMode) {
        // print test name
        print('\nuploadJsonToGitHub if updated should return 2');
        print(Sync().syncLog);
      }
      expect(result, 2);
      expect(await Sync().downloadJsonFromGithub(fileType: FileType.test), '[{"test":"test2"}]');
    });
  });
}
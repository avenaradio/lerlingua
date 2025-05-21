import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/global_variables.dart';
import 'package:lerlingua/resources/sync.dart';

void main() {
  group('deleteFileOnGithub Tests', () {
    test('token variable from enviroment', () {
      expect(syncTestToken, isNot(''));
    });
    test('credentials', () {
      Sync syncSingleton = Sync().credentials(token: 'test_token', repoOwner: 'test_owner', repoName: 'test_repo');
      expect(syncSingleton.token, 'test_token');
      expect(syncSingleton.repoOwner, 'test_owner');
      expect(syncSingleton.repoName, 'test_repo');
    });
    test('deleteFileOnGithub', () async {
      int result = await Sync().credentials(token: syncTestToken, repoOwner: 'avenaradio', repoName: 'lerlingua_sync_test').deleteFileOnGithub();
      if (kDebugMode) {
        print(Sync().syncLog);
      }
      expect(result, greaterThan(0));
    });
  });
}
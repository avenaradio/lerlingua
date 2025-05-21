import 'package:lerlingua/resources/settings.dart';
import 'package:lerlingua/resources/sql_database.dart';
import 'package:lerlingua/resources/sync.dart';
import 'package:lerlingua/resources/sync_utils_extension.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

import 'mirror.dart';

extension MirrorSync on Mirror {
  /// Syncs the database with GitHub <br>
  /// Don't forget to set state after sync <br>
  /// Returns [String]
  /// - Bad credentials
  /// - Synchronization successful
  /// - Or specific error message
  Future<String> sync() async {
    Sync().clearLog();
    // Test credentials
    Sync().syncLog += ('Testing credentials...\n');
    int credentialsStatus = await Sync().credentials(token: Settings().token, repoOwner: Settings().repoOwner, repoName: Settings().repoName).uploadJsonToGitHub(jsonString: '[{"test":"credentials_test"}]', fileType: FileType.test);
    switch (credentialsStatus) {
      case 2:
      case 1:
        break;
      case -1:
      case -2:
        return 'Bad credentials';
      default:
        return 'Unable to test credentials: ${Sync().stringFromResponse(response: credentialsStatus)}, see synchronization log in settings for more info.';
    }
    Sync().syncLog += ('Credentials tested successfully!\n');
    List<VocabEntry> entriesFromMirror = Mirror().dbMirror;
    // Download entries from GitHub
    Sync().syncLog += ('Trying to download cards from GitHub...\n');
    Map<int, String?> map = await Sync().downloadJsonFromGithub(fileType: FileType.cards);
    int downloadStatus = map.keys.first;
    String? jsonString = map.values.first;
    if (jsonString == null) {
      Sync().syncLog += ('Failed to download cards from GitHub...\n');
      switch (downloadStatus) {
        case -2: // Repo / file not found but token accepted
        case 1: // Success
          break;
        default:
          return 'Unable to download cards from GitHub: ${Sync().stringFromResponse(response: downloadStatus)}, see synchronization log in settings for more info.';
      }
    }
    // Will continue here if success or file not found
    List<VocabEntry>? entriesFromSync = Sync().vocabEntriesFromJson(jsonString);
    if(entriesFromSync == null) return 'File on server corrupted, see synchronization log in settings for more info.';
    List<VocabEntry> entriesMerged = Sync().mergeLists(listA: entriesFromMirror, listB: entriesFromSync);
      // Override mirror
      Sync().syncLog += 'Overriding mirror...\n';
      dbMirror = entriesMerged;
      // Override SQL database
      Sync().syncLog += 'Overriding SQL database...\n';
      SqlDatabase().overrideAllEntries(entriesMerged);
      // Upload entries to GitHub
      Sync().syncLog += 'Uploading merged cards to GitHub...\n';
      final String jsonStringForUpload = Sync().vocabEntriesToJson(entriesMerged);
      int uploadStatus = await Sync().uploadJsonToGitHub(jsonString: jsonStringForUpload, fileType: FileType.cards);
      switch (uploadStatus) {
        case 2: // File updated
        case 1: // File created
          break;
        default: // Error while uploading
          return 'Merged cards, but unable to upload to GitHub: ${Sync().stringFromResponse(response: uploadStatus)}, see synchronization log in settings for more info.';
      }
      Sync().syncLog += 'Synchronization done.\n';
    return 'Synchronization successful';
  }
}
import 'package:lerlingua/resources/settings/settings.dart';
import 'package:lerlingua/resources/database/sqlite/sqlite_database.dart';
import 'package:lerlingua/resources/database/sync/sync.dart';
import 'package:lerlingua/resources/database/sync/sync_utils_extension.dart';
import 'package:lerlingua/resources/database/mirror/vocab_card.dart';

import '../../../general/tuple.dart';
import 'mirror.dart';

extension MirrorSync on Mirror {
  /// Syncs the database with GitHub <br>
  /// Don't forget to set state after sync <br>
  /// Returns [String]
  /// - Bad credentials
  /// - Synchronization successful
  /// - Or specific error message
  /// <br> <br>
  /// - Needs integration test
  Future<String> sync() async {
    Sync().clearLog();
    // Test credentials
    Sync().syncLog += ('Testing credentials...\n');
    int credentialsStatus = await Sync().credentials(token: Settings().token, repoOwner: Settings().repoOwner, repoName: Settings().repoName).uploadCsvToGitHub(csvString: 'Name,Description\nTest,Test', fileType: FileType.test);
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
    List<VocabCard> cardsFromMirror = Mirror().dbMirror;
    // Download cards from GitHub
    Sync().syncLog += ('Trying to download cards from GitHub...\n');
    Map<int, String?> map = await Sync().downloadCsvFromGithub(fileType: FileType.cards);
    int downloadStatus = map.keys.first;
    String? csvString = map.values.first;
    if (csvString == null) {
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
    Tuple3<int, String, List<VocabCard>>? tupleFromSync = Sync().vocabCardsFromCsv(csvString);
    Settings().addDeletedCards(tupleFromSync?.second ?? ''); // Add deleted cards to settings
    List<VocabCard>? cardsFromSync = tupleFromSync?.third;
    if(cardsFromSync == null) return 'File on server corrupted, see synchronization log in settings for more info.';
    List<VocabCard> cardsMerged = Sync().mergeLists(listA: cardsFromMirror, listB: cardsFromSync); // Merge mirror and downloaded cards
    // Remove deleted cards from cardsMerged
    int mergedCardsCount = cardsMerged.length;
    cardsMerged.removeWhere((card) => Settings().deletedCards.contains(card.vocabKey));
    Sync().syncLog += 'Removed ${mergedCardsCount - cardsMerged.length} deleted cards from merged cards.\n';
      // Override mirror
      Sync().syncLog += 'Overriding mirror...\n';
      dbMirror = cardsMerged;
      // Override SQL database
      Sync().syncLog += 'Overriding SQL database...\n';
      SqlDatabase().overrideAllCards(cardsMerged);
      // Clear undo list
      Mirror().clearUndo();
      // Upload cards and deleted cards string to GitHub
      Sync().syncLog += 'Uploading merged cards to GitHub...\n';
      final String csvStringForUpload = Sync().vocabCardsToCsv(cards: cardsMerged, deletedCards: Settings().deletedCardsString);
      int uploadStatus = await Sync().uploadCsvToGitHub(csvString: csvStringForUpload, fileType: FileType.cards);
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
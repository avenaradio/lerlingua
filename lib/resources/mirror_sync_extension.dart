import 'package:flutter/foundation.dart';
import 'package:lerlingua/resources/sql_database.dart';
import 'package:lerlingua/resources/sync.dart';
import 'package:lerlingua/resources/sync_utils_extension.dart';
import 'package:lerlingua/resources/vocab_entry.dart';

import 'mirror.dart';

extension MirrorSync on Mirror {
  /// Syncs the database with GitHub
  /// Don't forget to set state after sync
  Future<bool> sync() async {
    List<VocabEntry> entriesFromMirror = Mirror().dbMirror;
    List<VocabEntry>? entriesFromSync = await Sync().downloadEntries();
    // If null -> error
    if(entriesFromSync == null) return false;
    List<VocabEntry> entriesMerged = Sync().mergeLists(listA: entriesFromMirror, listB: entriesFromSync);
    // Ovverride mirror
    Mirror().dbMirror = entriesMerged;
    // Override SQL database
    SqlDatabase().overrideAllEntries(entriesMerged);
    // Upload entries to GitHub
    await Sync().uploadEntries(entriesMerged);
    if(kDebugMode) {
      print('entriesMerged: $entriesMerged');
    }
    return true;
  }


}
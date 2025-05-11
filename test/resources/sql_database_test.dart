import 'package:flutter_test/flutter_test.dart';
import 'package:lerlingua/resources/sql_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future main() async {
  // Set directory to in-memory
  SqlDatabase().dbDirectory = inMemoryDatabasePath;
  // load db
  await SqlDatabase().loadSqlDatabase();

  // Setup sqflite_common_ffi for flutter test
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  });

  group('SqlDatabase query Tests', () {
    test('Load SQL Database and Create Table', () async {

      // Check if the table 'vocab' exists
      final List<Map<String, dynamic>> result = await SqlDatabase().db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='vocab';");

      // Verify that the table was created
      expect(result.isNotEmpty, true);
      expect(result[0]['name'], 'vocab');
    });

    test('Fill with dummy data', () async {

    });

    tearDown(() async {
      // Close the database after each test
      await SqlDatabase().db.close();
    });
  });
}
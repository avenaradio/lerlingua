import 'package:shared_preferences/shared_preferences.dart';

// Steps to add a field:
// 1. Getter and setter
// 2. loadSettings()
// 3. saveSettings()
// 4. tests
// Singleton
class Settings {
  late SharedPreferences _sharedPreferences;

  // Private constructor
  Settings._internal();

  // Static instance of the class
  static final Settings _instance = Settings._internal();

  // Factory constructor to always return the same instance
  factory Settings() {
    return _instance;
  }

  // Fields
  String _wordA = '';

  String get wordA => _wordA;
  set wordA(String value) {
    _wordA = value;
    saveSettings();
  }

  // Method to load settings
  Future<void> loadSettings() async{
    // Obtain shared preferences
    _sharedPreferences = await SharedPreferences.getInstance();
    // Write all settings to Settings()
    _wordA = _sharedPreferences.getString('wordA') ?? '';
  }

  saveSettings() async{
    await _sharedPreferences.setString('wordA', _wordA);
  }
}
import 'package:shared_preferences/shared_preferences.dart';

// Steps to add a field:
// 1. Getter and setter
// 2. loadSettings()
// 3. saveSettings()

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

  // Fields with getter and setter
  int _currentBox = 1;
  int get currentBox => _currentBox;
  set currentBox(int value) {
    _currentBox = value;
    saveSettings();
  }

  int _stackSize = 10;
  int get stackSize => _stackSize;
  set stackSize(int value) {
    _stackSize = value;
    saveSettings();
  }

  // GitHub credentials
  String _token = '';
  String get token => _token;
  String _repoOwner = '';
  String get repoOwner => _repoOwner;
  String _repoName = '';
  String get repoName => _repoName;
  void saveCredentials({String? token, required String repoOwner, required String repoName}) {
    _token = (token == null || token == '') ? _token : token;
    _repoOwner = repoOwner;
    _repoName = repoName;
    saveSettings();
  }

  // Method to load settings
  Future<void> loadSettings() async{
    // Obtain shared preferences
    _sharedPreferences = await SharedPreferences.getInstance();
    // Write all settings to Settings()
    _currentBox = _sharedPreferences.getInt('currentBox') ?? 1;
    _stackSize = _sharedPreferences.getInt('stackSize') ?? 10;
    _token = _sharedPreferences.getString('token') ?? '';
    _repoOwner = _sharedPreferences.getString('repoOwner') ?? '';
    _repoName = _sharedPreferences.getString('repoName') ?? '';
  }

  saveSettings() async{
    await _sharedPreferences.setInt('currentBox', _currentBox);
    await _sharedPreferences.setInt('stackSize', _stackSize);
    await _sharedPreferences.setString('token', _token);
    await _sharedPreferences.setString('repoOwner', _repoOwner);
    await _sharedPreferences.setString('repoName', _repoName);
  }
}
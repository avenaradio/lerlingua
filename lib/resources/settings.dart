import 'package:lerlingua/resources/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  // Set of feleted cards for syncronization
  final Set<int> _deletedCards = <int>{};
  Set<int> get deletedCards => _deletedCards;
  String get deletedCardsString => _deletedCards.join('/');
  /// Adds keys of deleted cards to the set
  /// Takes a string with keys separated by '/'
  addDeletedCards(String value) {
    if(value == '') return;
    List<int> deletedCards = value.split('/').map((e) => int.parse(e)).toList();
    _deletedCards.addAll(deletedCards);
    saveSettings();
  }
  /// Removes keys of deleted cards from the set for undo
  /// Takes a string with keys separated by '/'
  removeDeletedCards(String value) {
    if(value == '') return;
    List<int> deletedCards = value.split('/').map((e) => int.parse(e)).toList();
    _deletedCards.removeAll(deletedCards);
    saveSettings();
  }

  // Translation Services
  int _currentTranslationServiceKey = 0;
  final Set<TranslationService> _translationServices = <TranslationService>{};
  /// Returns the set of translation services ordered by languageA
  /// - Tested
  List<TranslationService> get translationServices => _translationServices.toList()..sort((a, b) => a.languageB.compareTo(b.languageB));
  /// Returns the current translation service
  /// - Tested
  TranslationService? get currentTranslationService {
    // check if there is a translation services with current key
    if(_translationServices.where((element) => element.key == _currentTranslationServiceKey).firstOrNull == null) _currentTranslationServiceKey = 0;
    if(_currentTranslationServiceKey == 0 && _translationServices.isEmpty) return null;
    if(_currentTranslationServiceKey == 0) {
      currentTranslationService = _translationServices.first;
      return _translationServices.first;
    }
    return _translationServices.firstWhere((element) => element.key == _currentTranslationServiceKey);
  }
  /// Sets the current translation service
  /// - Tested
  set currentTranslationService(TranslationService? translationService) {
    if(translationService == null) {
      _currentTranslationServiceKey = 0;
      return;
    }
    _currentTranslationServiceKey = translationService.key;
    addOrUpdateTranslationService(translationService);
    saveSettings();
  }
  /// Adds a translation service
  /// - Tested
  void addOrUpdateTranslationService(TranslationService translationService) {
    // If TranslationService with key already exists, delete it
    if(_translationServices.any((element) => element.key == translationService.key)) {
      _translationServices.removeWhere((element) => element.key == translationService.key);
    }
    _translationServices.add(translationService);
    saveSettings();
  }
  /// Deletes a translation service
  /// - Tested
  void deleteTranslationService(TranslationService translationService) {
    _translationServices.removeWhere((element) => element.key == translationService.key);
    saveSettings();
  }

  /// Loads settings from SharedPreferences
  /// - Tested
  Future<void> loadSettings() async{
    // Obtain shared preferences
    _sharedPreferences = await SharedPreferences.getInstance();
    // Write all settings to Settings()
    _currentBox = _sharedPreferences.getInt('currentBox') ?? 1;
    _stackSize = _sharedPreferences.getInt('stackSize') ?? 10;
    _token = _sharedPreferences.getString('token') ?? '';
    _repoOwner = _sharedPreferences.getString('repoOwner') ?? '';
    _repoName = _sharedPreferences.getString('repoName') ?? '';
    // Load deleted cards
    String? deletedCardsString = _sharedPreferences.getString('deletedCards');
    if (deletedCardsString != null) addDeletedCards(deletedCardsString);
    // Load current translation service key
    _currentTranslationServiceKey = _sharedPreferences.getInt('currentTranslationServiceKey') ?? 0;
    // Load translation services Set
    String? translationServicesString = _sharedPreferences.getString('translationServices');
    if (translationServicesString != null) {
      List<dynamic> translationServicesMap = jsonDecode(translationServicesString);
      // Convert each map and add to set
      for (dynamic e in translationServicesMap) {
        addOrUpdateTranslationService(TranslationService.fromMap(e));
      }
    }
  }

  /// Saves settings to SharedPreferences
  /// - Tested
  saveSettings() async{
    await _sharedPreferences.setInt('currentBox', _currentBox);
    await _sharedPreferences.setInt('stackSize', _stackSize);
    await _sharedPreferences.setString('token', _token);
    await _sharedPreferences.setString('repoOwner', _repoOwner);
    await _sharedPreferences.setString('repoName', _repoName);
    // Save deleted cards
    await _sharedPreferences.setString('deletedCards', _deletedCards.join('/'));
    // Save current translation service key
    await _sharedPreferences.setInt('currentTranslationServiceKey', _currentTranslationServiceKey);
    // Save translation services Set
    await _sharedPreferences.setString('translationServices', jsonEncode(_translationServices.map((e) => e.toMap()).toList()));
  }
}
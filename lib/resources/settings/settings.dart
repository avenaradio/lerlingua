import 'package:flutter/cupertino.dart';
import 'package:lerlingua/resources/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../file_utils/book.dart';

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

  bool _firstRun = true;
  bool get firstRun => _firstRun;
  set firstRun(bool value) {
    _firstRun = value;
    saveSettings();
  }

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

  int _fontSize = 18;
  int get fontSize => _fontSize;
  set fontSize(int value) {
    _fontSize = value;
    saveSettings();
  }

  bool _autoUpdate = true;
  bool get autoUpdate => _autoUpdate;
  set autoUpdate(bool value) {
    _autoUpdate = value;
    saveSettings();
  }

  bool _showFeedbackButton = true;
  bool get showFeedbackButton => _showFeedbackButton;
  set showFeedbackButton(bool value) {
    _showFeedbackButton = value;
    saveSettings();
  }

  bool _updateAvailable = false;
  bool get updateAvailable => _updateAvailable;
  set updateAvailable(bool value) {
    _updateAvailable = value;
    saveSettings();
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  set isDarkMode(bool value) {
    _isDarkMode = value;
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

  /* --------------------------------------------
  ----- DELETED CARDS FOR SYNCHRONIZATION -------
  ---------------------------------------------*/
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

  /* --------------------------------------------
  ------------ TRANSLATION SERVICES -------------
  ---------------------------------------------*/
  int _currentTranslationServiceKey = 0;
  @visibleForTesting
  final Set<TranslationService> translationServicesSet = <TranslationService>{};
  /// Returns List&lt;TranslationService&gt; ordered by languageB, then languageA, then key
  /// - Tested
  List<TranslationService> get translationServices => translationServicesSet.toList()..sort((a, b) {
    int compareLanguageB = a.languageB.compareTo(b.languageB);
    if (compareLanguageB != 0) return compareLanguageB;
    int compareLanguageA = a.languageA.compareTo(b.languageA);
    if (compareLanguageA != 0) return compareLanguageA;
    return a.key.compareTo(b.key);
  });
  /// Returns the current translation service
  /// - Tested
  TranslationService? get currentTranslationService {
    // check if there is a translation services with current key
    if(translationServicesSet.where((element) => element.key == _currentTranslationServiceKey).firstOrNull == null) _currentTranslationServiceKey = 0;
    if(_currentTranslationServiceKey == 0 && translationServicesSet.isEmpty) return null;
    if(_currentTranslationServiceKey == 0) {
      currentTranslationService = translationServicesSet.first;
      return translationServicesSet.first;
    }
    return translationServicesSet.firstWhere((element) => element.key == _currentTranslationServiceKey);
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
    if(translationServicesSet.any((element) => element.key == translationService.key)) {
      translationServicesSet.removeWhere((element) => element.key == translationService.key);
    }
    translationServicesSet.add(translationService);
    saveSettings();
  }
  /// Deletes a translation service
  /// - Tested
  void deleteTranslationService(TranslationService translationService) {
    translationServicesSet.removeWhere((element) => element.key == translationService.key);
    saveSettings();
  }
  /// Adds default translation services if not services with same values already exist
  /// - Tested
  void overrideDefaultTranslationServices() {
    List<TranslationService> defaultTranslationServices = TranslationService.defaults;
    // Override default translation services
    for (TranslationService translationService in defaultTranslationServices) {
      addOrUpdateTranslationService(translationService);
    }
  }

  /* --------------------------------------------
  ----------------- BOOKS -----------------------
  ---------------------------------------------*/
  int? _currentBookKey;
  final Set<Book> _books = <Book>{};
  /// Returns List&lt;Book&gt; ordered by lastReadTime
  /// - Tested
  List<Book> get books => _books.toList()..sort((a, b) => b.lastReadTime.compareTo(a.lastReadTime));
  /// Returns the current book
  /// -
  Book? get currentBook {
    if(_currentBookKey == null) return null;
    Book? currentBook = _books.where((element) => element.key == _currentBookKey).firstOrNull;
    currentBook ??= books.firstOrNull;
    return currentBook;
  }
  /// Sets the current book
  /// - Tested
  set currentBook(Book? book) {
    if(book == null) {
      _currentBookKey = null;
      return;
    }
    _currentBookKey = book.key;
    addOrUpdateBook(book);
    saveSettings();
  }
  /// Adds a book
  /// - Tested
  void addOrUpdateBook(Book book) {
    // If Book with key already exists, delete it
    if(_books.any((element) => element.key == book.key)) {
      _books.removeWhere((element) => element.key == book.key);
    }
    _books.add(book);
    saveSettings();
  }
  /// Deletes a book
  /// - Tested
  void deleteBook(Book book) {
    _books.removeWhere((element) => element.key == book.key);
    saveSettings();
  }


  /* --------------------------------------------
  ------------- SHARED PREFERENCES --------------
  ---------------------------------------------*/
  /// Loads settings from SharedPreferences
  /// - Tested
  Future<void> loadSettings() async{
    // Obtain shared preferences
    _sharedPreferences = await SharedPreferences.getInstance();
    // Write all settings to Settings()
    _firstRun = _sharedPreferences.getBool('firstRun') ?? true;
    _currentBox = _sharedPreferences.getInt('currentBox') ?? 1;
    _stackSize = _sharedPreferences.getInt('stackSize') ?? 10;
    _fontSize = _sharedPreferences.getInt('fontSize') ?? 16;
    _token = _sharedPreferences.getString('token') ?? '';
    _repoOwner = _sharedPreferences.getString('repoOwner') ?? '';
    _repoName = _sharedPreferences.getString('repoName') ?? '';
    _autoUpdate = _sharedPreferences.getBool('autoUpdate') ?? true;
    _updateAvailable = _sharedPreferences.getBool('updateAvailable') ?? false;
    _showFeedbackButton = _sharedPreferences.getBool('showFeedbackButton') ?? true;
    _isDarkMode = _sharedPreferences.getBool('isDarkMode') ?? false;
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
    // Load current book key
    _currentBookKey = _sharedPreferences.getInt('currentBookKey');
    if(_currentBookKey == -1) _currentBookKey = null;
    // Load books Set
    String? booksString = _sharedPreferences.getString('books');
    if (booksString != null) {
      List<dynamic> booksMap = jsonDecode(booksString);
      // Convert each map and add to set
      for (dynamic e in booksMap) {
        addOrUpdateBook(Book.fromMap(e));
      }
    }
    // If this is the first run
    if(_firstRun) {
      _currentBookKey = null;
      _firstRun = false;
      saveSettings();
    }
    // Override default translation services
    overrideDefaultTranslationServices();
  }

  /// Saves settings to SharedPreferences
  /// - Tested
  saveSettings() async{
    await _sharedPreferences.setBool('firstRun', _firstRun);
    await _sharedPreferences.setInt('currentBox', _currentBox);
    await _sharedPreferences.setInt('stackSize', _stackSize);
    await _sharedPreferences.setInt('fontSize', _fontSize);
    await _sharedPreferences.setString('token', _token);
    await _sharedPreferences.setString('repoOwner', _repoOwner);
    await _sharedPreferences.setString('repoName', _repoName);
    await _sharedPreferences.setBool('autoUpdate', _autoUpdate);
    await _sharedPreferences.setBool('updateAvailable', _updateAvailable);
    await _sharedPreferences.setBool('showFeedbackButton', _showFeedbackButton);
    await _sharedPreferences.setBool('isDarkMode', _isDarkMode);
    // Save deleted cards
    await _sharedPreferences.setString('deletedCards', _deletedCards.join('/'));
    // Save current translation service key
    await _sharedPreferences.setInt('currentTranslationServiceKey', _currentTranslationServiceKey);
    // Save translation services Set
    await _sharedPreferences.setString('translationServices', jsonEncode(translationServicesSet.map((e) => e.toMap()).toList()));
    // Save current book key
    await _sharedPreferences.setInt('currentBookKey', _currentBookKey ?? -1);
    // Save books Set
    await _sharedPreferences.setString('books', jsonEncode(_books.map((e) => e.toMap()).toList()));
  }
}
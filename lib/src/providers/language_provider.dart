import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en';
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  String get currentLanguage => _currentLanguage;
  bool get isInitialized => _isInitialized;

  // Initialize the provider by loading saved language preference
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _currentLanguage = _prefs.getString('app_language') ?? 'en';
    _isInitialized = true;
    notifyListeners();
  }

  // Change language and persist to SharedPreferences
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;
    
    // Ensure initialized before using _prefs
    if (!_isInitialized) {
      await initialize();
    }
    
    _currentLanguage = languageCode;
    await _prefs.setString('app_language', languageCode);
    notifyListeners();
  }

  // Get language name in English
  String getLanguageName(String code) {
    const Map<String, String> languageNames = {
      'en': 'English',
      'hi': 'Hindi',
    };
    return languageNames[code] ?? 'English';
  }

  // Get language name in native script
  String getNativeLanguageName(String code) {
    const Map<String, String> nativeNames = {
      'en': 'English',
      'hi': 'हिन्दी',
    };
    return nativeNames[code] ?? 'English';
  }
}

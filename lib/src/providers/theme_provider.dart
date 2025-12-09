import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider with 10 beautiful color schemes
/// Each theme has proper contrast and accessibility
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  AppThemeData _currentTheme = AppThemes.greenWhite;

  AppThemeData get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  /// Load saved theme from storage
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeId = prefs.getString(_themeKey) ?? 'green_white';
      _currentTheme = AppThemes.getThemeById(themeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  /// Change theme and save preference
  Future<void> setTheme(AppThemeData theme) async {
    _currentTheme = theme;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, theme.id);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Get Material ThemeData for Flutter
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: _currentTheme.isDark ? Brightness.dark : Brightness.light,
      primaryColor: _currentTheme.primary,
      scaffoldBackgroundColor: _currentTheme.background,
      colorScheme: ColorScheme(
        brightness: _currentTheme.isDark ? Brightness.dark : Brightness.light,
        primary: _currentTheme.primary,
        onPrimary: _currentTheme.onPrimary,
        secondary: _currentTheme.secondary,
        onSecondary: _currentTheme.onSecondary,
        error: _currentTheme.error,
        onError: Colors.white,
        surface: _currentTheme.surface,
        onSurface: _currentTheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _currentTheme.primary,
        foregroundColor: _currentTheme.onPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _currentTheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentTheme.primary,
          foregroundColor: _currentTheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _currentTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _currentTheme.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _currentTheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: _currentTheme.onSurface.withOpacity(0.7)),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: _currentTheme.onBackground, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: _currentTheme.onBackground, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: _currentTheme.onBackground, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: _currentTheme.onBackground, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: _currentTheme.onBackground, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: _currentTheme.onBackground, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: _currentTheme.onBackground, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: _currentTheme.onBackground, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: _currentTheme.onBackground, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: _currentTheme.onBackground),
        bodyMedium: TextStyle(color: _currentTheme.onBackground),
        bodySmall: TextStyle(color: _currentTheme.onBackground.withOpacity(0.8)),
        labelLarge: TextStyle(color: _currentTheme.onPrimary),
        labelMedium: TextStyle(color: _currentTheme.onSurface),
        labelSmall: TextStyle(color: _currentTheme.onSurface.withOpacity(0.7)),
      ),
    );
  }
}

/// Theme Data Model
class AppThemeData {
  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color onSurface;
  final Color error;
  final bool isDark;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.error,
    required this.isDark,
  });
}

/// 10 Beautiful Themes with Perfect Contrast
class AppThemes {
  // 1. Green & White (Default - Krishi Bandhu)
  static const greenWhite = AppThemeData(
    id: 'green_white',
    name: 'Green & White',
    primary: Color(0xFF2E7D32), // Green 800
    secondary: Color(0xFF66BB6A), // Green 400
    background: Colors.white,
    surface: Color(0xFFF1F8F4), // Light green tint
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFF1B5E20), // Dark green for text
    onSurface: Color(0xFF1B5E20),
    error: Color(0xFFD32F2F),
    isDark: false,
  );

  // 2. Pink & White (Elegant)
  static const pinkWhite = AppThemeData(
    id: 'pink_white',
    name: 'Pink & White',
    primary: Color(0xFFC2185B), // Pink 700
    secondary: Color(0xFFEC407A), // Pink 400
    background: Colors.white,
    surface: Color(0xFFFCE4EC), // Light pink tint
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFF880E4F), // Dark pink for text
    onSurface: Color(0xFF880E4F),
    error: Color(0xFFD32F2F),
    isDark: false,
  );

  // 3. Purple & White (Royal)
  static const purpleWhite = AppThemeData(
    id: 'purple_white',
    name: 'Purple & White',
    primary: Color(0xFF7B1FA2), // Purple 700
    secondary: Color(0xFFAB47BC), // Purple 400
    background: Colors.white,
    surface: Color(0xFFF3E5F5), // Light purple tint
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFF4A148C), // Dark purple for text
    onSurface: Color(0xFF4A148C),
    error: Color(0xFFD32F2F),
    isDark: false,
  );

  // 4. Dark Blue & Black (Professional Dark)
  static const blueDark = AppThemeData(
    id: 'blue_dark',
    name: 'Blue & Black',
    primary: Color(0xFF1976D2), // Blue 700
    secondary: Color(0xFF42A5F5), // Blue 400
    background: Color(0xFF121212), // Pure black
    surface: Color(0xFF1E1E1E), // Dark gray
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFFE3F2FD), // Light blue tint for text
    onSurface: Color(0xFFE3F2FD),
    error: Color(0xFFCF6679),
    isDark: true,
  );

  // 5. Orange & White (Energetic)
  static const orangeWhite = AppThemeData(
    id: 'orange_white',
    name: 'Orange & White',
    primary: Color(0xFFE64A19), // Deep Orange 700
    secondary: Color(0xFFFF7043), // Deep Orange 400
    background: Colors.white,
    surface: Color(0xFFFBE9E7), // Light orange tint
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFFBF360C), // Dark orange for text
    onSurface: Color(0xFFBF360C),
    error: Color(0xFFD32F2F),
    isDark: false,
  );

  // 6. Red & White (Bold)
  static const redWhite = AppThemeData(
    id: 'red_white',
    name: 'Red & White',
    primary: Color(0xFFC62828), // Red 800
    secondary: Color(0xFFEF5350), // Red 400
    background: Colors.white,
    surface: Color(0xFFFFEBEE), // Light red tint
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFFB71C1C), // Dark red for text
    onSurface: Color(0xFFB71C1C),
    error: Color(0xFFD32F2F),
    isDark: false,
  );

  // 7. Teal & White (Fresh)
  static const tealWhite = AppThemeData(
    id: 'teal_white',
    name: 'Teal & White',
    primary: Color(0xFF00796B), // Teal 700
    secondary: Color(0xFF26A69A), // Teal 400
    background: Colors.white,
    surface: Color(0xFFE0F2F1), // Light teal tint
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFF004D40), // Dark teal for text
    onSurface: Color(0xFF004D40),
    error: Color(0xFFD32F2F),
    isDark: false,
  );

  // 8. Indigo & Black (Modern Dark)
  static const indigoDark = AppThemeData(
    id: 'indigo_dark',
    name: 'Indigo & Black',
    primary: Color(0xFF303F9F), // Indigo 700
    secondary: Color(0xFF5C6BC0), // Indigo 400
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFFE8EAF6), // Light indigo tint for text
    onSurface: Color(0xFFE8EAF6),
    error: Color(0xFFCF6679),
    isDark: true,
  );

  // 9. Brown & White (Earthy)
  static const brownWhite = AppThemeData(
    id: 'brown_white',
    name: 'Brown & White',
    primary: Color(0xFF5D4037), // Brown 700
    secondary: Color(0xFF8D6E63), // Brown 400
    background: Colors.white,
    surface: Color(0xFFEFEBE9), // Light brown tint
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFF3E2723), // Dark brown for text
    onSurface: Color(0xFF3E2723),
    error: Color(0xFFD32F2F),
    isDark: false,
  );

  // 10. Cyan & White (Cool)
  static const cyanWhite = AppThemeData(
    id: 'cyan_white',
    name: 'Cyan & White',
    primary: Color(0xFF0097A7), // Cyan 700
    secondary: Color(0xFF26C6DA), // Cyan 400
    background: Colors.white,
    surface: Color(0xFFE0F7FA), // Light cyan tint
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFF006064), // Dark cyan for text
    onSurface: Color(0xFF006064),
    error: Color(0xFFD32F2F),
    isDark: false,
  );

  // 11. Amber & Black (Golden Dark)
  static const amberDark = AppThemeData(
    id: 'amber_dark',
    name: 'Amber & Black',
    primary: Color(0xFFFFA000), // Amber 700
    secondary: Color(0xFFFFCA28), // Amber 400
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onBackground: Color(0xFFFFF8E1), // Light amber tint for text
    onSurface: Color(0xFFFFF8E1),
    error: Color(0xFFCF6679),
    isDark: true,
  );

  // 12. Lime & White (Fresh Green)
  static const limeWhite = AppThemeData(
    id: 'lime_white',
    name: 'Lime & White',
    primary: Color(0xFF689F38), // Light Green 700
    secondary: Color(0xFF9CCC65), // Light Green 400
    background: Colors.white,
    surface: Color(0xFFF1F8E9), // Light lime tint
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Color(0xFF33691E), // Dark lime for text
    onSurface: Color(0xFF33691E),
    error: Color(0xFFD32F2F),
    isDark: false,
  );

  // 13. Deep Purple & Black (Royal Dark)
  static const deepPurpleDark = AppThemeData(
    id: 'deep_purple_dark',
    name: 'Deep Purple & Black',
    primary: Color(0xFF512DA8), // Deep Purple 700
    secondary: Color(0xFF7E57C2), // Deep Purple 400
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFFEDE7F6), // Light purple tint for text
    onSurface: Color(0xFFEDE7F6),
    error: Color(0xFFCF6679),
    isDark: true,
  );

  // 14. Yellow & White (Sunshine)
  static const yellowWhite = AppThemeData(
    id: 'yellow_white',
    name: 'Yellow & White',
    primary: Color(0xFFF57C00), // Orange 700 (warm yellow)
    secondary: Color(0xFFFFB74D), // Orange 300
    background: Colors.white,
    surface: Color(0xFFFFF3E0), // Light yellow tint
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Color(0xFFE65100), // Dark orange for text
    onSurface: Color(0xFFE65100),
    error: Color(0xFFD32F2F),
    isDark: false,
  );

  // 15. Blue Grey & Black (Professional)
  static const blueGreyDark = AppThemeData(
    id: 'blue_grey_dark',
    name: 'Blue Grey & Black',
    primary: Color(0xFF455A64), // Blue Grey 700
    secondary: Color(0xFF78909C), // Blue Grey 400
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFFECEFF1), // Light blue grey for text
    onSurface: Color(0xFFECEFF1),
    error: Color(0xFFCF6679),
    isDark: true,
  );

  /// Get all available themes
  static List<AppThemeData> get allThemes => [
    greenWhite,
    pinkWhite,
    purpleWhite,
    blueDark,
    orangeWhite,
    redWhite,
    tealWhite,
    indigoDark,
    brownWhite,
    cyanWhite,
    amberDark,
    limeWhite,
    deepPurpleDark,
    yellowWhite,
    blueGreyDark,
  ];

  /// Get theme by ID
  static AppThemeData getThemeById(String id) {
    return allThemes.firstWhere(
      (theme) => theme.id == id,
      orElse: () => greenWhite,
    );
  }
}

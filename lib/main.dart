import 'package:flutter/material.dart';
import 'screens/news_home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'models/news_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: const NewsApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class FavoritesProvider extends ChangeNotifier {
  final List<NewsModel> _favorites = [];

  List<NewsModel> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String url) {
    return _favorites.any((article) => article.url == url);
  }

  void toggleFavorite(NewsModel article) {
    final index = _favorites.indexWhere((item) => item.url == article.url);
    if (index != -1) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(article);
    }
    notifyListeners();
  }

  void removeFavorite(String url) {
    _favorites.removeWhere((article) => article.url == url);
    notifyListeners();
  }

  void clearAll() {
    _favorites.clear();
    notifyListeners();
  }
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NewsFlow',
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const NewsHomePage(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: const Color(0xFF5B67CA),
        primary: const Color(0xFF5B67CA),
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0xFFE1E3FF),
        onPrimaryContainer: const Color(0xFF0E1A7D),
        secondary: const Color(0xFF5C5F73),
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFE1E2F1),
        onSecondaryContainer: const Color(0xFF191B2E),
        tertiary: const Color(0xFF78536B),
        onTertiary: const Color(0xFFFFFFFF),
        tertiaryContainer: const Color(0xFFFFD8E8),
        onTertiaryContainer: const Color(0xFF2E1125),
        error: const Color(0xFFBA1A1A),
        onError: const Color(0xFFFFFFFF),
        errorContainer: const Color(0xFFFFDAD6),
        onErrorContainer: const Color(0xFF410002),
        surface: const Color(0xFFFEFBFF),
        onSurface: const Color(0xFF1B1B1F),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF5F2F7),
        surfaceContainer: const Color(0xFFEFECF1),
        surfaceContainerHigh: const Color(0xFFE9E6EB),
        surfaceContainerHighest: const Color(0xFFE3E1E6),
        outline: const Color(0xFF757681),
        outlineVariant: const Color(0xFFC5C6D0),
        inverseSurface: const Color(0xFF303034),
        onInverseSurface: const Color(0xFFF2F0F4),
        inversePrimary: const Color(0xFFBFC7FF),
      ),
      scaffoldBackgroundColor: const Color(0xFFFEFBFF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1B1B1F),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1B1B1F),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFFC5C6D0).withValues(alpha: 0.3),
          ),
        ),
        color: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Color(0xFF5B67CA),
        unselectedItemColor: Color(0xFF757681),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF5B67CA),
        primary: const Color(0xFFBFC7FF),
        onPrimary: const Color(0xFF0E1A7D),
        primaryContainer: const Color(0xFF3F4C93),
        onPrimaryContainer: const Color(0xFFE1E3FF),
        secondary: const Color(0xFFC5C6D5),
        onSecondary: const Color(0xFF2E3043),
        secondaryContainer: const Color(0xFF454759),
        onSecondaryContainer: const Color(0xFFE1E2F1),
        tertiary: const Color(0xFFE6B7CC),
        onTertiary: const Color(0xFF45263B),
        tertiaryContainer: const Color(0xFF5E3C52),
        onTertiaryContainer: const Color(0xFFFFD8E8),
        error: const Color(0xFFFFB4AB),
        onError: const Color(0xFF690005),
        errorContainer: const Color(0xFF93000A),
        onErrorContainer: const Color(0xFFFFDAD6),
        surface: const Color(0xFF131318),
        onSurface: const Color(0xFFE3E1E6),
        surfaceContainerLowest: const Color(0xFF0E0E13),
        surfaceContainerLow: const Color(0xFF1B1B20),
        surfaceContainer: const Color(0xFF1F1F24),
        surfaceContainerHigh: const Color(0xFF2A2A2F),
        surfaceContainerHighest: const Color(0xFF35353A),
        outline: const Color(0xFF8F909A),
        outlineVariant: const Color(0xFF454652),
        inverseSurface: const Color(0xFFE3E1E6),
        onInverseSurface: const Color(0xFF303034),
        inversePrimary: const Color(0xFF5B67CA),
      ),
      scaffoldBackgroundColor: const Color(0xFF131318),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE3E1E6),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFE3E1E6),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF454652).withValues(alpha: 0.3),
          ),
        ),
        color: const Color(0xFF1F1F24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F1F24),
        selectedItemColor: Color(0xFFBFC7FF),
        unselectedItemColor: Color(0xFF8F909A),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

String getImageUrl(String url) {
  if (kIsWeb) {
    return 'https://corsproxy.io/?$url';
  }

  // Fix common URL encoding issues
  String fixedUrl = url
      .replaceAll('\\/', '/') // Fix escaped slashes
      .replaceAll('&amp;', '&'); // Fix escaped ampersands

  // Handle Reddit image URLs that need HTML decoding
  if (fixedUrl.contains('amp;')) {
    fixedUrl = fixedUrl.replaceAll('amp;', '');
  }

  return fixedUrl;
}

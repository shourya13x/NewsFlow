import 'package:flutter/material.dart';
import 'package:api_integration/screens/news_home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News Explorer',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF2196F3), // Professional blue
          primary: const Color(0xFF2196F3),
          onPrimary: const Color(0xFFFFFFFF),
          primaryContainer: const Color(0xFFE3F2FD),
          onPrimaryContainer: const Color(0xFF1976D2),
          secondary: const Color(0xFF009688), // Teal
          onSecondary: const Color(0xFFFFFFFF),
          secondaryContainer: const Color(0xFFE0F2F1),
          onSecondaryContainer: const Color(0xFF00695C),
          tertiary: const Color(0xFF4CAF50), // Green
          onTertiary: const Color(0xFFFFFFFF),
          tertiaryContainer: const Color(0xFFE8F5E8),
          onTertiaryContainer: const Color(0xFF2E7D32),
          error: const Color(0xFFF44336),
          onError: const Color(0xFFFFFFFF),
          errorContainer: const Color(0xFFFFEBEE),
          onErrorContainer: const Color(0xFFC62828),
          surface: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF212121),
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFF5F5F5),
          surfaceContainer: const Color(0xFFF0F0F0),
          surfaceContainerHigh: const Color(0xFFE8E8E8),
          surfaceContainerHighest: const Color(0xFFE0E0E0),
          outline: const Color(0xFFBDBDBD),
          outlineVariant: const Color(0xFFE0E0E0),
          shadow: const Color(0xFF000000),
          scrim: const Color(0xFF000000),
          inverseSurface: const Color(0xFF212121),
          onInverseSurface: const Color(0xFFFFFFFF),
          inversePrimary: const Color(0xFF90CAF9),
          surfaceTint: const Color(0xFF2196F3),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF212121),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: const Color(0xFF2196F3).withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFFFFFFFF),
          surfaceTintColor: const Color(0xFF2196F3),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFFFFFF),
          selectedItemColor: Color(0xFF2196F3),
          unselectedItemColor: Color(0xFF757575),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFFFFFFF),
          indicatorColor: const Color(0xFFE3F2FD),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2196F3),
            ),
          ),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: Color(0xFF2196F3));
            }
            return const IconThemeData(color: Color(0xFF757575));
          }),
          elevation: 8,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFF212121)),
          displayMedium: TextStyle(color: Color(0xFF212121)),
          displaySmall: TextStyle(color: Color(0xFF212121)),
          headlineLarge: TextStyle(color: Color(0xFF212121)),
          headlineMedium: TextStyle(color: Color(0xFF212121)),
          headlineSmall: TextStyle(color: Color(0xFF212121)),
          titleLarge: TextStyle(color: Color(0xFF212121)),
          titleMedium: TextStyle(color: Color(0xFF212121)),
          titleSmall: TextStyle(color: Color(0xFF212121)),
          bodyLarge: TextStyle(color: Color(0xFF212121)),
          bodyMedium: TextStyle(color: Color(0xFF212121)),
          bodySmall: TextStyle(color: Color(0xFF757575)),
          labelLarge: TextStyle(color: Color(0xFF212121)),
          labelMedium: TextStyle(color: Color(0xFF212121)),
          labelSmall: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      home: const NewsHomePage(),
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

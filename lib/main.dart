import 'package:flutter/material.dart';
import 'package:api_integration/screens/meme_home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MemeApp());
}

class MemeApp extends StatelessWidget {
  const MemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meme Explorer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFFE91E63),
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFF2196F3),
          tertiary: const Color(0xFFFF9800),
          surface: const Color(0xFFFAFAFA),
          surfaceContainerLowest: const Color(0xFFF5F5F5),
          surfaceContainerLow: const Color(0xFFEFEFEF),
          surfaceContainer: const Color(0xFFE8E8E8),
          surfaceContainerHigh: const Color(0xFFE0E0E0),
          surfaceContainerHighest: const Color(0xFFD8D8D8),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.white,
          error: const Color(0xFFFF5722),
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF2D3748),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 12,
          shadowColor: const Color(0xFFE91E63).withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            shadowColor: const Color(0xFFE91E63).withOpacity(0.4),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const MemeHomePage(),
    );
  }
}

String getImageUrl(String url) {
  if (kIsWeb) {
    return 'https://corsproxy.io/?$url';
  }
  return url;
}

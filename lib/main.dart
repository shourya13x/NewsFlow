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
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 75, 183, 58),
        visualDensity: VisualDensity.adaptivePlatformDensity,
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

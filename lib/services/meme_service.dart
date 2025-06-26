import 'package:api_integration/models/meme_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemeService {
  static const String clientId = 'TqRq2kHD07fQX7iEWtKMaQ';
  static const String clientSecret = 'NDhq7sNYcBbYPDG-YdZk6HU1gQRKEw';
  static const List<String> subreddits = [
    'memes',
    'wholesomememes',
    'dankmemes',
    'funny',
    'me_irl',
    'AdviceAnimals',
    'MemeEconomy',
  ];

  static String? _accessToken;
  static DateTime? _tokenExpiry;

  static Future<void> _authenticate() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return;
    }
    final response = await http.post(
      Uri.parse('https://www.reddit.com/api/v1/access_token'),
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in']));
    } else {
      throw Exception('Reddit Auth failed: ${response.body}');
    }
  }

  static Future<List<Meme>?> fetchMemes(
    BuildContext context, {
    int page = 1,
    String? after,
  }) async {
    try {
      await _authenticate();
      final subreddit = (List.of(subreddits)..shuffle()).first;
      final url =
          'https://oauth.reddit.com/r/$subreddit/hot?limit=25${after != null ? '&after=$after' : ''}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'User-Agent': 'MemeExplorer/0.1 by Western-Carry-6201',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List children = data['data']['children'];
        if (children.isEmpty) return [];
        final memes =
            children
                .map((item) => item['data'])
                .where(
                  (item) => item['post_hint'] == 'image' && item['url'] != null,
                )
                .map<Meme>(
                  (item) => Meme(
                    postLink: 'https://reddit.com${item['permalink']}',
                    subreddit: item['subreddit'],
                    title: item['title'],
                    url: item['url'],
                    nsfw: item['over_18'],
                    spoiler: item['spoiler'],
                    author: item['author'],
                    ups: item['ups'],
                    preview:
                        item['preview'] != null &&
                                item['preview']['images'] != null
                            ? List<String>.from(
                              item['preview']['images'].map(
                                (img) => img['source']['url'],
                              ),
                            )
                            : null,
                  ),
                )
                .toList();
        return memes;
      } else {
        throw Exception(
          'Failed to load memes: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading memes: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return [];
    }
  }
}

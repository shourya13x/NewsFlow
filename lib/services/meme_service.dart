import 'package:api_integration/models/meme_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemeService {
  static Future<List<Meme>?> fetchMemes(
    BuildContext context, {
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('https://meme-api.com/gimme/wholesomememes/50'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null || data['memes'] == null) {
          return [];
        }

        final List<dynamic> memesList = data['memes'];
        if (memesList.isEmpty) {
          return [];
        }

        return memesList.map((meme) => Meme.fromJson(meme)).toList();
      } else {
        throw Exception('Failed to load memes: ${response.statusCode}');
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

import 'package:flutter/material.dart';
import 'package:api_integration/widgets/news_card.dart';
import 'package:api_integration/models/news_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<News> savedArticles = [];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Articles',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: colorScheme.surfaceContainerLowest,
      body:
          savedArticles.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_outline_rounded,
                      size: 64,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved articles yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start bookmarking articles to see them here!',
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  ],
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: 20,
                ),
                itemCount: savedArticles.length,
                itemBuilder: (context, index) {
                  final news = savedArticles[index];
                  return NewsCard(
                    title: news.title,
                    imageUrl: news.url,
                    ups: news.ups,
                    postLink: news.postLink,
                    index: index,
                    subreddit: news.subreddit,
                  );
                },
              ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:newsflow/widgets/news_card.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
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
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              if (favoritesProvider.favorites.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Clear All Favorites'),
                          content: const Text(
                            'Are you sure you want to remove all saved articles?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                favoritesProvider.clearAll();
                                Navigator.pop(context);
                              },
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(Icons.clear_all_rounded),
                tooltip: 'Clear all favorites',
              );
            },
          ),
        ],
      ),
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final savedArticles = favoritesProvider.favorites;

          if (savedArticles.isEmpty) {
            return Center(
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
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 0.75,
              mainAxisSpacing: 20,
            ),
            itemCount: savedArticles.length,
            itemBuilder: (context, index) {
              final article = savedArticles[index];
              return NewsCard(
                title: article.title,
                imageUrl: article.urlToImage,
                ups: 0, // Favorites don't have upvotes
                postLink: article.url,
                index: index,
                subreddit: article.source,
              );
            },
          );
        },
      ),
    );
  }
}

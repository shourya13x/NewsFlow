import 'package:newsflow/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/category_model.dart';

class NewsPage {
  final List<News> items;
  final String? after;
  NewsPage(this.items, this.after);
}

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;
  final String? author;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    this.author,
  });
}

class NewsService {
  // Top 5 Free News APIs with Image Support
  // 1. NewsAPI.org - Free tier: 500 requests/day
  static const String _newsApiKey =
      'a14560e959f24c6b86ec00c73fcc22c4'; // Get from newsapi.org

  // 2. GNews API - Free tier: 100 requests/day
  static const String _gnewsApiKey =
      '9ac72b797fbdfc4d8d2dfdfe1e037b12'; // Get from gnews.io

  // 3. Bing News Search API - Free tier: 1000 requests/month
  static const String _bingApiKey =
      'YOUR_BING_API_KEY'; // Get from Azure portal

  // 4. MediaStack API - Free tier: 500 requests/month
  static const String _mediaStackApiKey =
      'YOUR_MEDIASTACK_API_KEY'; // Get from mediastack.com

  // 5. NewsData.io - Free tier: 200 requests/day
  static const String _newsDataApiKey =
      'pub_1e60436310544iobbcab99b42e3c2ba39a'; // Get from newsdata.io

  static Map<String, dynamic> mapCategoryToApi(String category) {
    // Find the category in softwareCategories
    final cat = softwareCategories.firstWhere(
      (c) => c.name.toLowerCase() == category.toLowerCase(),
      orElse: () => softwareCategories.first,
    );
    // Standard NewsAPI categories
    const standardCategories = [
      'business',
      'entertainment',
      'general',
      'health',
      'science',
      'sports',
      'technology',
      'politics',
      'world',
      'nation',
      'finance',
      'food',
      'travel',
      'art',
      'fashion',
      'music',
    ];
    // If the category or its first keyword is a standard category, use it
    final apiCategory = cat.keywords.firstWhere(
      (k) => standardCategories.contains(k.toLowerCase()),
      orElse: () => '',
    );
    if (apiCategory.isNotEmpty) {
      return {'category': apiCategory, 'query': null};
    } else {
      // Use all keywords as a search query
      return {'category': null, 'query': cat.keywords.join(' OR ')};
    }
  }

  static Future<NewsPage?> fetchAllTechNews(
    BuildContext context, {
    int page = 1,
    String? after,
    bool isRefresh = false,
    String category = 'All',
  }) async {
    try {
      final mapped = mapCategoryToApi(category);
      final apiCategory = mapped['category'];
      final query = mapped['query'];
      debugPrint(
        'Fetching real tech news from APIs - page: $page, isRefresh: $isRefresh, category: $category, apiCategory: $apiCategory, query: $query',
      );
      final effectivePage =
          isRefresh ? (page + DateTime.now().millisecondsSinceEpoch % 5) : page;
      final results = await Future.wait([
        fetchNewsApiTechHeadlines(
              page: effectivePage,
              pageSize: 6,
              isRefresh: isRefresh,
              category: apiCategory,
              query: query,
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => <NewsArticle>[],
            )
            .catchError((e) {
              debugPrint('NewsAPI error: $e');
              return <NewsArticle>[];
            }),
        fetchGNewsTechHeadlines(
              page: effectivePage,
              pageSize: 6,
              isRefresh: isRefresh,
              category: apiCategory,
              query: query,
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => <NewsArticle>[],
            )
            .catchError((e) {
              debugPrint('GNews error: $e');
              return <NewsArticle>[];
            }),
        fetchNewsDataTechHeadlines(
              page: effectivePage,
              pageSize: 6,
              isRefresh: isRefresh,
              category: apiCategory,
              query: query,
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => <NewsArticle>[],
            )
            .catchError((e) {
              debugPrint('NewsData error: $e');
              return <NewsArticle>[];
            }),
        Future.value(_generateMockTechArticles(effectivePage).take(2).toList()),
      ]);

      // Combine and deduplicate articles
      final allArticles = <NewsArticle>[];
      final seenUrls = <String>{};
      final seenTitles = <String>[];
      final seenContentHashes = <String>{};

      for (final list in results) {
        for (final article in list) {
          if (article.url.isEmpty) continue;

          // Only include articles with valid images
          if (article.imageUrl == null || article.imageUrl!.isEmpty) continue;

          final normalizedTitle = _normalizeTitle(article.title);
          final contentHash = _createContentHash(
            article.title,
            article.description,
          );
          final normalizedUrl = _normalizeUrl(article.url);

          bool isDuplicate = false;
          for (final prevTitle in seenTitles) {
            if (_jaccardSimilarity(normalizedTitle, prevTitle) >= 0.85) {
              isDuplicate = true;
              break;
            }
          }
          isDuplicate =
              isDuplicate ||
              seenUrls.contains(article.url) ||
              seenUrls.contains(normalizedUrl) ||
              seenContentHashes.contains(contentHash);

          if (!isDuplicate) {
            allArticles.add(article);
            seenUrls.add(article.url);
            seenUrls.add(normalizedUrl);
            seenTitles.add(normalizedTitle);
            seenContentHashes.add(contentHash);
          }
        }
      }

      allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      final uniqueArticles = allArticles.take(20).toList();
      debugPrint(
        'fetchAllTechNews: ${allArticles.length} total articles with images, taking ${uniqueArticles.length}',
      );

      final news = uniqueArticles.map(_newsArticleToNews).toList();
      debugPrint('fetchAllTechNews: ${news.length} articles ready for display');

      final hasMore = news.isNotEmpty || page < 5;
      return NewsPage(news, hasMore ? (page + 1).toString() : null);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tech news: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return NewsPage([], null);
    }
  }

  static News _newsArticleToNews(NewsArticle article) {
    String processedImageUrl = (article.imageUrl ?? '')
        .replaceAll('\\/', '/')
        .replaceAll('&amp;', '&');
    return News(
      postLink: article.url,
      subreddit: article.source,
      title: article.title,
      url: processedImageUrl,
      nsfw: false,
      spoiler: false,
      author: article.author ?? '',
      ups: 0,
      preview: processedImageUrl.isNotEmpty ? [processedImageUrl] : null,
      description: article.description,
    );
  }

  // 1. NewsAPI.org - Excellent image support
  static Future<List<NewsArticle>> fetchNewsApiTechHeadlines({
    int page = 1,
    int pageSize = 20,
    bool isRefresh = false,
    String category = 'technology',
    String? query,
  }) async {
    try {
      final queryParams = {
        'apiKey': _newsApiKey,
        'country': 'us',
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (isRefresh) {
        queryParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      } else if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines',
      ).replace(queryParameters: queryParams);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];
        return articles
            .map((article) {
              return NewsArticle(
                title: article['title'] ?? '',
                description: article['description'] ?? '',
                url: article['url'] ?? '',
                imageUrl: article['urlToImage'],
                source: article['source']?['name'] ?? 'NewsAPI',
                publishedAt:
                    DateTime.tryParse(article['publishedAt'] ?? '') ??
                    DateTime.now(),
                author: article['author'],
              );
            })
            .where(
              (a) =>
                  a.title.isNotEmpty &&
                  a.url.isNotEmpty &&
                  a.imageUrl != null &&
                  a.imageUrl!.isNotEmpty,
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching NewsAPI headlines: $e');
    }
    return [];
  }

  // 2. GNews API - Good image support
  static Future<List<NewsArticle>> fetchGNewsTechHeadlines({
    int page = 1,
    int pageSize = 20,
    bool isRefresh = false,
    String category = 'technology',
    String? query,
  }) async {
    try {
      final queryParams = {
        'token': _gnewsApiKey,
        'lang': 'en',
        'max': pageSize.toString(),
        'page': page.toString(),
      };
      if (isRefresh) {
        queryParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
      }
      if (category != null && category.isNotEmpty) {
        queryParams['topic'] = category;
      } else if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      final url = Uri.parse(
        'https://gnews.io/api/v4/top-headlines',
      ).replace(queryParameters: queryParams);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];
        return articles
            .map((article) {
              return NewsArticle(
                title: article['title'] ?? '',
                description: article['description'] ?? '',
                url: article['url'] ?? '',
                imageUrl: article['image'],
                source: article['source']?['name'] ?? 'GNews',
                publishedAt:
                    DateTime.tryParse(article['publishedAt'] ?? '') ??
                    DateTime.now(),
                author: article['author'],
              );
            })
            .where(
              (a) =>
                  a.title.isNotEmpty &&
                  a.url.isNotEmpty &&
                  a.imageUrl != null &&
                  a.imageUrl!.isNotEmpty,
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching GNews headlines: $e');
    }
    return [];
  }

  // 3. Bing News Search API - Excellent image support
  static Future<List<NewsArticle>> fetchBingNewsTechHeadlines({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.bing.microsoft.com/v7.0/news/search',
      ).replace(
        queryParameters: {
          'q': 'technology news',
          'count': pageSize.toString(),
          'offset': ((page - 1) * pageSize).toString(),
          'mkt': 'en-US',
          'freshness': 'Day',
        },
      );

      final response = await http.get(
        url,
        headers: {'Ocp-Apim-Subscription-Key': _bingApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['value'] ?? [];

        return articles
            .map((article) {
              String? imageUrl;
              if (article['image'] != null &&
                  article['image']['thumbnail'] != null) {
                imageUrl = article['image']['thumbnail']['contentUrl'];
              }

              return NewsArticle(
                title: article['name'] ?? '',
                description: article['description'] ?? '',
                url: article['url'] ?? '',
                imageUrl: imageUrl,
                source: article['provider']?[0]?['name'] ?? 'Bing News',
                publishedAt:
                    DateTime.tryParse(article['datePublished'] ?? '') ??
                    DateTime.now(),
                author: article['provider']?[0]?['name'],
              );
            })
            .where(
              (a) =>
                  a.title.isNotEmpty &&
                  a.url.isNotEmpty &&
                  a.imageUrl != null &&
                  a.imageUrl!.isNotEmpty,
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching Bing News headlines: $e');
    }
    return [];
  }

  // 4. MediaStack API - Good image support
  static Future<List<NewsArticle>> fetchMediaStackTechNews({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse('http://api.mediastack.com/v1/news').replace(
        queryParameters: {
          'access_key': _mediaStackApiKey,
          'categories': 'technology',
          'languages': 'en',
          'limit': pageSize.toString(),
          'offset': ((page - 1) * pageSize).toString(),
        },
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['data'] ?? [];

        return articles
            .map((article) {
              return NewsArticle(
                title: article['title'] ?? '',
                description: article['description'] ?? '',
                url: article['url'] ?? '',
                imageUrl: article['image'], // MediaStack provides image field
                source: article['source'] ?? 'MediaStack',
                publishedAt:
                    DateTime.tryParse(article['published_at'] ?? '') ??
                    DateTime.now(),
                author: article['author'],
              );
            })
            .where(
              (a) =>
                  a.title.isNotEmpty &&
                  a.url.isNotEmpty &&
                  a.imageUrl != null &&
                  a.imageUrl!.isNotEmpty,
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching MediaStack news: $e');
    }
    return [];
  }

  // 5. NewsData.io - Good image support
  static Future<List<NewsArticle>> fetchNewsDataTechHeadlines({
    int page = 1,
    int pageSize = 20,
    bool isRefresh = false,
    String category = 'technology',
    String? query,
  }) async {
    try {
      final queryParams = {
        'apikey': _newsDataApiKey,
        'language': 'en',
        'size': pageSize.toString(),
        'page': page.toString(),
      };
      if (isRefresh) {
        queryParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      } else if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      final url = Uri.parse(
        'https://newsdata.io/api/1/news',
      ).replace(queryParameters: queryParams);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['results'] ?? [];
        return articles
            .map((article) {
              String? imageUrl;
              if (article['image_url'] != null) {
                imageUrl = article['image_url'];
              } else if (article['content'] != null &&
                  article['content'].contains('img')) {
                final imgMatch = RegExp(
                  r'<img[^>]+src="([^"]+)"',
                ).firstMatch(article['content']);
                if (imgMatch != null) {
                  imageUrl = imgMatch.group(1);
                }
              }
              return NewsArticle(
                title: article['title'] ?? '',
                description: article['description'] ?? '',
                url: article['link'] ?? '',
                imageUrl: imageUrl,
                source: article['source_id'] ?? 'NewsData',
                publishedAt:
                    DateTime.tryParse(article['pubDate'] ?? '') ??
                    DateTime.now(),
                author: article['creator']?[0],
              );
            })
            .where(
              (a) =>
                  a.title.isNotEmpty &&
                  a.url.isNotEmpty &&
                  a.imageUrl != null &&
                  a.imageUrl!.isNotEmpty,
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching NewsData headlines: $e');
    }
    return [];
  }

  // NewsData.io - General headlines
  static Future<List<NewsArticle>> fetchNewsDataGeneralHeadlines({
    int page = 1,
    int pageSize = 20,
    bool isRefresh = false,
  }) async {
    try {
      final queryParams = {
        'apikey': _newsDataApiKey,
        'language': 'en',
        'size': pageSize.toString(),
        'page': page.toString(),
      };

      // Add cache-busting parameter for refresh
      if (isRefresh) {
        queryParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      final url = Uri.parse(
        'https://newsdata.io/api/1/news',
      ).replace(queryParameters: queryParams);

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['results'] ?? [];

        return articles
            .map((article) {
              String? imageUrl;
              if (article['image_url'] != null) {
                imageUrl = article['image_url'];
              } else if (article['content'] != null &&
                  article['content'].contains('img')) {
                // Try to extract image from content if available
                final imgMatch = RegExp(
                  r'<img[^>]+src="([^"]+)"',
                ).firstMatch(article['content']);
                if (imgMatch != null) {
                  imageUrl = imgMatch.group(1);
                }
              }

              return NewsArticle(
                title: article['title'] ?? '',
                description: article['description'] ?? '',
                url: article['link'] ?? '',
                imageUrl: imageUrl,
                source: article['source_id'] ?? 'NewsData',
                publishedAt:
                    DateTime.tryParse(article['pubDate'] ?? '') ??
                    DateTime.now(),
                author: article['creator']?[0],
              );
            })
            .where(
              (a) =>
                  a.title.isNotEmpty &&
                  a.url.isNotEmpty &&
                  a.imageUrl != null &&
                  a.imageUrl!.isNotEmpty,
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching NewsData general headlines: $e');
    }
    return [];
  }

  // Trending news from multiple sources with images
  static Future<NewsPage?> fetchTrendingNews(
    BuildContext context, {
    String? after,
    bool isRefresh = false,
  }) async {
    try {
      debugPrint(
        'Fetching real trending news from APIs, isRefresh: $isRefresh',
      );

      // Parse the current page from the 'after' parameter
      int currentPage = 1;
      if (after != null && after.startsWith('page_')) {
        currentPage = int.tryParse(after.substring(5)) ?? 1;
      }

      // For refresh, use different page numbers to get fresh content
      final effectivePage =
          isRefresh
              ? (currentPage + DateTime.now().millisecondsSinceEpoch % 5)
              : currentPage;

      final results = await Future.wait([
        fetchNewsApiGeneralHeadlines(
              page: effectivePage,
              pageSize: 8,
              isRefresh: isRefresh,
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => <NewsArticle>[],
            )
            .catchError((e) {
              debugPrint('NewsAPI trending error: $e');
              return <NewsArticle>[];
            }),
        fetchGNewsGeneralHeadlines(
              page: effectivePage,
              pageSize: 8,
              isRefresh: isRefresh,
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => <NewsArticle>[],
            )
            .catchError((e) {
              debugPrint('GNews trending error: $e');
              return <NewsArticle>[];
            }),
        fetchNewsDataGeneralHeadlines(
              page: effectivePage,
              pageSize: 8,
              isRefresh: isRefresh,
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => <NewsArticle>[],
            )
            .catchError((e) {
              debugPrint('NewsData trending error: $e');
              return <NewsArticle>[];
            }),
        // Fallback with mock data - generate different mock data for each page
        Future.value(
          _generateMockTrendingArticles()
              .skip((effectivePage - 1) * 4)
              .take(4)
              .toList(),
        ),
      ]);

      final allArticles = <NewsArticle>[];
      for (final list in results) {
        allArticles.addAll(list);
      }

      // Sort by publish date and filter for images
      allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      final articlesWithImages =
          allArticles
              .where((a) => a.imageUrl != null && a.imageUrl!.isNotEmpty)
              .take(20)
              .toList();

      final news = articlesWithImages.map(_newsArticleToNews).toList();

      debugPrint(
        'fetchTrendingNews: ${news.length} articles ready for display (page $currentPage)',
      );

      // Return the next page number, but limit to prevent infinite scrolling
      final nextPage = currentPage < 5 ? 'page_${currentPage + 1}' : null;

      return NewsPage(news, nextPage);
    } catch (e) {
      debugPrint('Error fetching trending news: $e');
      return NewsPage([], null);
    }
  }

  // NewsAPI - General headlines
  static Future<List<NewsArticle>> fetchNewsApiGeneralHeadlines({
    int page = 1,
    int pageSize = 20,
    bool isRefresh = false,
  }) async {
    try {
      final queryParams = {
        'apiKey': _newsApiKey,
        'country': 'us',
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      // Add cache-busting parameter for refresh
      if (isRefresh) {
        queryParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines',
      ).replace(queryParameters: queryParams);

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];

        return articles
            .map((article) {
              return NewsArticle(
                title: article['title'] ?? '',
                description: article['description'] ?? '',
                url: article['url'] ?? '',
                imageUrl: article['urlToImage'],
                source: article['source']?['name'] ?? 'NewsAPI',
                publishedAt:
                    DateTime.tryParse(article['publishedAt'] ?? '') ??
                    DateTime.now(),
                author: article['author'],
              );
            })
            .where(
              (a) =>
                  a.title.isNotEmpty &&
                  a.url.isNotEmpty &&
                  a.imageUrl != null &&
                  a.imageUrl!.isNotEmpty,
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching NewsAPI general headlines: $e');
    }
    return [];
  }

  // GNews - General headlines
  static Future<List<NewsArticle>> fetchGNewsGeneralHeadlines({
    int page = 1,
    int pageSize = 20,
    bool isRefresh = false,
  }) async {
    try {
      final queryParams = {
        'token': _gnewsApiKey,
        'lang': 'en',
        'max': pageSize.toString(),
        'page': page.toString(),
      };

      // Add cache-busting parameter for refresh
      if (isRefresh) {
        queryParams['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      final url = Uri.parse(
        'https://gnews.io/api/v4/top-headlines',
      ).replace(queryParameters: queryParams);

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];

        return articles
            .map((article) {
              return NewsArticle(
                title: article['title'] ?? '',
                description: article['description'] ?? '',
                url: article['url'] ?? '',
                imageUrl: article['image'],
                source: article['source']?['name'] ?? 'GNews',
                publishedAt:
                    DateTime.tryParse(article['publishedAt'] ?? '') ??
                    DateTime.now(),
                author: article['author'],
              );
            })
            .where(
              (a) =>
                  a.title.isNotEmpty &&
                  a.url.isNotEmpty &&
                  a.imageUrl != null &&
                  a.imageUrl!.isNotEmpty,
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching GNews general headlines: $e');
    }
    return [];
  }

  // Bing News - General headlines
  static Future<List<NewsArticle>> fetchBingNewsGeneralHeadlines({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.bing.microsoft.com/v7.0/news/search',
      ).replace(
        queryParameters: {
          'q': 'breaking news',
          'count': pageSize.toString(),
          'offset': ((page - 1) * pageSize).toString(),
          'mkt': 'en-US',
          'freshness': 'Day',
        },
      );

      final response = await http.get(
        url,
        headers: {'Ocp-Apim-Subscription-Key': _bingApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['value'] ?? [];

        return articles
            .map((article) {
              String? imageUrl;
              if (article['image'] != null &&
                  article['image']['thumbnail'] != null) {
                imageUrl = article['image']['thumbnail']['contentUrl'];
              }

              return NewsArticle(
                title: article['name'] ?? '',
                description: article['description'] ?? '',
                url: article['url'] ?? '',
                imageUrl: imageUrl,
                source: article['provider']?[0]?['name'] ?? 'Bing News',
                publishedAt:
                    DateTime.tryParse(article['datePublished'] ?? '') ??
                    DateTime.now(),
                author: article['provider']?[0]?['name'],
              );
            })
            .where(
              (a) =>
                  a.title.isNotEmpty &&
                  a.url.isNotEmpty &&
                  a.imageUrl != null &&
                  a.imageUrl!.isNotEmpty,
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching Bing News general headlines: $e');
    }
    return [];
  }

  // Helper methods for deduplication
  static String _normalizeTitle(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static double _jaccardSimilarity(String a, String b) {
    final aSet = a.split(' ').toSet();
    final bSet = b.split(' ').toSet();
    final intersection = aSet.intersection(bSet).length;
    final union = aSet.union(bSet).length;
    if (union == 0) return 0.0;
    return intersection / union;
  }

  static String _createContentHash(String title, String description) {
    final combined =
        '${title.toLowerCase().trim()} ${description.toLowerCase().trim()}';
    int hash = 0;
    for (int i = 0; i < combined.length; i++) {
      hash = ((hash << 5) - hash + combined.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash.toString();
  }

  static String _normalizeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final cleanParams = <String, String>{};
      uri.queryParameters.forEach((key, value) {
        if (![
          'utm_source',
          'utm_medium',
          'utm_campaign',
          'utm_term',
          'utm_content',
          'ref',
          'source',
        ].contains(key.toLowerCase())) {
          cleanParams[key] = value;
        }
      });
      return uri
          .replace(queryParameters: cleanParams.isEmpty ? null : cleanParams)
          .toString();
    } catch (e) {
      return url;
    }
  }

  static bool hasValidImage(News news) {
    if (news.url.isEmpty) return false;
    if (news.url.contains('no-image') ||
        news.url.contains('placeholder') ||
        news.url.contains('default-image')) {
      return false;
    }
    return news.url.startsWith('http') &&
        (news.url.contains('.jpg') ||
            news.url.contains('.jpeg') ||
            news.url.contains('.png') ||
            news.url.contains('.gif') ||
            news.url.contains('.webp'));
  }

  // Mock data generators for development
  static List<NewsArticle> _generateMockTechArticles(int page) {
    final baseIndex = (page - 1) * 10;
    return List.generate(10, (index) {
      final articleIndex = baseIndex + index + 1;
      return NewsArticle(
        title: 'Breaking Tech News $articleIndex: Revolutionary AI Development',
        description:
            'Scientists have made groundbreaking discoveries in artificial intelligence that could change the way we interact with technology forever. This development promises to revolutionize multiple industries.',
        url: 'https://example.com/tech-news-$articleIndex',
        imageUrl: 'https://picsum.photos/800/600?random=$articleIndex',
        source: 'TechDaily',
        publishedAt: DateTime.now().subtract(Duration(hours: articleIndex)),
        author: 'Tech Reporter $articleIndex',
      );
    });
  }

  static List<NewsArticle> _generateMockTrendingArticles() {
    final articles = List.generate(15, (index) {
      final articleIndex = index + 1;
      final categories = [
        'Politics',
        'Sports',
        'Entertainment',
        'Business',
        'Health',
      ];
      final category = categories[index % categories.length];

      return NewsArticle(
        title: 'Trending $category News $articleIndex: Major Development',
        description:
            'This is a trending story in $category that has captured worldwide attention. The implications of this development are far-reaching and significant.',
        url: 'https://example.com/trending-$articleIndex',
        imageUrl: 'https://picsum.photos/800/600?random=${articleIndex + 100}',
        source: '${category}Times',
        publishedAt: DateTime.now().subtract(
          Duration(minutes: articleIndex * 30),
        ),
        author: '$category Reporter $articleIndex',
      );
    });
    articles.shuffle(); // Shuffle to simulate new news order on each refresh
    return articles;
  }
}

// Abstract controller for infinite scrolling news
abstract class InfiniteNewsController extends ChangeNotifier {
  List<News> news = [];
  String? newsAfter;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isError = false;
  bool noMoreNews = false;
  BuildContext? context;
  bool _isDisposed = false;

  InfiniteNewsController({this.context});

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<NewsPage?> fetchPage({
    required int page,
    String? after,
    bool isRefresh = false,
  });

  Future<void> fetchInitialNews({bool isRefresh = false}) async {
    isLoading = true;
    isError = false;
    newsAfter = null;
    noMoreNews = false;
    news.clear();
    _safeNotifyListeners();
    try {
      await _fetchUntilValid(
        page: 1,
        after: null,
        append: false,
        isRefresh: isRefresh,
      );
      isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      isLoading = false;
      isError = true;
      _safeNotifyListeners();
    }
  }

  Future<void> fetchMoreNews() async {
    if (isLoadingMore || newsAfter == null || noMoreNews) return;
    isLoadingMore = true;
    _safeNotifyListeners();
    try {
      await _fetchUntilValid(
        page: int.tryParse(newsAfter ?? '1') ?? 1,
        after: newsAfter,
        append: true,
      );
      isLoadingMore = false;
      _safeNotifyListeners();
    } catch (e) {
      isLoadingMore = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _fetchUntilValid({
    required int page,
    String? after,
    required bool append,
    bool isRefresh = false,
  }) async {
    debugPrint(
      '_fetchUntilValid called: page=$page, after=$after, append=$append',
    );
    int tries = 0;
    int maxTries = 3;

    while (tries < maxTries) {
      debugPrint('Fetch attempt ${tries + 1}/$maxTries for page $page');
      final newsPage = await fetchPage(
        page: page,
        after: after,
        isRefresh: isRefresh,
      );

      if (newsPage == null) {
        debugPrint('NewsPage is null, stopping');
        newsAfter = null;
        noMoreNews = true;
        return;
      }

      debugPrint(
        'Received ${newsPage.items.length} items, after=${newsPage.after}',
      );
      final validNews =
          newsPage.items.where((n) => NewsService.hasValidImage(n)).toList();
      debugPrint('Found ${validNews.length} valid items with images');

      if (validNews.isNotEmpty) {
        final existingUrls = news.map((n) => n.url).toSet();
        final uniqueNewItems =
            validNews.where((n) => !existingUrls.contains(n.url)).toList();
        debugPrint('Adding ${uniqueNewItems.length} unique new items');

        if (append) {
          news.addAll(uniqueNewItems);
        } else {
          news = uniqueNewItems;
        }

        newsAfter = newsPage.after ?? (page + 1).toString();
        noMoreNews = false;
        debugPrint('Success! Total news: ${news.length}, hasMore: true');
        return;
      } else {
        debugPrint('No valid items with images found, trying next page');
        after = newsPage.after ?? (page + 1).toString();
        page = int.tryParse(after) ?? (page + 1);
        tries++;
      }
    }

    debugPrint(
      'Reached max tries ($maxTries), but will continue with next page',
    );
    newsAfter = (page + 1).toString();
    noMoreNews = false;
  }

  void setContext(BuildContext ctx) {
    context = ctx;
  }
}

class TechNewsController extends InfiniteNewsController {
  final String category;
  TechNewsController({BuildContext? context, required this.category})
    : super(context: context);

  @override
  Future<NewsPage?> fetchPage({
    required int page,
    String? after,
    bool isRefresh = false,
  }) {
    return NewsService.fetchAllTechNews(
      context!,
      page: page,
      after: after,
      isRefresh: isRefresh,
      category: category,
    );
  }
}

class TrendingNewsController extends InfiniteNewsController {
  TrendingNewsController({BuildContext? context}) : super(context: context);

  @override
  Future<NewsPage?> fetchPage({
    required int page,
    String? after,
    bool isRefresh = false,
  }) {
    return NewsService.fetchTrendingNews(
      context!,
      after: after,
      isRefresh: isRefresh,
    );
  }
}

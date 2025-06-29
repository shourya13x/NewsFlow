import 'package:api_integration/models/news_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  // ... other static methods ...

  static Future<NewsPage?> fetchAllTechNews(
    BuildContext context, {
    int page = 1,
    String? after,
  }) async {
    try {
      final results = await Future.wait([
        fetchNewsApiTechHeadlines(page: page, pageSize: 20)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () => <NewsArticle>[],
            )
            .catchError((e) {
              print('NewsAPI error: $e');
              return <NewsArticle>[];
            }),
        fetchGNewsTechHeadlines(page: page, pageSize: 20)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () => <NewsArticle>[],
            )
            .catchError((e) {
              print('GNews error: $e');
              return <NewsArticle>[];
            }),
        fetchDevToArticles(page: page, pageSize: 20)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () => <NewsArticle>[],
            )
            .catchError((e) {
              print('Dev.to API error: $e');
              return <NewsArticle>[];
            }),
        fetchTechNewsFromReddit(context, page: page, after: after)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () => <NewsArticle>[],
            )
            .catchError((e) {
              print('Reddit tech subreddits error: $e');
              return <NewsArticle>[];
            }),
      ]);

      // Deduplication logic (as before)
      final allArticles = <NewsArticle>[];
      final seenUrls = <String>{};
      final seenTitles = <String>[];
      final seenContentHashes = <String>{};

      for (final list in results) {
        for (final article in list) {
          if (article.url.isEmpty) continue;
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
      print(
        'fetchAllTechNews: ${allArticles.length} total articles, taking ${uniqueArticles.length}',
      );

      final news =
          uniqueArticles
              .map(_newsArticleToNews)
              .where((n) => hasValidImage(n))
              .toList();

      print('fetchAllTechNews: ${news.length} articles with valid images');

      // Always return a pagination token to ensure infinite scroll
      // If we have valid news, great! If not, we'll still try the next page
      final hasMore =
          news.isNotEmpty || page < 10; // Try up to 10 pages before giving up
      print(
        'fetchAllTechNews: hasMore=$hasMore (${news.length} > 0 || page=$page < 10)',
      );
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
      postLink: article.url ?? '',
      subreddit: article.source ?? '',
      title: article.title ?? '',
      url: processedImageUrl,
      nsfw: false,
      spoiler: false,
      author: article.author ?? '',
      ups: 0,
      preview: processedImageUrl.isNotEmpty ? [processedImageUrl] : null,
      description: article.description ?? '',
    );
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

  // Fetch Dev.to tech articles
  static Future<List<NewsArticle>> fetchDevToArticles({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse('https://dev.to/api/articles').replace(
        queryParameters: {
          'page': page.toString(),
          'per_page': pageSize.toString(),
          'tag':
              'technology,programming,webdev,ai,flutter,react,python,cloud,devops',
        },
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> articles = json.decode(response.body);
        return articles
            .map((article) {
              return NewsArticle(
                title: article['title'] ?? '',
                description: article['description'] ?? '',
                url: article['url'] ?? '',
                imageUrl:
                    article['cover_image'] ?? article['social_image'] ?? '',
                source: 'Dev.to',
                publishedAt:
                    DateTime.tryParse(article['published_at'] ?? '') ??
                    DateTime.now(),
                author: article['user']?['name'] ?? '',
              );
            })
            .where((a) => a.title.isNotEmpty && a.url.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('Error fetching Dev.to articles: $e');
    }
    return [];
  }

  // Fetch Reddit tech news from tech subreddits
  static Future<List<NewsArticle>> fetchTechNewsFromReddit(
    BuildContext context, {
    int page = 1,
    String? after,
  }) async {
    const List<String> techSubreddits = [
      // Core Technology & Programming
      'technology',
      'programming',
      'learnprogramming',
      'computerscience',
      'softwaredevelopment',
      'coding',
      // Software Engineering & Architecture
      'algorithms',
      'datastructures',
      'systemdesign',
      'softwarearchitecture',
      'designpatterns',
      // Web Development
      'webdev',
      'Frontend',
      'Backend',
      'fullstack',
      'javascript',
      'reactjs',
      'vuejs',
      'angular',
      'nodejs',
      'webdesign',
      'css',
      'html5',
      'typescript',
      'NextJS',
      'svelte',
      'nuxtjs',
      // Mobile App Development
      'flutterdev',
      'dartlang',
      'reactnative',
      'iOSProgramming',
      'swift',
      'AndroidDev',
      'kotlin',
      'xamarin',
      'ionic',
      'appdev',
      'mobiledevelopment',
      // AI/ML & Data Science - Expanded
      'MachineLearning',
      'artificial',
      'datascience',
      'deeplearning',
      'tensorflow',
      'pytorch',
      'jupyter',
      'pandas',
      'numpy',
      'scipy',
      'reinforcementlearning',
      'computervision',
      'NLP',
      'LanguageTechnology',
      'MLQuestions',
      'learnmachinelearning',
      'OpenAI',
      'GPT3',
      'StableDiffusion',
      'AIArt',
      'neuralnetworks',
      'DataEngineering',
      'statistics',
      'rstats',
      'analytics',
      'MLOps',
      'kaggle',
      'huggingface',
      'dalle2',
      'midjourney',
      'llms',
      'chatgpt',
      'gpt4',
      'AIGeneratedArt',
      'AIPromptEngineering',
      'GenerativeAI',
      'AIEthics',
      'AINews',
      'AIresearch',
      'AIforScience',
      'MLEngineering',
      'BigDataAnalytics',
      'DataVisualization',
      'dataanalysis',
      'datascienceproject',
      'MLpapers',
      'scikitlearn',
      'KerasML',
      // FAANG & Career
      'cscareerquestions',
      'ExperiencedDevs',
      'techjobs',
      'engineeringresumes',
      'interviews',
      'leetcode',
      'bigtech',
      'faang',
      'remotework',
      // Programming Languages
      'python',
      'java',
      'cplusplus',
      'csharp',
      'golang',
      'rust',
      'php',
      'ruby',
      'scala',
      'haskell',
      'clojure',
      'elixir',
      // Frameworks & Tools
      'django',
      'flask',
      'rails',
      'laravel',
      'spring',
      'dotnet',
      'express',
      'nestjs',
      'fastapi',
      // DevOps & Cloud
      'devops',
      'docker',
      'kubernetes',
      'aws',
      'azure',
      'googlecloud',
      'terraform',
      'ansible',
      'jenkins',
      'gitlab',
      'github',
      'cicd',
      // Databases & Data
      'database',
      'sql',
      'mongodb',
      'postgresql',
      'mysql',
      'redis',
      'elasticsearch',
      'datascience',
      // UI/UX & Design
      'UI_Design',
      'UXDesign',
      'userexperience',
      'webdesign',
      'graphic_design',
      'figma',
      // General Tech & Innovation
      'Futurology',
      'gadgets',
      'technews',
      'DataIsBeautiful',
      'hardware',
      'computers',
      'cybersecurity',
      'linux',
      'opensource',
      'startups',
      'entrepreneur',
      // Meme & Community
      'ProgrammerHumor', 'techmemes', 'ITmemes', 'linuxmemes', 'pcmasterrace',
    ];
    try {
      final subreddit = (List.of(techSubreddits)..shuffle()).first;
      final url =
          'https://www.reddit.com/r/$subreddit/top.json?limit=25&t=day${after != null ? '&after=$after' : ''}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List children = data['data']['children'];
        if (children.isEmpty) return [];
        final articles =
            children
                .map((item) {
                  final d = item['data'];
                  String? imageUrl;
                  if (d['preview'] != null &&
                      d['preview']['images'] != null &&
                      d['preview']['images'].isNotEmpty) {
                    imageUrl = d['preview']['images'][0]['source']['url'];
                  } else if (d['url'] != null &&
                      (d['url'].endsWith('.jpg') ||
                          d['url'].endsWith('.jpeg') ||
                          d['url'].endsWith('.png') ||
                          d['url'].endsWith('.gif'))) {
                    imageUrl = d['url'];
                  } else if (d['thumbnail'] != null &&
                      d['thumbnail'].toString().startsWith('http')) {
                    imageUrl = d['thumbnail'];
                  }
                  return NewsArticle(
                    title: d['title'] ?? '',
                    description: d['selftext'] ?? '',
                    url: 'https://reddit.com${d['permalink']}',
                    imageUrl: imageUrl ?? '',
                    source: d['subreddit'] ?? 'Reddit',
                    publishedAt: DateTime.fromMillisecondsSinceEpoch(
                      (d['created_utc'] != null)
                          ? ((d['created_utc'] as num) * 1000).toInt()
                          : DateTime.now().millisecondsSinceEpoch,
                    ),
                    author: d['author'] ?? '',
                  );
                })
                .whereType<NewsArticle>()
                .where(
                  (a) => a.imageUrl != null && a.imageUrl.toString().isNotEmpty,
                )
                .toList();
        return articles;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading Reddit tech news: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    return [];
  }

  static Future<List<NewsArticle>> fetchNewsApiTechHeadlines({
    int page = 1,
    int pageSize = 20,
  }) async {
    const String apiKey =
        'a14560e959f24c6b86ec00c73fcc22c4'; // Replace with your NewsAPI key
    final url = Uri.parse('https://newsapi.org/v2/top-headlines').replace(
      queryParameters: {
        'category': 'technology',
        'language': 'en',
        'pageSize': pageSize.toString(),
        'page': page.toString(),
        'apiKey': apiKey,
      },
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articles = data['articles'] ?? [];
        return articles
            .map((article) {
              return NewsArticle(
                title: article['title'] ?? '',
                description: article['description'] ?? '',
                url: article['url'] ?? '',
                imageUrl: article['urlToImage'] ?? '',
                source: article['source']?['name'] ?? 'NewsAPI',
                publishedAt:
                    DateTime.tryParse(article['publishedAt'] ?? '') ??
                    DateTime.now(),
                author: article['author'] ?? '',
              );
            })
            .where((a) => a.title.isNotEmpty && a.url.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('Error fetching NewsAPI tech headlines: $e');
    }
    return [];
  }

  static Future<List<NewsArticle>> fetchGNewsTechHeadlines({
    int page = 1,
    int pageSize = 20,
  }) async {
    const String apiKey =
        '9ac72b797fbdfc4d8d2dfdfe1e037b12'; // Replace with your GNews API key
    final url = Uri.parse('https://gnews.io/api/v4/top-headlines').replace(
      queryParameters: {
        'topic': 'technology',
        'lang': 'en',
        'max': pageSize.toString(),
        'page': page.toString(),
        'token': apiKey,
      },
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articles = data['articles'] ?? [];
        return articles
            .map((article) {
              return NewsArticle(
                title: article['title'] ?? '',
                description: article['description'] ?? '',
                url: article['url'] ?? '',
                imageUrl: article['image'] ?? '',
                source:
                    (article['source'] != null &&
                            article['source']['name'] != null)
                        ? article['source']['name']
                        : 'GNews',
                publishedAt:
                    DateTime.tryParse(article['publishedAt'] ?? '') ??
                    DateTime.now(),
                author: article['author'] ?? '',
              );
            })
            .where((a) => a.title.isNotEmpty && a.url.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('Error fetching GNews tech headlines: $e');
    }
    return [];
  }

  static int _memeSubredditIndex = 0;
  static int _memePage = 1;

  static Future<NewsPage?> fetchTechMemes(
    BuildContext context, {
    String? after,
  }) async {
    const List<String> techMemeSubreddits = [
      // Meme subreddits
      'ProgrammerHumor',
      'techsupportanimals',
      'linuxmemes',
      'programmingmemes',
      'codinghumor',
      'softwaregore',
      'techhumor',
      'devhumor',
      'techmemes',
      'ITmemes',
      'pcmasterrace',
      // Software Engineering & Programming
      'technology',
      'programming',
      'learnprogramming',
      'webdev',
      'Frontend',
      'Backend',
      'fullstack',
      'computerscience',
      'softwaredevelopment',
      'coding',
      'algorithms',
      'datastructures',
      'systemdesign',
      'softwarearchitecture',
      // Web Development
      'javascript',
      'reactjs',
      'vuejs',
      'angular',
      'nodejs',
      'webdesign',
      'css',
      'html5',
      'typescript',
      'NextJS',
      'svelte',
      'nuxtjs',
      'tailwindcss',
      'bootstrap',
      'jquery',
      // Mobile App Development
      'flutterdev',
      'dartlang',
      'reactnative',
      'iOSProgramming',
      'swift',
      'AndroidDev',
      'kotlin',
      'xamarin',
      'ionic',
      'appdev',
      'mobiledevelopment',
      // AI/ML & Data Science - Expanded
      'MachineLearning',
      'artificial',
      'datascience',
      'deeplearning',
      'tensorflow',
      'pytorch',
      'jupyter',
      'pandas',
      'numpy',
      'scipy',
      'reinforcementlearning',
      'computervision',
      'NLP',
      'LanguageTechnology',
      'MLQuestions',
      'learnmachinelearning',
      'OpenAI',
      'GPT3',
      'StableDiffusion',
      'AIArt',
      'neuralnetworks',
      'DataEngineering',
      'statistics',
      'rstats',
      'analytics',
      'MLOps',
      'kaggle',
      'huggingface',
      'dalle2',
      'midjourney',
      'llms',
      'chatgpt',
      'gpt4',
      'AIGeneratedArt',
      'AIPromptEngineering',
      'GenerativeAI',
      'AIEthics',
      'AINews',
      'AIresearch',
      'AIforScience',
      'MLEngineering',
      'BigDataAnalytics',
      'DataVisualization',
      'dataanalysis',
      'datascienceproject',
      'MLpapers',
      'scikitlearn',
      'KerasML',
      // FAANG & Big Tech
      'cscareerquestions',
      'ExperiencedDevs',
      'techjobs',
      'engineeringresumes',
      'interviews',
      'leetcode',
      'algorithms',
      'systemdesign',
      'bigtech',
      'faang',
      'remotework',
      // Specific Programming Languages
      'python',
      'java',
      'cplusplus',
      'csharp',
      'golang',
      'rust',
      'php',
      'ruby',
      'scala',
      'haskell',
      'clojure',
      'elixir',
      'erlang',
      // Frameworks & Tools
      'django',
      'flask',
      'rails',
      'laravel',
      'spring',
      'dotnet',
      'express',
      'nestjs',
      'fastapi',
      'gin',
      'fiber',
      // DevOps & Infrastructure
      'devops',
      'docker',
      'kubernetes',
      'aws',
      'azure',
      'googlecloud',
      'terraform',
      'ansible',
      'jenkins',
      'gitlab',
      'github',
      'cicd',
      // Databases
      'database',
      'sql',
      'mongodb',
      'postgresql',
      'mysql',
      'redis',
      'elasticsearch',
      'cassandra',
      'neo4j',
      // UI/UX & Design
      'UI_Design',
      'UXDesign',
      'userexperience',
      'webdesign',
      'graphic_design',
      'adobe',
      'figma',
      'sketch',
      // General Tech
      'Futurology',
      'gadgets',
      'technews',
      'DataIsBeautiful',
      'hardware',
      'computers',
      'cybersecurity',
      'linux',
      'opensource',
      'startups',
      'entrepreneur',
    ];

    print(
      'fetchTechMemes: starting with after=$after, subreddit index=${_memeSubredditIndex}',
    );
    int tried = 0;
    int subredditCount = techMemeSubreddits.length;

    while (tried < subredditCount) {
      final subreddit =
          techMemeSubreddits[_memeSubredditIndex % subredditCount];
      print(
        'fetchTechMemes: trying subreddit $subreddit (${tried + 1}/$subredditCount)',
      );

      final url =
          'https://www.reddit.com/r/$subreddit/hot.json?limit=25${after != null ? '&after=$after' : ''}';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List children = data['data']['children'];
          final afterToken = data['data']['after'];

          print(
            'fetchTechMemes: got ${children.length} posts from $subreddit, after=$afterToken',
          );

          if (children.isNotEmpty) {
            final news =
                children
                    .map((item) {
                      final d = item['data'];
                      String? imageUrl;
                      if (d['preview'] != null &&
                          d['preview']['images'] != null &&
                          d['preview']['images'].isNotEmpty) {
                        imageUrl = d['preview']['images'][0]['source']['url'];
                      } else if (d['url'] != null &&
                          (d['url'].endsWith('.jpg') ||
                              d['url'].endsWith('.jpeg') ||
                              d['url'].endsWith('.png') ||
                              d['url'].endsWith('.gif'))) {
                        imageUrl = d['url'];
                      } else if (d['thumbnail'] != null &&
                          d['thumbnail'].toString().startsWith('http')) {
                        imageUrl = d['thumbnail'];
                      }
                      if (imageUrl != null &&
                          (imageUrl.endsWith('.jpg') ||
                              imageUrl.endsWith('.jpeg') ||
                              imageUrl.endsWith('.png') ||
                              imageUrl.endsWith('.gif'))) {
                        final news = News(
                          postLink: 'https://reddit.com${d['permalink']}',
                          subreddit: d['subreddit'],
                          title: d['title'],
                          url: imageUrl,
                          nsfw: d['over_18'] ?? false,
                          spoiler: d['spoiler'] ?? false,
                          author: d['author'],
                          ups: d['ups'] ?? 0,
                          preview: [imageUrl],
                        );
                        return hasValidImage(news) ? news : null;
                      }
                      return null;
                    })
                    .whereType<News>()
                    .toList();

            print(
              'fetchTechMemes: found ${news.length} valid posts with images',
            );

            // Move to next subreddit for next fetch to ensure variety
            _memeSubredditIndex = (_memeSubredditIndex + 1) % subredditCount;

            if (news.isNotEmpty) {
              // Always return an after token, even if API didn't provide one
              // This ensures we'll try the next page or subreddit
              final nextAfter = afterToken ?? 'next_$_memePage';
              return NewsPage(news, nextAfter);
            }
          }
        }
      } catch (e) {
        print('fetchTechMemes: error fetching from $subreddit: $e');
      }

      // Try next subreddit
      _memeSubredditIndex = (_memeSubredditIndex + 1) % subredditCount;
      tried++;
    }

    // If all subreddits are empty, try next page
    _memePage++;
    print('fetchTechMemes: tried all subreddits, moving to page $_memePage');

    // Always return something to continue pagination
    return NewsPage([], 'page_$_memePage');
  }

  static Future<NewsPage?> fetchTechNewsByCategory(
    BuildContext context, {
    required List<String> categoryKeywords,
    String? after,
  }) async {
    try {
      // Randomly select a tech subreddit based on category keywords
      final subreddit = categoryKeywords.first;
      final url =
          'https://www.reddit.com/r/$subreddit/hot.json?limit=25${after != null ? '&after=$after' : ''}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List children = data['data']['children'];
        if (children.isEmpty) return NewsPage([], null);
        final news =
            children
                .map((item) {
                  final d = item['data'];
                  String? imageUrl;
                  if (d['preview'] != null &&
                      d['preview']['images'] != null &&
                      d['preview']['images'].isNotEmpty) {
                    imageUrl = d['preview']['images'][0]['source']['url'];
                  } else if (d['url'] != null &&
                      (d['url'].endsWith('.jpg') ||
                          d['url'].endsWith('.jpeg') ||
                          d['url'].endsWith('.png') ||
                          d['url'].endsWith('.gif'))) {
                    imageUrl = d['url'];
                  } else if (d['thumbnail'] != null &&
                      d['thumbnail'].toString().startsWith('http')) {
                    imageUrl = d['thumbnail'];
                  }
                  return News(
                    postLink: 'https://reddit.com${d['permalink']}',
                    subreddit: d['subreddit'],
                    title: d['title'],
                    url: imageUrl ?? '',
                    nsfw: d['over_18'] ?? false,
                    spoiler: d['spoiler'] ?? false,
                    author: d['author'],
                    ups: d['ups'] ?? 0,
                    preview: imageUrl != null ? [imageUrl] : null,
                  );
                })
                .whereType<News>()
                .where((n) => hasValidImage(n))
                .toList();
        final afterToken = data['data']['after'];
        return NewsPage(news, afterToken);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading category news: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    return NewsPage([], null);
  }

  static Future<NewsPage?> fetchTrendingNews(
    BuildContext context, {
    String? after,
  }) async {
    const List<String> trendingSubreddits = [
      // General trending
      'all',
      'popular',
      'trending',
      'technology',
      'science',
      'worldnews',
      'news',
      // Programming & Tech
      'programming',
      'tech',
      'futurology',
      'gadgets',
      'apple',
      'android',
      'microsoft',
      'google',
      'tesla',
      'spacex',
      // AI/ML Trending
      'MachineLearning',
      'artificial',
      'OpenAI',
      'chatgpt',
      'gpt4',
      'AIGeneratedArt',
      'StableDiffusion',
      'AINews',
      'AIart',
      'midjourney',
      'dalle2',
      'GenerativeAI',
      'AIEthics',
      'AIresearch',
      'datascience',
      'deeplearning',
    ];

    print('fetchTrendingNews: starting with after=$after');
    int tried = 0;
    int maxTries = 5; // Try up to 5 subreddits before giving up

    while (tried < maxTries) {
      // Randomly select a trending subreddit
      final subreddit = (List.of(trendingSubreddits)..shuffle()).first;
      print(
        'fetchTrendingNews: trying subreddit $subreddit (${tried + 1}/$maxTries)',
      );

      final url =
          'https://www.reddit.com/r/$subreddit/hot.json?limit=25${after != null ? '&after=$after' : ''}';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List children = data['data']['children'];
          final afterToken = data['data']['after'];

          print(
            'fetchTrendingNews: got ${children.length} posts from $subreddit, after=$afterToken',
          );

          if (children.isNotEmpty) {
            final news =
                children
                    .map((item) {
                      final d = item['data'];
                      String? imageUrl;
                      if (d['preview'] != null &&
                          d['preview']['images'] != null &&
                          d['preview']['images'].isNotEmpty) {
                        imageUrl = d['preview']['images'][0]['source']['url'];
                      } else if (d['url'] != null &&
                          (d['url'].endsWith('.jpg') ||
                              d['url'].endsWith('.jpeg') ||
                              d['url'].endsWith('.png') ||
                              d['url'].endsWith('.gif'))) {
                        imageUrl = d['url'];
                      } else if (d['thumbnail'] != null &&
                          d['thumbnail'].toString().startsWith('http')) {
                        imageUrl = d['thumbnail'];
                      }
                      return News(
                        postLink: 'https://reddit.com${d['permalink']}',
                        subreddit: d['subreddit'],
                        title: d['title'],
                        url: imageUrl ?? '',
                        nsfw: d['over_18'] ?? false,
                        spoiler: d['spoiler'] ?? false,
                        author: d['author'],
                        ups: d['ups'] ?? 0,
                        preview: imageUrl != null ? [imageUrl] : null,
                      );
                    })
                    .whereType<News>()
                    .where((n) => hasValidImage(n))
                    .toList();

            print(
              'fetchTrendingNews: found ${news.length} valid posts with images',
            );

            if (news.isNotEmpty) {
              // Always return an after token, even if API didn't provide one
              final nextAfter =
                  afterToken ??
                  'trending_next_${DateTime.now().millisecondsSinceEpoch}';
              return NewsPage(news, nextAfter);
            }
          }
        }
      } catch (e) {
        print('fetchTrendingNews: error fetching from $subreddit: $e');
      }

      tried++;
    }

    // If all attempts failed, still return a token to try again later
    print(
      'fetchTrendingNews: tried $maxTries subreddits, returning empty page with next token',
    );
    return NewsPage(
      [],
      'trending_retry_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

abstract class InfiniteNewsController extends ChangeNotifier {
  List<News> news = [];
  String? newsAfter;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isError = false;
  bool noMoreNews = false;
  BuildContext? context;

  InfiniteNewsController({this.context});

  Future<NewsPage?> fetchPage({required int page, String? after});

  Future<void> fetchInitialNews() async {
    isLoading = true;
    isError = false;
    newsAfter = null;
    noMoreNews = false;
    news.clear();
    notifyListeners();
    try {
      await _fetchUntilValid(page: 1, after: null, append: false);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      isError = true;
      notifyListeners();
    }
  }

  Future<void> fetchMoreNews() async {
    if (isLoadingMore || newsAfter == null || noMoreNews) return;
    isLoadingMore = true;
    notifyListeners();
    try {
      await _fetchUntilValid(
        page: int.tryParse(newsAfter ?? '1') ?? 1,
        after: newsAfter,
        append: true,
      );
      isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUntilValid({
    required int page,
    String? after,
    required bool append,
  }) async {
    print('_fetchUntilValid called: page=$page, after=$after, append=$append');
    int tries = 0;
    int maxTries = 3; // Reduced from 10 to 3 for faster iteration

    while (tries < maxTries) {
      print('Fetch attempt ${tries + 1}/$maxTries for page $page');
      final newsPage = await fetchPage(page: page, after: after);

      // If the API returned nothing at all, stop
      if (newsPage == null) {
        print('NewsPage is null, stopping');
        newsAfter = null;
        noMoreNews = true;
        return;
      }

      print('Received ${newsPage.items.length} items, after=${newsPage.after}');
      final validNews =
          (newsPage.items).where((n) => hasValidImage(n)).toList();
      print('Found ${validNews.length} valid items after filtering');

      if (validNews.isNotEmpty) {
        final existingUrls = news.map((n) => n.url).toSet();
        final uniqueNewItems =
            validNews.where((n) => !existingUrls.contains(n.url)).toList();
        print('Adding ${uniqueNewItems.length} unique new items');
        if (append) {
          news.addAll(uniqueNewItems);
        } else {
          news = uniqueNewItems;
        }

        // Always provide a next page token, even if the API didn't return one
        // This ensures we'll try the next page or cycle through subreddits
        newsAfter = newsPage.after ?? (page + 1).toString();
        noMoreNews = false;
        print('Success! Total news: ${news.length}, hasMore: true');
        return;
      } else {
        // No valid items found, try next page or increment counter
        print('No valid items found, trying next page/after token');
        after = newsPage.after ?? (page + 1).toString();
        page = int.tryParse(after) ?? (page + 1);
        tries++;
      }
    }

    // If we tried max times and got nothing, we'll still continue
    // by providing a next page token to try again later
    print('Reached max tries ($maxTries), but will continue with next page');
    newsAfter = (page + 1).toString();
    noMoreNews = false;
  }

  void setContext(BuildContext ctx) {
    context = ctx;
  }
}

class TechNewsController extends InfiniteNewsController {
  TechNewsController({BuildContext? context}) : super(context: context);
  @override
  Future<NewsPage?> fetchPage({required int page, String? after}) {
    return NewsService.fetchAllTechNews(context!, page: page, after: after);
  }
}

class TrendingNewsController extends InfiniteNewsController {
  TrendingNewsController({BuildContext? context}) : super(context: context);
  @override
  Future<NewsPage?> fetchPage({required int page, String? after}) {
    return NewsService.fetchTrendingNews(context!, after: after);
  }
}

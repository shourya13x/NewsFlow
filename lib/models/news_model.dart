class NewsModel {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String source;
  final String content;
  final String author;
  final String category;

  NewsModel({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.source,
    required this.content,
    required this.author,
    required this.category,
  });

  factory NewsModel.fromJson(
    Map<String, dynamic> json, {
    String category = 'general',
  }) {
    return NewsModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage:
          json['urlToImage'] ?? json['image'] ?? json['image_url'] ?? '',
      publishedAt: json['publishedAt'] ?? json['published_at'] ?? '',
      source:
          json['source'] is Map
              ? json['source']['name'] ?? ''
              : json['source'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      category: category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'source': source,
      'content': content,
      'author': author,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'NewsModel(title: $title, source: $source, url: $url)';
  }
}

// Legacy News class for backward compatibility
class News {
  late String postLink;
  late String subreddit;
  late String title;
  late String url;
  late bool nsfw;
  late bool spoiler;
  late String author;
  late int ups;
  List<String>? preview;
  late String description;

  News({
    this.postLink = '',
    this.subreddit = '',
    this.title = '',
    this.url = '',
    this.nsfw = false,
    this.spoiler = false,
    this.author = '',
    this.ups = 0,
    this.preview,
    this.description = '',
  });

  News.fromJson(Map<String, dynamic> json) {
    postLink = json['postLink'] ?? '';
    subreddit = json['subreddit'] ?? '';
    title = json['title'] ?? '';
    url = json['url'] ?? '';
    nsfw = json['nsfw'] ?? false;
    spoiler = json['spoiler'] ?? false;
    author = json['author'] ?? '';
    ups = json['ups'] ?? 0;
    preview = json['preview']?.cast<String>();
    description = json['description'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postLink'] = postLink;
    data['subreddit'] = subreddit;
    data['title'] = title;
    data['url'] = url;
    data['nsfw'] = nsfw;
    data['spoiler'] = spoiler;
    data['author'] = author;
    data['ups'] = ups;
    data['preview'] = preview;
    data['description'] = description;
    return data;
  }
}

bool hasValidImage(News news) {
  if (news.url.isEmpty) return false;

  final url = news.url.toLowerCase();

  // Explicitly reject these patterns
  if (url.contains('no+image') ||
      url.contains('placeholder') ||
      url.contains('default.') ||
      url.contains('noimage') ||
      url.endsWith('.svg') ||
      url.endsWith('.ico')) {
    return false;
  }

  // Explicitly accept common image extensions
  if (url.endsWith('.jpg') ||
      url.endsWith('.jpeg') ||
      url.endsWith('.png') ||
      url.endsWith('.webp') ||
      url.endsWith('.gif')) {
    return true;
  }

  // Accept Reddit and Imgur URLs which typically contain images
  if (url.contains('i.redd.it') ||
      url.contains('i.imgur.com') ||
      url.contains('imgur.com/') ||
      url.contains('redditmedia.com') ||
      url.contains('redditstatic.com')) {
    return true;
  }

  // Accept http(s) images that are not explicitly rejected above
  return url.startsWith('http') && url.length > 10;
}

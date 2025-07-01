import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../main.dart';

class ArticleDetailScreen extends StatefulWidget {
  final NewsModel article;
  final int notificationCount;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    this.notificationCount = 3,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  String _formatTimeAgo(String publishedAt) {
    try {
      final publishedDate = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final difference = now.difference(publishedDate);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '5 hours ago'; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: Container(
            margin: const EdgeInsets.only(left: 16),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          title: Text(
            'NEWS',
            style: TextStyle(
              color: const Color(0xFFFF4757),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // Handle notification tap
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  if (widget.notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4757),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${widget.notificationCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              height: 280,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 80, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: widget.article.urlToImage,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color:
                            isDark ? const Color(0xFF1A1A1A) : Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF4757),
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color:
                            isDark ? const Color(0xFF1A1A1A) : Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                          size: 48,
                        ),
                      ),
                ),
              ),
            ),

            // Article Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article Title
                  Text(
                    widget.article.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Author and Time Row
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.article.author.isNotEmpty
                            ? widget.article.author
                            : 'Unknown Author',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(widget.article.publishedAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFFFF4757),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Article Body
                  Text(
                    _getArticleBody(),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color:
                          isDark ? Colors.grey[300] : const Color(0xFF2A2A2A),
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Source and Share Actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isDark
                                ? const Color(0xFF2A2A2A)
                                : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF4757,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.article.source,
                            style: const TextStyle(
                              color: Color(0xFFFF4757),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            // Handle share
                          },
                          icon: Icon(
                            Icons.share_rounded,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Consumer<FavoritesProvider>(
                          builder: (context, favoritesProvider, child) {
                            final isFavorite = favoritesProvider.isFavorite(
                              widget.article.url,
                            );
                            return IconButton(
                              onPressed: () {
                                favoritesProvider.toggleFavorite(
                                  widget.article,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isFavorite
                                          ? 'Removed from favorites!'
                                          : 'Added to favorites!',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(
                                isFavorite
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color:
                                    isFavorite
                                        ? const Color(0xFFFF4757)
                                        : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getArticleBody() {
    String content = widget.article.content;
    if (content.isEmpty) {
      content = widget.article.description;
    }

    if (content.isEmpty) {
      content =
          '''In a groundbreaking development, researchers from the Harvard Research Group at CU Boulder have unveiled a novel photomechanical material that has the potential to revolutionize various industries by converting light energy into mechanical work.

This innovative material, described in a study published in Nature Materials, opens doors to energy-efficient and wirelessly controlled systems, paving the way for advancements in robotics, aerospace, and biomedical devices.

Beyond Traditional Actuators

Traditional methods of converting energy often involve multiple stages, leading to inefficiencies and the added bulk of energy stores such as batteries. However, the new photomechanical material developed by CU Boulder scientists represents a paradigm shift in how we think about energy conversion and mechanical work.''';
    }

    // Clean up common content artifacts
    content = content.replaceAll('[+\\d+ chars]', '');
    content = content.replaceAll(RegExp(r'\[\+\d+\s+chars\]'), '');

    return content;
  }
}

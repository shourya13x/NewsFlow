import 'package:newsflow/main.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsflow/screens/article_detail_screen.dart';
import 'package:newsflow/models/news_model.dart';
import 'package:provider/provider.dart';

class NewsCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final int ups;
  final String postLink;
  final int index;
  final String subreddit;

  const NewsCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.ups,
    required this.postLink,
    required this.index,
    required this.subreddit,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 80)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    final favoritesProvider = Provider.of<FavoritesProvider>(
      context,
      listen: false,
    );

    // Create a NewsModel from the current article data
    final newsModel = NewsModel(
      title: widget.title,
      description: 'Read the full article to learn more about this story.',
      url: widget.postLink,
      urlToImage: widget.imageUrl,
      publishedAt:
          DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      source: widget.subreddit,
      content:
          '''In a groundbreaking development, researchers from leading institutions have unveiled significant findings that could impact various industries.

This innovative research, recently published in top-tier journals, opens doors to new possibilities and applications across multiple fields.

The implications of this work extend far beyond traditional boundaries, potentially revolutionizing how we approach current challenges and creating new opportunities for advancement.

Further analysis and peer review continue to validate these remarkable discoveries, with experts anticipating widespread adoption and implementation in the coming months.''',
      author: 'NewsFlow Reporter',
      category: 'general',
    );

    favoritesProvider.toggleFavorite(newsModel);

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          favoritesProvider.isFavorite(widget.postLink)
              ? 'Added to favorites!'
              : 'Removed from favorites!',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareArticle() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showNewsDetails(BuildContext context) {
    // Convert current data to NewsModel for the new screen
    final newsModel = NewsModel(
      title: widget.title,
      description: 'Read the full article to learn more about this story.',
      url: widget.postLink,
      urlToImage: widget.imageUrl,
      publishedAt:
          DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      source: widget.subreddit,
      content:
          '''In a groundbreaking development, researchers from leading institutions have unveiled significant findings that could impact various industries.

This innovative research, recently published in top-tier journals, opens doors to new possibilities and applications across multiple fields.

The implications of this work extend far beyond traditional boundaries, potentially revolutionizing how we approach current challenges and creating new opportunities for advancement.

Further analysis and peer review continue to validate these remarkable discoveries, with experts anticipating widespread adoption and implementation in the coming months.''',
      author: 'NewsFlow Reporter',
      category: 'general',
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ArticleDetailScreen(
              article: newsModel,
              notificationCount: 3,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isHovered ? 1.02 : _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(
                        alpha: _isHovered ? 0.15 : 0.08,
                      ),
                      blurRadius: _isHovered ? 20 : 12,
                      offset: Offset(0, _isHovered ? 8 : 4),
                      spreadRadius: _isHovered ? 1 : 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showNewsDetails(context),
                      borderRadius: BorderRadius.circular(16),
                      splashColor: colorScheme.primary.withValues(alpha: 0.1),
                      highlightColor: colorScheme.primary.withValues(
                        alpha: 0.05,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section
                            Expanded(
                              flex: 3,
                              child: Stack(
                                children: [
                                  // Background Image
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                    child: Hero(
                                      tag: 'news_${widget.imageUrl}',
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              widget.imageUrl.isNotEmpty
                                                  ? getImageUrl(widget.imageUrl)
                                                  : 'https://via.placeholder.com/600x400?text=No+Image',
                                          fit: BoxFit.cover,
                                          maxHeightDiskCache: 1500,
                                          memCacheHeight: 1000,
                                          fadeInDuration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          placeholderFadeInDuration:
                                              const Duration(milliseconds: 200),
                                          placeholder:
                                              (context, url) => Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      colorScheme.primary
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      colorScheme.secondary
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                    ],
                                                  ),
                                                ),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color:
                                                            colorScheme.primary,
                                                      ),
                                                ),
                                              ),
                                          errorWidget:
                                              (
                                                context,
                                                url,
                                                error,
                                              ) => Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      colorScheme.primary
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      colorScheme.secondary
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                    ],
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_rounded,
                                                  size: 48,
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Gradient overlay for better text readability
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.2),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Source badge
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.9,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        widget.subreddit,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Upvotes badge
                                  if (widget.ups > 0)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.7,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.arrow_upward_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${widget.ups}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Content Section
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Expanded(
                                      child: Text(
                                        widget.title,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                          height: 1.3,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Action buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Read More button
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed:
                                                () => _showNewsDetails(context),
                                            icon: const Icon(
                                              Icons.read_more_rounded,
                                              size: 16,
                                            ),
                                            label: const Text('Read More'),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              minimumSize: const Size(0, 32),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // Action buttons
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: _shareArticle,
                                              icon: const Icon(
                                                Icons.share_rounded,
                                                size: 18,
                                              ),
                                              tooltip: 'Share',
                                              style: IconButton.styleFrom(
                                                minimumSize: const Size(32, 32),
                                                padding: EdgeInsets.zero,
                                              ),
                                            ),
                                            Consumer<FavoritesProvider>(
                                              builder: (
                                                context,
                                                favoritesProvider,
                                                child,
                                              ) {
                                                final isFavorite =
                                                    favoritesProvider
                                                        .isFavorite(
                                                          widget.postLink,
                                                        );
                                                return IconButton(
                                                  onPressed: _toggleBookmark,
                                                  icon: Icon(
                                                    isFavorite
                                                        ? Icons.bookmark_rounded
                                                        : Icons
                                                            .bookmark_outline_rounded,
                                                    size: 18,
                                                    color:
                                                        isFavorite
                                                            ? colorScheme
                                                                .primary
                                                            : null,
                                                  ),
                                                  tooltip:
                                                      isFavorite
                                                          ? 'Remove from favorites'
                                                          : 'Add to favorites',
                                                  style: IconButton.styleFrom(
                                                    minimumSize: const Size(
                                                      32,
                                                      32,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

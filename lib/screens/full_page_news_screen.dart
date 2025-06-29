import 'package:flutter/material.dart';
import 'package:api_integration/services/news_service.dart';
import 'package:api_integration/models/news_model.dart';
import 'package:api_integration/screens/news_card_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:provider/provider.dart';

class FullPageNewsScreen extends StatefulWidget {
  const FullPageNewsScreen({super.key});

  @override
  State<FullPageNewsScreen> createState() => _FullPageNewsScreenState();
}

class _FullPageNewsScreenState extends State<FullPageNewsScreen>
    with TickerProviderStateMixin {
  late TechNewsController newsController;
  int currentIndex = 0;

  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    newsController = TechNewsController(context: context);
    newsController.fetchInitialNews();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    if (!newsController.isLoadingMore &&
        newsController.newsAfter != null &&
        _pageController.page != null &&
        _pageController.page!.round() >= newsController.news.length - 2) {
      newsController.fetchMoreNews();
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    newsController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    _scaleController.reset();
    _scaleController.forward();
  }

  void _showNewsDetails(News news) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: NewsCardScreen(
              title: news.title,
              imageUrl: news.url,
              ups: news.ups,
              postLink: news.postLink,
              subreddit: news.subreddit,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
      value: newsController,
      child: Consumer<TechNewsController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return Scaffold(
              backgroundColor: colorScheme.surface,
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.isError) {
            return Scaffold(
              backgroundColor: colorScheme.surface,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load news',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: controller.fetchInitialNews,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (controller.news.isEmpty) {
            return Scaffold(
              backgroundColor: colorScheme.surface,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.newspaper_outlined,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No news available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try refreshing to get the latest updates',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: controller.fetchInitialNews,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            backgroundColor: colorScheme.surface,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.8),
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outline.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.newspaper_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'News Explorer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${currentIndex + 1} of ${controller.news.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: controller.fetchInitialNews,
                  tooltip: 'Refresh',
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_outline_rounded),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to favorites!')),
                    );
                  },
                  tooltip: 'Add to favorites',
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  if (currentIndex > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                } else if (details.primaryVelocity! < 0) {
                  if (currentIndex <
                      controller.news.length -
                          1 +
                          (controller.isLoadingMore ||
                                  controller.newsAfter != null
                              ? 1
                              : 0)) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                }
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  _onPageChanged(index);
                  if (index == controller.news.length &&
                      (controller.isLoadingMore ||
                          controller.newsAfter != null)) {
                    controller.fetchMoreNews();
                  }
                },
                itemCount:
                    controller.news.length +
                    (controller.isLoadingMore || controller.newsAfter != null
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (index < controller.news.length) {
                    final news = controller.news[index];
                    return _buildNewsCard(news, index);
                  } else {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Loading more news...',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.9),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed:
                        currentIndex > 0
                            ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                            : null,
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    tooltip: 'Previous',
                  ),
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: colorScheme.outline.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            (currentIndex + 1) / controller.news.length,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        currentIndex < controller.news.length - 1
                            ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                            : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    tooltip: 'Next',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(News news, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showNewsDetails(news),
                      child: Container(
                        decoration: BoxDecoration(color: colorScheme.surface),
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
                                    child: Hero(
                                      tag: 'news_${news.url}_$index',
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            news.url.isNotEmpty
                                                ? news.url
                                                : 'https://via.placeholder.com/600x400?text=No+Image',
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (context, url) => Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    colorScheme.primary
                                                        .withOpacity(0.1),
                                                    colorScheme.secondary
                                                        .withOpacity(0.1),
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
                                            (context, url, error) => Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    colorScheme.primary
                                                        .withOpacity(0.1),
                                                    colorScheme.secondary
                                                        .withOpacity(0.1),
                                                  ],
                                                ),
                                              ),
                                              child: Icon(
                                                Icons
                                                    .image_not_supported_rounded,
                                                size: 48,
                                                color: colorScheme.onSurface
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),

                                  // Gradient overlay
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Source badge
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(
                                          0.9,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        news.subreddit,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Upvotes badge
                                  if (news.ups > 0)
                                    Positioned(
                                      top: 16,
                                      right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.arrow_upward_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${news.ups}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
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
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Expanded(
                                      child: Text(
                                        news.title,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                          height: 1.3,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Description
                                    if (news.description.isNotEmpty)
                                      Expanded(
                                        child: Text(
                                          news.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colorScheme.onSurface
                                                .withOpacity(0.7),
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                    const SizedBox(height: 16),

                                    // Action buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed:
                                                () => _showNewsDetails(news),
                                            icon: const Icon(
                                              Icons.read_more_rounded,
                                            ),
                                            label: const Text('Read More'),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          onPressed: () {
                                            // TODO: Share functionality
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Share feature coming soon!',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.share_rounded),
                                          tooltip: 'Share',
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            // TODO: Bookmark functionality
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Added to favorites!',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.bookmark_outline_rounded,
                                          ),
                                          tooltip: 'Add to favorites',
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

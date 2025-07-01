import 'package:flutter/material.dart';
import 'package:newsflow/services/news_service.dart';
import 'package:newsflow/widgets/news_card.dart';
import 'package:newsflow/screens/full_page_news_screen.dart';
import 'package:provider/provider.dart';

class TechScreen extends StatefulWidget {
  final Function(VoidCallback)? onRefreshCallback;
  final String category;

  const TechScreen({super.key, required this.category, this.onRefreshCallback});

  @override
  State<TechScreen> createState() => _TechScreenState();
}

class _TechScreenState extends State<TechScreen> {
  late TechNewsController newsController;
  final ScrollController _scrollController = ScrollController();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    newsController = TechNewsController(
      context: context,
      category: widget.category,
    );
    newsController.fetchInitialNews();
    _scrollController.addListener(_onScroll);

    // Register refresh callback
    widget.onRefreshCallback?.call(refreshNews);
  }

  void refreshNews() {
    if (!_isDisposed && mounted) {
      newsController.fetchInitialNews(isRefresh: true);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    newsController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TechScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      newsController.dispose();
      newsController = TechNewsController(
        context: context,
        category: widget.category,
      );
      newsController.fetchInitialNews(isRefresh: true);
      setState(() {});
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      if (!newsController.isLoadingMore && newsController.newsAfter != null) {
        newsController.fetchMoreNews();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChangeNotifierProvider.value(
      value: newsController,
      child: Consumer<TechNewsController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load news.',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed:
                        () => controller.fetchInitialNews(isRefresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => controller.fetchInitialNews(isRefresh: true),
            child: GridView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.75,
                mainAxisSpacing: 20,
              ),
              itemCount:
                  controller.news.length +
                  (controller.isLoadingMore || controller.newsAfter != null
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index < controller.news.length) {
                  final news = controller.news[index];
                  return NewsCard(
                    title: news.title,
                    imageUrl: news.url,
                    ups: news.ups,
                    postLink: news.postLink,
                    index: index,
                    subreddit: news.subreddit,
                  );
                } else {
                  // Loading indicator at the end
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colorScheme.surfaceContainer,
                    ),
                    child: const Center(
                      child: SizedBox(
                        height: 40,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

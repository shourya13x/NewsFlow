import 'package:flutter/material.dart';
import 'package:newsflow/services/news_service.dart';
import 'package:newsflow/widgets/news_card.dart';
import 'package:provider/provider.dart';

class TrendingScreen extends StatefulWidget {
  final Function(VoidCallback)? onRefreshCallback;

  const TrendingScreen({super.key, this.onRefreshCallback});

  @override
  State<TrendingScreen> createState() => TrendingScreenState();
}

class TrendingScreenState extends State<TrendingScreen> {
  late TrendingNewsController newsController;
  final ScrollController _scrollController = ScrollController();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    newsController = TrendingNewsController(context: context);
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      if (!newsController.isLoadingMore &&
          newsController.newsAfter != null &&
          !newsController.noMoreNews) {
        newsController.fetchMoreNews();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChangeNotifierProvider.value(
      value: newsController,
      child: Consumer<TrendingNewsController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load trending news.',
                    style: TextStyle(color: colorScheme.outline),
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
                } else if (controller.noMoreNews) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No more news',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  );
                } else {
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

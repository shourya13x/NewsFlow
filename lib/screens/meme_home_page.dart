import 'package:api_integration/models/meme_model.dart';
import 'package:api_integration/widgets/meme_card.dart';
import 'package:flutter/material.dart';
import 'package:api_integration/services/meme_service.dart';

class MemeHomePage extends StatefulWidget {
  const MemeHomePage({super.key});

  @override
  State<MemeHomePage> createState() => _MemeHomePageState();
}

class _MemeHomePageState extends State<MemeHomePage>
    with TickerProviderStateMixin {
  List<Meme> memes = [];
  List<Meme> favoriteMemes = [];
  bool isLoading = true;
  bool isError = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchMemes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !isLoadingMore &&
        !isLoading &&
        !isError) {
      loadMoreMemes();
    }
  }

  Future<void> loadMoreMemes() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final newMemes = await MemeService.fetchMemes(
        context,
        page: currentPage + 1,
      );
      if (!mounted) return;

      if (newMemes != null && newMemes.isNotEmpty) {
        setState(() {
          memes.addAll(newMemes);
          currentPage++;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> fetchMemes() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isError = false;
      currentPage = 1;
    });

    try {
      final fetchedMemes = await MemeService.fetchMemes(context);
      if (!mounted) return;

      setState(() {
        memes = fetchedMemes ?? [];
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: colorScheme.surfaceContainerLowest,
      drawer: _buildDrawer(colorScheme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE91E63).withOpacity(0.05),
              const Color(0xFF2196F3).withOpacity(0.03),
              const Color(0xFFFF9800).withOpacity(0.02),
              colorScheme.surface,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            _buildAnimatedAppBar(colorScheme),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    memes.clear();
                    currentPage = 1;
                  });
                  await fetchMemes();
                },
                backgroundColor: colorScheme.surface,
                color: colorScheme.primary,
                child: _buildBody(colorScheme),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
    );
  }

  Widget _buildAnimatedAppBar(ColorScheme colorScheme) {
    return Builder(
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE91E63).withOpacity(0.15),
                  const Color(0xFF2196F3).withOpacity(0.12),
                  const Color(0xFFFF9800).withOpacity(0.10),
                  const Color(0xFF9C27B0).withOpacity(0.08),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mood_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Meme Explorer",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              foreground:
                                  Paint()
                                    ..shader = const LinearGradient(
                                      colors: [
                                        Color(0xFFE91E63),
                                        Color(0xFF2196F3),
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 200, 70),
                                    ),
                            ),
                          ),
                          Text(
                            "Discover amazing memes",
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2196F3).withOpacity(0.3),
                            const Color(0xFF9C27B0).withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            memes.clear();
                            currentPage = 1;
                          });
                          fetchMemes();
                        },
                        tooltip: 'Refresh memes',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      icon: const Icon(Icons.keyboard_arrow_up_rounded),
      label: const Text("Top"),
      backgroundColor: const Color(0xFFFF9800),
      foregroundColor: Colors.white,
      elevation: 12,
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE91E63).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE91E63).withOpacity(0.2),
                    const Color(0xFF2196F3).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                '✨ Loading awesome memes...',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF5722).withOpacity(0.1),
                  const Color(0xFFFF9800).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFF5722).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Oops! Couldn't load memes",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Check your internet connection and try again",
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: FilledButton.icon(
                    onPressed: fetchMemes,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Try Again"),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (memes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF9800).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No memes found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try refreshing to load some fresh content",
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.75,
                mainAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final meme = memes[index];
                return MemeCard(
                  title: meme.title ?? '',
                  imageUrl: meme.url ?? '',
                  ups: meme.ups ?? 0,
                  postLink: meme.postLink ?? '',
                  index: index,
                  subreddit: meme.subreddit ?? '',
                );
              }, childCount: memes.length),
            ),
          ),
          if (isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF2196F3).withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
        physics: const BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE91E63).withOpacity(0.1),
              const Color(0xFF2196F3).withOpacity(0.08),
              const Color(0xFFFF9800).withOpacity(0.06),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE91E63).withOpacity(0.2),
                    const Color(0xFF2196F3).withOpacity(0.15),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE91E63).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Meme Explorer",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      foreground:
                          Paint()
                            ..shader = const LinearGradient(
                              colors: [Color(0xFFE91E63), Color(0xFF2196F3)],
                            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Your favorite memes",
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_rounded,
                    title: "Home",
                    subtitle: "Discover new memes",
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.favorite_rounded,
                    title: "Favorites",
                    subtitle: "Your saved memes",
                    color: const Color(0xFFFF5722),
                    onTap: () {
                      Navigator.pop(context);
                      _showFavorites(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.trending_up_rounded,
                    title: "Trending",
                    subtitle: "Popular memes",
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.pop(context);
                      _showTrending(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: "Settings",
                    subtitle: "App preferences",
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.pop(context);
                      _showSettings(context);
                    },
                  ),

                  const Divider(height: 32, thickness: 1),

                  // Favorites Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Text(
                      "Recent Favorites",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  // Actual favorite memes
                  if (favoriteMemes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No favorites yet",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap the heart icon on memes to add them here",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...favoriteMemes
                        .take(10)
                        .map(
                          (meme) => _buildFavoriteMemeItem(
                            title: meme.title ?? 'Untitled Meme',
                            imageUrl: meme.url ?? '',
                            color: const Color(0xFFE91E63),
                            onTap: () {
                              Navigator.pop(context);
                              _showMemeDetails(context, meme);
                            },
                            onLongPress: () {
                              removeFromFavorites(meme);
                            },
                          ),
                        )
                        .toList(),
                ],
              ),
            ),

            // Drawer Footer
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFE91E63).withOpacity(0.2),
                          const Color(0xFF2196F3).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Meme Explorer v1.0",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          "Made with ❤️ by Shourya",
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      onTap: onTap,
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildFavoriteMemeItem({
    required String title,
    required String imageUrl,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return ListTile(
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    Icon(Icons.image_rounded, color: Colors.white, size: 24),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "Tap to view",
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  void _showFavorites(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favorites feature coming soon! ❤️'),
        backgroundColor: Color(0xFFE91E63),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTrending(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trending memes coming soon! 🔥'),
        backgroundColor: Color(0xFFFF9800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings coming soon! ⚙️'),
        backgroundColor: Color(0xFF9C27B0),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMemeDetails(BuildContext context, Meme meme) {
    // Implement the logic to show meme details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening meme details'),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Add meme to favorites
  void addToFavorites(Meme meme) {
    if (!favoriteMemes.any((m) => m.url == meme.url)) {
      setState(() {
        favoriteMemes.add(meme);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❤️ Added to favorites!'),
          backgroundColor: const Color(0xFFE91E63),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View Favorites',
            textColor: Colors.white,
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already in favorites! ❤️'),
          backgroundColor: Color(0xFFFF5722),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Remove meme from favorites
  void removeFromFavorites(Meme meme) {
    setState(() {
      favoriteMemes.removeWhere((m) => m.url == meme.url);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites 💔'),
        backgroundColor: Color(0xFF9C27B0),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

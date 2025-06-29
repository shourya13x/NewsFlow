import 'package:flutter/material.dart';
import 'package:api_integration/screens/tech_screen.dart';
import 'package:api_integration/screens/trending_screen.dart';
import 'package:api_integration/screens/favorites_screen.dart';
import 'package:api_integration/screens/settings_screen.dart';
import 'dart:ui';

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Refresh callbacks for each screen
  VoidCallback? _techScreenRefresh;
  VoidCallback? _trendingScreenRefresh;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TechScreen(
        onRefreshCallback: (callback) => _techScreenRefresh = callback,
      ),
      TrendingScreen(
        onRefreshCallback: (callback) => _trendingScreenRefresh = callback,
      ),
      const FavoritesScreen(),
      const SettingsScreen(),
    ];
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _refreshCurrentScreen() {
    switch (_currentIndex) {
      case 0: // Tech Screen
        _techScreenRefresh?.call();
        break;
      case 1: // Trending Screen
        _trendingScreenRefresh?.call();
        break;
      case 2: // Favorites Screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorites refreshed!'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 3: // Settings Screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings screen - nothing to refresh'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
    }
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'News Explorer';
      case 1:
        return 'Trending Stories';
      case 2:
        return 'Saved Articles';
      case 3:
        return 'Settings';
      default:
        return 'News Explorer';
    }
  }

  IconData _getAppBarIcon() {
    switch (_currentIndex) {
      case 0:
        return Icons.newspaper_rounded;
      case 1:
        return Icons.trending_up_rounded;
      case 2:
        return Icons.bookmark_rounded;
      case 3:
        return Icons.settings_rounded;
      default:
        return Icons.newspaper_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAppBarIcon(),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getAppBarTitle(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search feature coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _refreshCurrentScreen,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // Very light blue
              Color(0xFFF5F5F5), // Light grey
              Color(0xFFFFFFFF), // White
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: NavigationBar(
            elevation: 0,
            backgroundColor: Colors.white.withOpacity(0.9),
            selectedIndex: _currentIndex,
            onDestinationSelected: _onItemTapped,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.newspaper_outlined),
                selectedIcon: const Icon(Icons.newspaper_rounded),
                label: 'News',
              ),
              NavigationDestination(
                icon: const Icon(Icons.trending_up_outlined),
                selectedIcon: const Icon(Icons.trending_up_rounded),
                label: 'Trending',
              ),
              NavigationDestination(
                icon: const Icon(Icons.bookmark_outline_rounded),
                selectedIcon: const Icon(Icons.bookmark_rounded),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

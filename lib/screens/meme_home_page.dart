import 'package:api_integration/models/meme_model.dart';
import 'package:api_integration/widegts/meme_card.dart';
import 'package:flutter/material.dart';
import 'package:api_integration/services/meme_service.dart';

class MemeHomePage extends StatefulWidget {
  const MemeHomePage({super.key});

  @override
  State<MemeHomePage> createState() => _MemeHomePageState();
}

class _MemeHomePageState extends State<MemeHomePage> {
  List<Meme> memes = [];
  bool isLoading = true;
  bool isError = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMemes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meme App"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                memes.clear();
                currentPage = 1;
              });
              fetchMemes();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.amber,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : isError
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Failed to load memes",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchMemes,
                        child: const Text("Try Again"),
                      ),
                    ],
                  ),
                )
                : memes.isEmpty
                ? const Center(child: Text("No memes found"))
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: memes.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == memes.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final meme = memes[index];
                    return MemeCard(
                      title: meme.title ?? '',
                      imageUrl: meme.url ?? '',
                      ups: meme.ups ?? 0,
                      postLink: meme.postLink ?? '',
                    );
                  },
                ),
      ),
    );
  }
}

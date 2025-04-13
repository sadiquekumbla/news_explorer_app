import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_list.dart';
import '../widgets/search_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NewsProvider>().refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const CustomSearchBar(),
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                if (newsProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (newsProvider.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${newsProvider.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => newsProvider.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (newsProvider.articles.isEmpty) {
                  return const Center(
                    child: Text('No news articles found.'),
                  );
                }

                return NewsList(articles: newsProvider.articles);
              },
            ),
          ),
        ],
      ),
    );
  }
} 
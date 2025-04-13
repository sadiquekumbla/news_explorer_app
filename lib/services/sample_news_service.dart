import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/article.dart';

class SampleNewsService {
  final Map<String, List<Article>> _sampleNews = {
    'technology': [
      Article(
        title: 'Flutter 3.0 Released with Major Improvements',
        link: 'https://flutter.dev/blog/2023/05/10/flutter-3.0',
        pubDate: DateTime.now().subtract(const Duration(hours: 2)),
        summary: 'Flutter 3.0 brings significant performance improvements, new widgets, and better platform support.',
        source: 'Flutter Team',
      ),
      Article(
        title: 'Google Announces New AI Features for Android',
        link: 'https://blog.google/products/android/ai-features',
        pubDate: DateTime.now().subtract(const Duration(hours: 5)),
        summary: 'Google introduces new AI-powered features for Android devices, enhancing user experience.',
        source: 'Google Blog',
      ),
    ],
    'business': [
      Article(
        title: 'Tech Stocks Rally as Market Shows Recovery',
        link: 'https://example.com/tech-stocks-rally',
        pubDate: DateTime.now().subtract(const Duration(hours: 3)),
        summary: 'Major tech companies see significant stock price increases as market confidence grows.',
        source: 'Financial Times',
      ),
      Article(
        title: 'Startup Funding Reaches New Heights in Q2',
        link: 'https://example.com/startup-funding',
        pubDate: DateTime.now().subtract(const Duration(hours: 6)),
        summary: 'Venture capital investments in tech startups hit record levels in the second quarter.',
        source: 'TechCrunch',
      ),
    ],
    'science': [
      Article(
        title: 'New Study Reveals Breakthrough in Quantum Computing',
        link: 'https://example.com/quantum-computing',
        pubDate: DateTime.now().subtract(const Duration(hours: 4)),
        summary: 'Scientists achieve major milestone in quantum computing stability.',
        source: 'Nature',
      ),
      Article(
        title: 'NASA Plans New Mars Mission for 2025',
        link: 'https://example.com/nasa-mars',
        pubDate: DateTime.now().subtract(const Duration(hours: 7)),
        summary: 'NASA announces details of its next Mars exploration mission.',
        source: 'NASA',
      ),
    ],
  };

  List<Article> getNewsForCategory(String category) {
    return _sampleNews[category.toLowerCase()] ?? [];
  }

  List<String> getAvailableCategories() {
    return _sampleNews.keys.toList();
  }

  Future<List<Article>> getSampleNews() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/news.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      print('Error loading sample news: $e');
      return [];
    }
  }
} 
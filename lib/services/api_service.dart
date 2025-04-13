import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/article.dart';

class ApiService {
  static const String _baseUrl = 'assets/news.json';

  Future<List<Article>> getNews() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(_baseUrl);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Parse the articles from the JSON data
      final List<dynamic> articlesJson = jsonData['articles'];
      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      print('Error loading news: $e');
      return [];
    }
  }

  Future<List<Article>> getNewsForCategory(String category) async {
    try {
      final articles = await getNews();
      return articles.where((article) => 
        article.source.toLowerCase().contains(category.toLowerCase()) ||
        article.title.toLowerCase().contains(category.toLowerCase())
      ).toList();
    } catch (e) {
      print('Error getting news for category: $e');
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    // For now, return a static list of categories
    return [
      'Technology',
      'Business',
      'Science',
      'Health',
      'Entertainment',
      'Sports'
    ];
  }
} 
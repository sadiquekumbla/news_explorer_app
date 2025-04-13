import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  static const String baseUrl = 'http://localhost:3001/api';

  Future<List<Article>> getNews(String category, {int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news?query=$category&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  Future<List<Article>> getSummarizedNews(String category, {int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/summarized-news?query=$category&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load summarized news');
      }
    } catch (e) {
      throw Exception('Error fetching summarized news: $e');
    }
  }
} 
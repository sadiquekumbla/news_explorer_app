import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/news_article.dart';
import '../models/category.dart' as app_models;
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final ApiService _apiService;
  final NewsService _newsService = NewsService();
  
  List<String> _categories = [];
  List<Article> _newsArticles = [];
  String _selectedCategory = 'technology';
  bool _isLoading = false;
  bool _isOffline = false;
  String? _error;
  DateTime? _lastRefreshTime;
  String? _searchQuery;
  
  // Cache duration in milliseconds (30 minutes)
  static const int _cacheDuration = 30 * 60 * 1000;
  
  NewsProvider(this._apiService) {
    _loadInitialData();
  }
  
  // Getters
  List<String> get categories => _categories;
  List<Article> get newsArticles => _newsArticles;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get error => _error;
  DateTime? get lastRefreshTime => _lastRefreshTime;
  
  // Initialize the provider
  Future<void> init() async {
    // Check connectivity
    _checkConnectivity();
    
    // Load categories
    await _loadCategories();
    
    // Load news for current category
    await _loadNewsForCategory(_selectedCategory);
  }
  
  // Check connectivity
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOffline = connectivityResult == ConnectivityResult.none;
    notifyListeners();
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      _isOffline = result == ConnectivityResult.none;
      notifyListeners();
      
      // If we're back online, refresh the data
      if (!_isOffline) {
        _loadNewsForCategory(_selectedCategory);
      }
    });
  }
  
  // Load categories
  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString('categories');
      
      if (categoriesJson != null) {
        final data = json.decode(categoriesJson) as List;
        _categories = data.map((json) => json as String).toList();
      } else {
        _categories = [
          'technology',
          'business',
          'entertainment',
          'health',
          'science',
          'sports',
        ];
        await prefs.setString('categories', json.encode(_categories));
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load categories: $e';
      notifyListeners();
    }
  }
  
  // Load news for a category
  Future<void> _loadNewsForCategory(String category) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Try to load from cache first if not forcing refresh
      if (!isOffline) {
        final prefs = await SharedPreferences.getInstance();
        final cachedNews = prefs.getString('news_$category');
        final cachedTimestamp = prefs.getInt('news_${category}_timestamp');
        
        if (cachedNews != null && cachedTimestamp != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - cachedTimestamp < _cacheDuration) {
            final List<dynamic> data = json.decode(cachedNews);
            _newsArticles = data.map((json) => Article.fromJson(json)).toList();
            _selectedCategory = category;
            _isLoading = false;
            notifyListeners();
            return;
          }
        }
      }
      
      // If cache is expired or doesn't exist, fetch from API
      _newsArticles = await _apiService.getNews(category);
      _selectedCategory = category;
      
      // Cache the news
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('news_$category', json.encode(_newsArticles.map((a) => a.toJson()).toList()));
      await prefs.setInt('news_${category}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _error = 'Failed to load news: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Select a category
  Future<void> selectCategory(String category) async {
    if (category != _selectedCategory) {
      await _loadNewsForCategory(category);
    }
  }
  
  // Search news
  Future<void> searchNews(String query) async {
    _searchQuery = query;
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${const String.fromEnvironment('API_URL')}/api/news?query=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _newsArticles = data.map((json) => Article.fromJson(json)).toList();
      } else {
        _error = 'Failed to search news';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
  
  // Refresh current category
  Future<void> refresh() async {
    await _loadNewsForCategory(_selectedCategory);
  }

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${const String.fromEnvironment('API_URL')}/api/news?category=$_selectedCategory'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _newsArticles = data.map((json) => Article.fromJson(json)).toList();
      } else {
        _error = 'Failed to load news';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshNews() async {
    if (_searchQuery != null) {
      await searchNews(_searchQuery!);
    } else {
      await fetchNews();
    }
  }

  Future<void> _loadInitialData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _categories = await _apiService.getCategories();
      await _loadNewsForCategory(_selectedCategory);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 
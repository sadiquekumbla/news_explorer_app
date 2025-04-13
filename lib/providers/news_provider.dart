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

class NewsProvider with ChangeNotifier {
  final ApiService _apiService;
  final NewsService _newsService = NewsService();
  
  List<app_models.Category> _categories = [];
  List<NewsArticle> _newsArticles = [];
  String _currentCategory = 'technology';
  bool _isLoading = false;
  bool _isOffline = false;
  String? _error;
  DateTime? _lastRefreshTime;
  String? _searchQuery;
  
  // Cache duration in milliseconds (30 minutes)
  static const int _cacheDuration = 30 * 60 * 1000;
  
  NewsProvider(this._apiService) {
    _initialize();
  }
  
  // Getters
  List<app_models.Category> get categories => _categories;
  List<NewsArticle> get newsArticles => _newsArticles;
  String get currentCategory => _currentCategory;
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
    await _loadNewsForCategory(_currentCategory);
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
        _loadNewsForCategory(_currentCategory);
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
        _categories = data.map((json) => app_models.Category.fromJson(json)).toList();
      } else {
        _categories = [
          app_models.Category(id: 'technology', name: 'Technology', icon: '💻'),
          app_models.Category(id: 'business', name: 'Business', icon: '💼'),
          app_models.Category(id: 'entertainment', name: 'Entertainment', icon: '🎬'),
          app_models.Category(id: 'health', name: 'Health', icon: '🏥'),
          app_models.Category(id: 'science', name: 'Science', icon: '🔬'),
          app_models.Category(id: 'sports', name: 'Sports', icon: '⚽'),
        ];
        await prefs.setString('categories', json.encode(_categories.map((c) => c.toJson()).toList()));
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load categories: $e';
      notifyListeners();
    }
  }
  
  // Load news for a category
  Future<void> _loadNewsForCategory(String category, {bool forceRefresh = false}) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Try to load from cache first if not forcing refresh
      if (!forceRefresh) {
        final prefs = await SharedPreferences.getInstance();
        final cachedNews = prefs.getString('news_$category');
        final cachedTimestamp = prefs.getInt('news_${category}_timestamp');
        
        if (cachedNews != null && cachedTimestamp != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - cachedTimestamp < _cacheDuration) {
            final List<dynamic> data = json.decode(cachedNews);
            _newsArticles = data.map((json) => NewsArticle.fromJson(json)).toList();
            _currentCategory = category;
            _isLoading = false;
            notifyListeners();
            return;
          }
        }
      }
      
      // If cache is expired or doesn't exist, fetch from API
      _newsArticles = await _apiService.getNewsByCategory(category);
      _currentCategory = category;
      
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
    if (_currentCategory == category) return;
    await _loadNewsForCategory(category);
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
        _newsArticles = data.map((json) => NewsArticle.fromJson(json)).toList();
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
  Future<void> refreshCurrentCategory() async {
    await _loadNewsForCategory(_currentCategory, forceRefresh: true);
  }

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${const String.fromEnvironment('API_URL')}/api/news?category=$_currentCategory'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _newsArticles = data.map((json) => NewsArticle.fromJson(json)).toList();
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

  Future<void> _initialize() async {
    await _loadCategories();
    await _loadNewsForCategory(_currentCategory);
  }
} 
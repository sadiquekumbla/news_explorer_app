import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';
import '../services/sample_news_service.dart';

class NewsProvider with ChangeNotifier {
  final ApiService _apiService;
  final SampleNewsService _sampleNewsService;
  
  List<Article> _articles = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String _error = '';
  DateTime? _lastRefreshTime;
  String? _searchQuery;
  String _currentCategory = 'technology';
  
  // Cache duration in milliseconds (30 minutes)
  static const int _cacheDuration = 30 * 60 * 1000;
  
  NewsProvider(this._apiService, this._sampleNewsService) {
    _loadInitialNews();
  }
  
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String get error => _error;
  DateTime? get lastRefreshTime => _lastRefreshTime;
  String get currentCategory => _currentCategory;
  
  Future<void> _loadInitialNews() async {
    await fetchNewsForCategory(_currentCategory);
  }
  
  Future<void> fetchNewsForCategory(String category) async {
    _isLoading = true;
    _error = '';
    _currentCategory = category;
    notifyListeners();

    try {
      // First try to get news from API
      _articles = await _apiService.getNewsForCategory(category);
    } catch (e) {
      // If API fails, fall back to sample news
      _articles = _sampleNewsService.getNewsForCategory(category);
      _error = 'Using offline data. Please check your internet connection.';
    }

    _isLoading = false;
    notifyListeners();
  }
  
  List<String> getAvailableCategories() {
    return _sampleNewsService.getAvailableCategories();
  }
  
  // Initialize the provider
  Future<void> init() async {
    // Check connectivity
    _checkConnectivity();
    
    // Load news
    await _loadNews();
  }
  
  // Load news
  Future<void> _loadNews() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Try to load from cache first
      final cachedNews = await _loadFromCache();
      if (cachedNews != null) {
        _articles = cachedNews;
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // If no cache or cache expired, fetch from API
      _articles = await _apiService.getNews();
      
      // Save to cache
      await _saveToCache(_articles);
      
      _lastRefreshTime = DateTime.now();
    } catch (e) {
      _error = e.toString();
      // Load sample news when offline
      _articles = await _sampleNewsService.getSampleNews();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Refresh news
  Future<void> refresh() async {
    _lastRefreshTime = null; // Clear last refresh time to force a new fetch
    await _loadNews();
  }
  
  // Check connectivity
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOffline = connectivityResult == ConnectivityResult.none;
    notifyListeners();
  }
  
  // Load from cache
  Future<List<Article>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('news_cache');
      final cachedTime = prefs.getInt('news_cache_time');
      
      if (cachedData != null && cachedTime != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTime;
        
        if (cacheAge < _cacheDuration) {
          final List<dynamic> decodedData = json.decode(cachedData);
          return decodedData.map((item) => Article.fromJson(item)).toList();
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Save to cache
  Future<void> _saveToCache(List<Article> articles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedData = json.encode(articles.map((e) => e.toJson()).toList());
      
      await prefs.setString('news_cache', encodedData);
      await prefs.setInt('news_cache_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Ignore cache errors
    }
  }
  
  // Search news
  Future<void> search(String query) async {
    _searchQuery = query;
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      if (query.isEmpty) {
        await _loadNews();
        return;
      }
      
      // Filter news articles based on search query
      final filteredArticles = _articles.where((article) {
        return article.title.toLowerCase().contains(query.toLowerCase()) ||
               article.summary.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      _articles = filteredArticles;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNews({int limit = 20}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _articles = await _apiService.getNews();
    } catch (e) {
      _error = e.toString();
      // Load sample news when offline
      _articles = await _sampleNewsService.getSampleNews();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }
} 
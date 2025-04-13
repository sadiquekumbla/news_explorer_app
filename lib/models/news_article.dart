class NewsArticle {
  final String title;
  final String summary;
  final String link;
  final DateTime pubDate;
  final String source;

  NewsArticle({
    required this.title,
    required this.summary,
    required this.link,
    required this.pubDate,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      link: json['link'] ?? '',
      pubDate: DateTime.tryParse(json['pubDate'] ?? '') ?? DateTime.now(),
      source: json['source'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'link': link,
      'pubDate': pubDate.toIso8601String(),
      'source': source,
    };
  }
} 
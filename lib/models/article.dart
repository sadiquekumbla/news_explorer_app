class Article {
  final String title;
  final String link;
  final DateTime pubDate;
  final String summary;
  final String source;

  Article({
    required this.title,
    required this.link,
    required this.pubDate,
    required this.summary,
    required this.source,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      pubDate: DateTime.parse(json['pubDate'] ?? DateTime.now().toIso8601String()),
      summary: json['summary'] ?? '',
      source: json['source'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'pubDate': pubDate.toIso8601String(),
      'summary': summary,
      'source': source,
    };
  }
} 
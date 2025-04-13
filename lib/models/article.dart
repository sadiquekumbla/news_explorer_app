class Article {
  final String title;
  final String link;
  final String pubDate;
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
      pubDate: json['pubDate'] ?? '',
      summary: json['summary'] ?? '',
      source: json['source'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'pubDate': pubDate,
      'summary': summary,
      'source': source,
    };
  }
} 
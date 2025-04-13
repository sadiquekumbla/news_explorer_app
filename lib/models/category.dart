class Category {
  final String id;
  final String name;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  static List<Category> getCategories() {
    return [
      Category(id: '1', name: 'Technology', icon: '💻'),
      Category(id: '2', name: 'Business', icon: '💼'),
      Category(id: '3', name: 'Sports', icon: '⚽'),
      Category(id: '4', name: 'Entertainment', icon: '🎬'),
      Category(id: '5', name: 'Health', icon: '🏥'),
      Category(id: '6', name: 'Science', icon: '🔬'),
      Category(id: '7', name: 'Politics', icon: '🏛️'),
      Category(id: '8', name: 'World', icon: '🌍'),
    ];
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
} 
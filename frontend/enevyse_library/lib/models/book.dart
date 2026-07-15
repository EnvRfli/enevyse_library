class Book {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final DateTime? published;
  final double ratings;
  final String? coverUrl;
  final List<String> categories;
  final List<String> genres;
  final String language;
  final int totalCopies;
  final int availableCopies;
  final int totalPages;
  final String synopsis;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    this.published,
    required this.ratings,
    this.coverUrl,
    required this.categories,
    required this.genres,
    required this.language,
    required this.totalCopies,
    required this.availableCopies,
    required this.totalPages,
    required this.synopsis,
    this.createdAt,
    this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown',
      author: json['author'] ?? 'Unknown',
      publisher: json['publisher'] ?? '',
      published: json['published'] != null ? DateTime.tryParse(json['published']) : null,
      ratings: (json['ratings'] ?? 0).toDouble(),
      coverUrl: json['cover_url'],
      categories: List<String>.from(json['categories'] ?? []),
      genres: List<String>.from(json['genres'] ?? []),
      language: json['language'] ?? '',
      totalCopies: json['total_copies'] ?? 0,
      availableCopies: json['available_copies'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      synopsis: json['synopsis'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'published': published?.toIso8601String(),
      'ratings': ratings,
      'cover_url': coverUrl,
      'categories': categories,
      'genres': genres,
      'language': language,
      'total_copies': totalCopies,
      'available_copies': availableCopies,
      'total_pages': totalPages,
      'synopsis': synopsis,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

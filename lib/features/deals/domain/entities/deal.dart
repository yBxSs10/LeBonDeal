class Deal {
  final String id;
  final String title;
  final String description;
  final double price;
  final double originalPrice;
  final int discountPercent;
  final String imageUrl;
  final String storeName;
  final String author;
  final int publishedHoursAgo;
  final String? badge;
  final int comments;
  final int favorites;
  final int shares;
  final String categoryId;
  final bool isTrending;
  final bool isPopular;

  const Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.discountPercent,
    required this.imageUrl,
    required this.storeName,
    required this.author,
    required this.publishedHoursAgo,
    this.badge,
    required this.comments,
    required this.favorites,
    required this.shares,
    required this.categoryId,
    this.isTrending = false,
    this.isPopular = false,
  });

  // Getters pour le formatage
  String get priceLabel => '\$${price.toStringAsFixed(2)}';
  String get originalPriceLabel => '\$${originalPrice.toStringAsFixed(2)}';

  // Creates a copy of the Deal with the given fields replaced by the non-null values
  Deal copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    int? discountPercent,
    String? imageUrl,
    String? storeName,
    String? author,
    int? publishedHoursAgo,
    String? badge,
    int? comments,
    int? favorites,
    int? shares,
    String? categoryId,
    bool? isTrending,
    bool? isPopular,
  }) {
    return Deal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      imageUrl: imageUrl ?? this.imageUrl,
      storeName: storeName ?? this.storeName,
      author: author ?? this.author,
      publishedHoursAgo: publishedHoursAgo ?? this.publishedHoursAgo,
      badge: badge ?? this.badge,
      comments: comments ?? this.comments,
      favorites: favorites ?? this.favorites,
      shares: shares ?? this.shares,
      categoryId: categoryId ?? this.categoryId,
      isTrending: isTrending ?? this.isTrending,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}

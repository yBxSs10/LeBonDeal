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
  final String authorId; // UID Firebase — requis par les Security Rules
  final int publishedHoursAgo;
  final String? badge;
  final int comments;
  final int favorites;
  final int shares;
  final String categoryId;
  final bool isTrending;
  final bool isPopular;
  final int temperature;

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
    required this.authorId,
    required this.publishedHoursAgo,
    this.badge,
    required this.comments,
    required this.favorites,
    required this.shares,
    required this.categoryId,
    this.isTrending = false,
    this.isPopular = false,
    this.temperature = 50,
  });

  // Getters pour le formatage
  String get priceLabel => '${price.toStringAsFixed(2)} €';
  String get originalPriceLabel => '${originalPrice.toStringAsFixed(2)} €';

  /// Ancienneté formatée en unité adaptée (minutes → heures → jours → semaines → mois).
  String get timeAgoLabel {
    if (publishedHoursAgo < 1) return "à l'instant";
    if (publishedHoursAgo < 24) return 'il y a ${publishedHoursAgo}h';
    final days = publishedHoursAgo ~/ 24;
    if (days < 7) return 'il y a ${days}j';
    final weeks = days ~/ 7;
    if (weeks < 4) return 'il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    final months = days ~/ 30;
    return 'il y a $months mois';
  }

  /// L'étiquette "NEW" est temporaire (< 24h) ; les autres badges
  /// (HOT, ou personnalisés fixés par un modérateur) restent affichés.
  bool get shouldShowBadge {
    if (badge == null || badge!.isEmpty) return false;
    if (badge == 'NEW') return publishedHoursAgo < 24;
    return true;
  }

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
    String? authorId,
    int? publishedHoursAgo,
    String? badge,
    int? comments,
    int? favorites,
    int? shares,
    String? categoryId,
    bool? isTrending,
    bool? isPopular,
    int? temperature,
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
      authorId: authorId ?? this.authorId,
      publishedHoursAgo: publishedHoursAgo ?? this.publishedHoursAgo,
      badge: badge ?? this.badge,
      comments: comments ?? this.comments,
      favorites: favorites ?? this.favorites,
      shares: shares ?? this.shares,
      categoryId: categoryId ?? this.categoryId,
      isTrending: isTrending ?? this.isTrending,
      isPopular: isPopular ?? this.isPopular,
      temperature: temperature ?? this.temperature,
    );
  }
}

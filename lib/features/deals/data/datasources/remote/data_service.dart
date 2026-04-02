import 'package:flutter/material.dart';
import '../../../domain/entities/deal.dart';
import '../../../../categories/domain/entities/category.dart';
import '../../../../comments/data/models/comment.dart';

class DataService {
  static final List<Deal> _deals = [
    Deal(
      id: '1',
      title: 'MacBook Pro M3 -30%',
      description: 'Ordinateur portable professionnel avec puce M3, 16GB RAM, 512GB SSD',
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600',
      storeName: 'Apple Store',
      price: 1399.99,
      originalPrice: 1999.99,
      discountPercent: 30,
      author: 'John Doe',
      publishedHoursAgo: 2,
      badge: 'HOT',
      comments: 45,
      favorites: 128,
      shares: 23,
      categoryId: 'high-tech',
      isTrending: true,
      isPopular: true,
    ),
    Deal(
      id: '2',
      title: 'Nike Air Max -50%',
      description: 'Chaussures de sport confortables et stylées, technologie Air',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
      storeName: 'Nike',
      price: 49.99,
      originalPrice: 99.99,
      discountPercent: 50,
      author: 'Jane Smith',
      publishedHoursAgo: 5,
      badge: 'NEW',
      comments: 32,
      favorites: 89,
      shares: 15,
      categoryId: 'mode',
      isTrending: true,
    ),
    Deal(
      id: '3',
      title: 'Smart TV 4K 55"',
      description: 'Télévision intelligente 4K avec HDR, apps Netflix et Prime Video',
      imageUrl: 'https://images.unsplash.com/photo-1593359677879-2d4865123e14?w=600',
      storeName: 'Samsung',
      price: 399.99,
      originalPrice: 699.99,
      discountPercent: 43,
      author: 'Mike Johnson',
      publishedHoursAgo: 8,
      badge: 'LIMITED',
      comments: 67,
      favorites: 156,
      shares: 34,
      categoryId: 'high-tech',
      isPopular: true,
    ),
    Deal(
      id: '4',
      title: 'Canapé convertible -40%',
      description: 'Canapé lit avec rangement intégré, couleur gris anthracite',
      imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600',
      storeName: 'IKEA',
      price: 299.99,
      originalPrice: 499.99,
      discountPercent: 40,
      author: 'Sarah Wilson',
      publishedHoursAgo: 12,
      badge: 'SALE',
      comments: 23,
      favorites: 67,
      shares: 12,
      categoryId: 'maison',
    ),
    Deal(
      id: '5',
      title: 'PlayStation 5 Console',
      description: 'Console de jeux vidéo dernière génération avec manette DualSense',
      imageUrl: 'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=600',
      storeName: 'Sony',
      price: 449.99,
      originalPrice: 549.99,
      discountPercent: 18,
      author: 'Tom Brown',
      publishedHoursAgo: 15,
      badge: 'POPULAR',
      comments: 89,
      favorites: 234,
      shares: 45,
      categoryId: 'high-tech',
      isTrending: true,
      isPopular: true,
    ),
  ];

  static final List<Comment> _comments = [
    Comment(
      id: 'c1',
      dealId: '1',
      author: 'Alice',
      content: 'Super affaire, j\'ai commandé hier et tout s\'est bien passé.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Comment(
      id: 'c2',
      dealId: '1',
      author: 'Marc',
      content: 'Attention, livraison un peu lente mais produit conforme.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Comment(
      id: 'c3',
      dealId: '2',
      author: 'Sophie',
      content: 'Merci pour le partage, parfait pour un cadeau !',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    Comment(
      id: 'c4',
      dealId: '5',
      author: 'Nabil',
      content: 'Rupture de stock actuellement, espérons un réassort.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  // Deals
  static List<Deal> getAllDeals() => _deals;
  static List<Deal> getDealsByCategory(String categoryId) => 
      _deals.where((deal) => deal.categoryId == categoryId).toList();
  static List<Deal> getTrendingDeals() => 
      _deals.where((deal) => deal.isTrending).toList();
  static List<Deal> getPopularDeals() => 
      _deals.where((deal) => deal.isPopular).toList();
  static List<Deal> searchDeals(String query) => _deals.where((deal) {
    final q = query.toLowerCase();
    return deal.title.toLowerCase().contains(q) ||
        deal.description.toLowerCase().contains(q) ||
        deal.storeName.toLowerCase().contains(q);
  }).toList();
  static List<Deal> getSavedDeals(List<String> savedDealIds) => 
      _deals.where((deal) => savedDealIds.contains(deal.id)).toList();

  // Categories
  static List<Category> getAllCategories() {
    // In a real app, this would come from an API or database
    // For now, we'll use the hardcoded list from the model
    final modelCategories = [
      Category(
        id: 'high-tech',
        name: 'High-Tech',
        icon: Icons.computer,
        color: Colors.blue,
      ),
      Category(
        id: 'informatique',
        name: 'Informatique',
        icon: Icons.laptop,
        color: Colors.green,
      ),
      Category(
        id: 'mode',
        name: 'Mode',
        icon: Icons.style,
        color: Colors.pink,
      ),
      Category(
        id: 'maison',
        name: 'Maison',
        icon: Icons.home,
        color: Colors.orange,
      ),
      Category(
        id: 'sports',
        name: 'Sports',
        icon: Icons.sports,
        color: Colors.red,
      ),
      Category(
        id: 'voyages',
        name: 'Voyages',
        icon: Icons.flight,
        color: Colors.purple,
      ),
      Category(
        id: 'restauration',
        name: 'Restauration',
        icon: Icons.restaurant,
        color: Colors.brown,
      ),
      Category(
        id: 'beaute',
        name: 'Beauté',
        icon: Icons.spa,
        color: Colors.pinkAccent,
      ),
    ];
    
    return modelCategories;
  }
  
  static Category? getCategoryById(String id) {
    try {
      return getAllCategories().firstWhere((cat) => cat.id == id);
    } catch (_) {
      return null;
    }
  }

  // Add new deal
  static void addDeal(Deal deal) {
    _deals.insert(0, deal); // Add at the beginning to show newest first
  }

  // Comments
  static List<Comment> getCommentsByDealId(String dealId) {
    final comments = _comments.where((comment) => comment.dealId == dealId).toList();
    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return comments;
  }

  static Comment addComment(Comment comment) {
    _comments.insert(0, comment);

    final index = _deals.indexWhere((deal) => deal.id == comment.dealId);
    if (index != -1) {
      _deals[index] = _deals[index].copyWith(
        comments: _deals[index].comments + 1,
      );
    }

    return comment;
  }
}

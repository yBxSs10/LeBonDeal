import 'package:flutter/material.dart';
import 'package:lebondeal/features/deals/domain/domain.dart';
import 'package:lebondeal/features/categories/domain/domain.dart';

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
      authorId: 'uid_seed_001',
      publishedHoursAgo: 2,
      badge: 'HOT',
      comments: 45,
      favorites: 128,
      shares: 23,
      categoryId: '2', // High-Tech
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
      authorId: 'uid_seed_002',
      publishedHoursAgo: 5,
      badge: 'NEW',
      comments: 32,
      favorites: 89,
      shares: 15,
      categoryId: '3', // Mode
      isTrending: true,
      isPopular: false,
    ),
    Deal(
      id: '3',
      title: 'Smart TV 4K 55"',
      description: 'Télévision intelligente 4K avec HDR, apps Netflix et Prime Video',
      imageUrl: 'https://images.unsplash.com/photo-1593359677879-2d4865123e14?w=600',
      storeName: 'Samsung',
      price: 399.99,
      originalPrice: 599.99,
      discountPercent: 33,
      author: 'Mike Johnson',
      authorId: 'uid_seed_003',
      publishedHoursAgo: 8,
      badge: 'SOLDES',
      comments: 28,
      favorites: 75,
      shares: 12,
      categoryId: '2', // High-Tech
      isTrending: false,
      isPopular: true,
    ),
    Deal(
      id: '4',
      title: 'Canapé d\'angle en cuir',
      description: 'Canapé d\'angle en cuir véritable, couleur marron, 5 places',
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600',
      storeName: 'Maisons du Monde',
      price: 899.99,
      originalPrice: 1299.99,
      discountPercent: 31,
      author: 'Sarah Williams',
      authorId: 'uid_seed_004',
      publishedHoursAgo: 12,
      badge: 'PROMO',
      comments: 18,
      favorites: 42,
      shares: 8,
      categoryId: '4', // Maison
      isTrending: true,
      isPopular: false,
    ),
    Deal(
      id: '5',
      title: 'Kit maquillage professionnel',
      description: 'Kit complet de maquillage professionnel avec pinceaux inclus',
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600',
      storeName: 'Sephora',
      price: 79.99,
      originalPrice: 149.99,
      discountPercent: 47,
      author: 'Emma Davis',
      authorId: 'uid_seed_005',
      publishedHoursAgo: 3,
      badge: 'TOP',
      comments: 36,
      favorites: 94,
      shares: 21,
      categoryId: '5', // Beauté
      isTrending: true,
      isPopular: true,
    ),
  ];

  // Méthode pour récupérer les deals tendance
  static List<Deal> getTrendingDeals() {
    return _deals.where((deal) => deal.isTrending).toList();
  }

  // Méthode pour récupérer les deals populaires
  static List<Deal> getPopularDeals() {
    return _deals.where((deal) => deal.isPopular).toList();
  }

  // Méthode pour récupérer toutes les catégories
  static List<Category> getAllCategories() {
    return [
      const Category(id: '1', name: 'Tous', icon: Icons.all_inclusive, color: Colors.blue),
      const Category(id: '2', name: 'High-Tech', icon: Icons.computer, color: Colors.green),
      const Category(id: '3', name: 'Mode', icon: Icons.shopping_bag, color: Colors.purple),
      const Category(id: '4', name: 'Maison', icon: Icons.home, color: Colors.orange),
      const Category(id: '5', name: 'Beauté', icon: Icons.face_retouching_natural, color: Colors.pink),
    ];
  }

  // Méthode pour récupérer les deals par catégorie
  static List<Deal> getDealsByCategory(String categoryId) {
    if (categoryId == '1') return _deals; // Tous les deals
    return _deals.where((deal) => deal.categoryId == categoryId).toList();
  }

  // Méthode pour rechercher des deals
  static List<Deal> searchDeals(String query) {
    if (query.isEmpty) return _deals;
    return _deals
        .where((deal) =>
            deal.title.toLowerCase().contains(query.toLowerCase()) ||
            deal.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Méthode pour ajouter un nouveau deal
  static void addDeal(Deal newDeal) {
    _deals.add(newDeal);
  }
}

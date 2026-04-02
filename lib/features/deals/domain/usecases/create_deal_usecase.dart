import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../entities/deal.dart';
import '../../data/datasources/remote/data_service.dart';

class CreateDealUseCase {
  Future<void> execute({
    required String title,
    required String description,
    required String storeName,
    required double price,
    double? originalPrice,
    required String categoryId,
    String? imageUrl,
  }) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      throw Exception('Utilisateur non connecté');
    }

    final discountPercent = originalPrice != null && originalPrice > 0
        ? ((originalPrice - price) / originalPrice * 100).round()
        : 0;

    final deal = Deal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      imageUrl: imageUrl?.trim().isEmpty ?? true
          ? 'https://via.placeholder.com/300x200'
          : imageUrl!.trim(),
      storeName: storeName.trim(),
      price: price,
      originalPrice: originalPrice ?? price,
      discountPercent: discountPercent,
      author: user.displayName ?? 'Utilisateur actuel',
      publishedHoursAgo: 0,
      badge: discountPercent > 50 ? 'HOT' : 'NEW',
      comments: 0,
      favorites: 0,
      shares: 0,
      categoryId: categoryId,
    );

    DataService.addDeal(deal);
  }
}

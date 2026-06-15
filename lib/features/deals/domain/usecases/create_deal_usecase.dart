import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/deals/domain/entities/deal.dart';

class CreateDealUseCase {
  final FirestoreService _firestoreService;

  CreateDealUseCase(this._firestoreService);

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

    final effectiveOriginalPrice = originalPrice ?? price;
    final discountPercent = effectiveOriginalPrice > price
        ? ((effectiveOriginalPrice - price) / effectiveOriginalPrice * 100)
              .round()
        : 0;

    final deal = Deal(
      id: '',
      title: title.trim(),
      description: description.trim(),
      imageUrl: imageUrl?.trim().isNotEmpty == true
          ? imageUrl!.trim()
          : 'https://via.placeholder.com/300x200',
      storeName: storeName.trim(),
      price: price,
      originalPrice: effectiveOriginalPrice,
      discountPercent: discountPercent,
      author: user.displayName ?? 'Utilisateur',
      authorId: user.uid,
      publishedHoursAgo: 0,
      badge: discountPercent > 50 ? 'HOT' : 'NEW',
      comments: 0,
      favorites: 0,
      shares: 0,
      categoryId: categoryId,
    );

    await _firestoreService.addDeal(deal);
  }
}

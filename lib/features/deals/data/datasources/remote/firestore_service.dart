import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/deal.dart';
import '../../../../categories/domain/entities/category.dart';
import '../../../../comments/data/models/comment.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _deals = _db.collection('deals');
  static final _comments = _db.collection('comments');

  // ─── Deals ──────────────────────────────────────────────────────────────────

  static Stream<List<Deal>> getAllDealsStream() {
    return _deals
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_dealFromDoc).toList());
  }

  static Stream<List<Deal>> getDealsByCategoryStream(String categoryId) {
    return _deals
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_dealFromDoc).toList());
  }

  static Stream<List<Deal>> getTrendingDealsStream() {
    return _deals
        .where('isTrending', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_dealFromDoc).toList());
  }

  static Future<DocumentReference> addDeal(Deal deal) {
    return _deals.add({
      'title': deal.title,
      'description': deal.description,
      'price': deal.price,
      'originalPrice': deal.originalPrice,
      'discountPercent': deal.discountPercent,
      'imageUrl': deal.imageUrl,
      'storeName': deal.storeName,
      'author': deal.author,
      'authorId': deal.authorId,
      'badge': deal.badge,
      'comments': 0,
      'favorites': 0,
      'shares': 0,
      'categoryId': deal.categoryId,
      'isTrending': deal.isTrending,
      'isPopular': deal.isPopular,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Comments ───────────────────────────────────────────────────────────────

  static Stream<List<Comment>> getCommentsStream(String dealId) {
    return _comments
        .where('dealId', isEqualTo: dealId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_commentFromDoc).toList());
  }

  static Future<void> addComment(Comment comment, String authorId) async {
    final batch = _db.batch();
    final commentRef = _comments.doc();
    batch.set(commentRef, {
      'dealId': comment.dealId,
      'author': comment.author,
      'authorId': authorId,
      'content': comment.content,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(_deals.doc(comment.dealId), {
      'comments': FieldValue.increment(1),
    });
    await batch.commit();
  }

  // ─── Favoris ────────────────────────────────────────────────────────────────

  static Stream<Set<String>> getSavedDealIdsStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return <String>{};
      final data = doc.data()!;
      return Set<String>.from(data['savedDealIds'] ?? []);
    });
  }

  static Future<void> toggleSavedDeal(
    String userId,
    String dealId,
    bool currentlySaved,
  ) async {
    final userRef = _db.collection('users').doc(userId);
    if (currentlySaved) {
      await userRef.set({
        'savedDealIds': FieldValue.arrayRemove([dealId]),
      }, SetOptions(merge: true));
    } else {
      await userRef.set({
        'savedDealIds': FieldValue.arrayUnion([dealId]),
      }, SetOptions(merge: true));
    }
  }

  static Stream<List<Deal>> getSavedDealsStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().asyncMap((
      userDoc,
    ) async {
      if (!userDoc.exists) return <Deal>[];
      final ids = List<String>.from(userDoc.data()?['savedDealIds'] ?? []);
      if (ids.isEmpty) return <Deal>[];
      final snap = await _deals.where(FieldPath.documentId, whereIn: ids).get();
      return snap.docs.map(_dealFromDoc).toList();
    });
  }

  // ─── Catégories (statiques — pas besoin de Firestore) ───────────────────────

  static List<Category> getAllCategories() => [
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
    Category(id: 'mode', name: 'Mode', icon: Icons.style, color: Colors.pink),
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

  // ─── Helpers privés ──────────────────────────────────────────────────────────

  static Deal _dealFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final createdAt =
        (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final hoursAgo = DateTime.now().difference(createdAt).inHours;
    return Deal(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      price: (d['price'] as num).toDouble(),
      originalPrice: (d['originalPrice'] as num).toDouble(),
      discountPercent: d['discountPercent'] ?? 0,
      imageUrl: d['imageUrl'] ?? '',
      storeName: d['storeName'] ?? '',
      author: d['author'] ?? '',
      authorId: d['authorId'] ?? '',
      publishedHoursAgo: hoursAgo,
      badge: d['badge'] as String?,
      comments: d['comments'] ?? 0,
      favorites: d['favorites'] ?? 0,
      shares: d['shares'] ?? 0,
      categoryId: d['categoryId'] ?? '',
      isTrending: d['isTrending'] ?? false,
      isPopular: d['isPopular'] ?? false,
    );
  }

  static Comment _commentFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      dealId: d['dealId'] ?? '',
      author: d['author'] ?? '',
      content: d['content'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

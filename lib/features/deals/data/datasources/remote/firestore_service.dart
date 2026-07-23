import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:lebondeal/features/deals/domain/entities/deal.dart';
import 'package:lebondeal/features/categories/domain/entities/category.dart';
import 'package:lebondeal/features/comments/data/models/comment.dart';
import 'package:lebondeal/features/reports/data/models/report.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  // ─── Deals ──────────────────────────────────────────────────────────────────

  Stream<List<Deal>> getAllDealsStream() {
    return _db
        .collection('deals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_dealFromDoc).toList());
  }

  Stream<Deal?> getDealStream(String dealId) {
    return _db
        .collection('deals')
        .doc(dealId)
        .snapshots()
        .map((doc) => doc.exists ? _dealFromDoc(doc) : null);
  }

  Stream<List<Deal>> getDealsByCategoryStream(String categoryId) {
    return _db
        .collection('deals')
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_dealFromDoc).toList());
  }

  Stream<List<Deal>> getTrendingDealsStream() {
    return _db
        .collection('deals')
        .where('isTrending', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_dealFromDoc).toList());
  }

  Future<DocumentReference> addDeal(Deal deal) async {
    final dealRef = _db.collection('deals').doc();
    // Écrit dans le même batch que users/{uid}.lastDealPublishedAt, lu par
    // la règle Firestore recentlyPublishedDeal() pour l'anti-spam (30s).
    final userRef = _db.collection('users').doc(deal.authorId);

    final batch = _db.batch();
    batch.set(dealRef, {
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
      'temperature': 50,
      'categoryId': deal.categoryId,
      'isTrending': deal.isTrending,
      'isPopular': deal.isPopular,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(userRef, {
      'lastDealPublishedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
    return dealRef;
  }

  /// Supprime un deal — réservé à l'auteur ou un modérateur (firestore.rules).
  Future<void> deleteDeal(String dealId) {
    return _db.collection('deals').doc(dealId).delete();
  }

  // ─── Votes (température) ─────────────────────────────────────────────────────

  /// Retourne le vote actuel de l'utilisateur pour un deal : 1, -1, ou 0.
  Stream<int> getUserVoteStream(String userId, String dealId) {
    return _db
        .collection('deals')
        .doc(dealId)
        .collection('votes')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? (doc.data()?['value'] as int? ?? 0) : 0);
  }

  /// Vote sur un deal. Gère le toggle (revoter annule) et le changement de sens.
  /// - [vote] doit être 1 (upvote) ou -1 (downvote).
  Future<void> voteOnDeal(String userId, String dealId, int vote) async {
    assert(vote == 1 || vote == -1);
    final dealRef = _db.collection('deals').doc(dealId);
    final voteRef = dealRef.collection('votes').doc(userId);

    await _db.runTransaction((tx) async {
      final voteDoc = await tx.get(voteRef);
      final previousVote = voteDoc.exists
          ? (voteDoc.data()?['value'] as int? ?? 0)
          : 0;

      if (previousVote == vote) {
        // Même vote → annulation
        tx.delete(voteRef);
        tx.update(dealRef, {'temperature': FieldValue.increment(-vote)});
      } else {
        // Nouveau vote ou changement de sens
        tx.set(voteRef, {'value': vote});
        final delta = previousVote == 0 ? vote : vote * 2;
        tx.update(dealRef, {'temperature': FieldValue.increment(delta)});
      }
    });
  }

  // ─── Comments ───────────────────────────────────────────────────────────────

  Stream<List<Comment>> getCommentsStream(String dealId) {
    return _db
        .collection('comments')
        .where('dealId', isEqualTo: dealId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_commentFromDoc).toList());
  }

  Future<void> addComment(Comment comment, String authorId) async {
    final batch = _db.batch();
    final commentRef = _db.collection('comments').doc();
    batch.set(commentRef, {
      'dealId': comment.dealId,
      'author': comment.author,
      'authorId': authorId,
      'content': comment.content,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('deals').doc(comment.dealId), {
      'comments': FieldValue.increment(1),
    });
    await batch.commit();
  }

  // ─── Favoris ────────────────────────────────────────────────────────────────

  Stream<Set<String>> getSavedDealIdsStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return <String>{};
      final data = doc.data()!;
      return Set<String>.from(data['savedDealIds'] ?? []);
    });
  }

  Future<void> toggleSavedDeal(
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

  Stream<List<Deal>> getSavedDealsStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().asyncMap((
      userDoc,
    ) async {
      if (!userDoc.exists) return <Deal>[];
      final ids = List<String>.from(userDoc.data()?['savedDealIds'] ?? []);
      if (ids.isEmpty) return <Deal>[];
      final snap = await _db
          .collection('deals')
          .where(FieldPath.documentId, whereIn: ids)
          .get();
      return snap.docs.map(_dealFromDoc).toList();
    });
  }

  // ─── Rôle utilisateur ───────────────────────────────────────────────────────

  /// Crée le profil Firestore d'un utilisateur à l'inscription — requis par
  /// firestore.rules (allow create exige email, displayName et role='user').
  /// Sans cet appel, aucune écriture ultérieure sur users/{uid} (favoris,
  /// catégories suivies) ne peut créer le document et échoue silencieusement.
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) {
    return _db.collection('users').doc(uid).set({
      'email': email,
      'displayName': displayName,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sert uniquement à décider l'affichage de l'entrée "Modération" côté UI —
  /// l'accès réel aux signalements reste imposé par firestore.rules (isModerator()).
  Stream<String?> getUserRoleStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data()?['role'] as String?;
    });
  }

  // ─── Notifications par catégorie ───────────────────────────────────────────

  Stream<Set<String>> getFollowedCategoryIdsStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return <String>{};
      final data = doc.data()!;
      return Set<String>.from(data['followedCategoryIds'] ?? []);
    });
  }

  Future<void> toggleFollowedCategory(
    String userId,
    String categoryId,
    bool currentlyFollowed,
  ) async {
    final userRef = _db.collection('users').doc(userId);
    if (currentlyFollowed) {
      await userRef.set({
        'followedCategoryIds': FieldValue.arrayRemove([categoryId]),
      }, SetOptions(merge: true));
    } else {
      await userRef.set({
        'followedCategoryIds': FieldValue.arrayUnion([categoryId]),
      }, SetOptions(merge: true));
    }
  }

  // ─── Catégories (statiques — pas besoin de Firestore) ───────────────────────

  List<Category> getAllCategories() => [
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

  // ─── Signalements (reports) ────────────────────────────────────────────────

  Future<void> createReport({
    required String targetId,
    required String targetType,
    required String targetTitle,
    required String reason,
    required String authorId,
  }) {
    return _db.collection('reports').add({
      'targetId': targetId,
      'targetType': targetType,
      'targetTitle': targetTitle,
      'reason': reason,
      'authorId': authorId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Tous les signalements, triés du plus récent au plus ancien — filtrage
  /// par statut fait côté client pour ne pas dépendre d'un index composite
  /// supplémentaire (status + createdAt) non requis par ailleurs.
  Stream<List<Report>> getReportsStream() {
    return _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_reportFromDoc).toList());
  }

  Future<void> resolveReport(String reportId) {
    return _db.collection('reports').doc(reportId).update({
      'status': 'resolved',
    });
  }

  // ─── Helpers privés ──────────────────────────────────────────────────────────

  Deal _dealFromDoc(DocumentSnapshot doc) {
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
      temperature: d['temperature'] ?? 50,
    );
  }

  Comment _commentFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      dealId: d['dealId'] ?? '',
      author: d['author'] ?? '',
      content: d['content'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Report _reportFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      targetId: d['targetId'] ?? '',
      targetType: d['targetType'] ?? '',
      targetTitle: d['targetTitle'] ?? '',
      reason: d['reason'] ?? '',
      authorId: d['authorId'] ?? '',
      status: d['status'] ?? 'pending',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/deals/domain/entities/deal.dart';

abstract class DealRepository {
  Stream<List<Deal>> getAllDealsStream();

  Stream<Deal?> getDealStream(String dealId);

  Stream<List<Deal>> getDealsByCategoryStream(String categoryId);

  Stream<List<Deal>> getTrendingDealsStream();

  /// Retourne le deal créé (avec son id Firestore généré) en cas de succès.
  Future<Either<String, Deal>> addDeal(Deal deal);

  Future<Either<String, Unit>> deleteDeal(String dealId);

  // ─── Votes (température) ─────────────────────────────────────────────────

  /// Retourne le vote actuel de l'utilisateur pour un deal : 1, -1, ou 0.
  Stream<int> getUserVoteStream(String userId, String dealId);

  Future<Either<String, Unit>> voteOnDeal(
    String userId,
    String dealId,
    int vote,
  );

  // ─── Favoris ────────────────────────────────────────────────────────────

  Stream<Set<String>> getSavedDealIdsStream(String userId);

  Future<Either<String, Unit>> toggleSavedDeal(
    String userId,
    String dealId,
    bool currentlySaved,
  );

  Stream<List<Deal>> getSavedDealsStream(String userId);
}

import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/deals/domain/entities/deal.dart';
import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class DealRepositoryImpl implements DealRepository {
  final FirestoreService _firestoreService;

  DealRepositoryImpl(this._firestoreService);

  @override
  Stream<List<Deal>> getAllDealsStream() =>
      _firestoreService.getAllDealsStream();

  @override
  Stream<Deal?> getDealStream(String dealId) =>
      _firestoreService.getDealStream(dealId);

  @override
  Stream<List<Deal>> getDealsByCategoryStream(String categoryId) =>
      _firestoreService.getDealsByCategoryStream(categoryId);

  @override
  Stream<List<Deal>> getTrendingDealsStream() =>
      _firestoreService.getTrendingDealsStream();

  @override
  Future<Either<String, Deal>> addDeal(Deal deal) async {
    try {
      final ref = await _firestoreService.addDeal(deal);
      return Right(deal.copyWith(id: ref.id));
    } catch (_) {
      return const Left('Erreur lors de la publication du deal');
    }
  }

  @override
  Future<Either<String, Unit>> deleteDeal(String dealId) async {
    try {
      await _firestoreService.deleteDeal(dealId);
      return const Right(unit);
    } catch (_) {
      return const Left('Erreur lors de la suppression du deal');
    }
  }

  @override
  Stream<int> getUserVoteStream(String userId, String dealId) =>
      _firestoreService.getUserVoteStream(userId, dealId);

  @override
  Future<Either<String, Unit>> voteOnDeal(
    String userId,
    String dealId,
    int vote,
  ) async {
    try {
      await _firestoreService.voteOnDeal(userId, dealId, vote);
      return const Right(unit);
    } catch (_) {
      return const Left('Erreur lors du vote');
    }
  }

  @override
  Stream<Set<String>> getSavedDealIdsStream(String userId) =>
      _firestoreService.getSavedDealIdsStream(userId);

  @override
  Future<Either<String, Unit>> toggleSavedDeal(
    String userId,
    String dealId,
    bool currentlySaved,
  ) async {
    try {
      await _firestoreService.toggleSavedDeal(userId, dealId, currentlySaved);
      return const Right(unit);
    } catch (_) {
      return const Left('Erreur lors de la mise à jour des favoris');
    }
  }

  @override
  Stream<List<Deal>> getSavedDealsStream(String userId) =>
      _firestoreService.getSavedDealsStream(userId);
}

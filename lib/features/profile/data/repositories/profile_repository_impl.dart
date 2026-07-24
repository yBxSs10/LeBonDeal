import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirestoreService _firestoreService;

  ProfileRepositoryImpl(this._firestoreService);

  @override
  Stream<String?> getUserRoleStream(String userId) =>
      _firestoreService.getUserRoleStream(userId);

  @override
  Stream<Set<String>> getFollowedCategoryIdsStream(String userId) =>
      _firestoreService.getFollowedCategoryIdsStream(userId);

  @override
  Future<Either<String, Unit>> toggleFollowedCategory(
    String userId,
    String categoryId,
    bool currentlyFollowed,
  ) async {
    try {
      await _firestoreService.toggleFollowedCategory(
        userId,
        categoryId,
        currentlyFollowed,
      );
      return const Right(unit);
    } catch (_) {
      return const Left('Erreur lors de la mise à jour des notifications');
    }
  }
}

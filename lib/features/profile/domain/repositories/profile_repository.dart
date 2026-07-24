import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  /// Sert uniquement à décider l'affichage de l'entrée "Modération" côté UI —
  /// l'accès réel aux signalements reste imposé par firestore.rules.
  Stream<String?> getUserRoleStream(String userId);

  Stream<Set<String>> getFollowedCategoryIdsStream(String userId);

  Future<Either<String, Unit>> toggleFollowedCategory(
    String userId,
    String categoryId,
    bool currentlyFollowed,
  );
}

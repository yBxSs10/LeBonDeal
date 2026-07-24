import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/profile/domain/repositories/profile_repository.dart';

class ToggleFollowedCategoryUseCase {
  final ProfileRepository repository;

  ToggleFollowedCategoryUseCase(this.repository);

  Future<Either<String, Unit>> call(
    String userId,
    String categoryId,
    bool currentlyFollowed,
  ) => repository.toggleFollowedCategory(userId, categoryId, currentlyFollowed);
}

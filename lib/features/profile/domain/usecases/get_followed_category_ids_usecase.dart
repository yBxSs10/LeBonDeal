import 'package:lebondeal/features/profile/domain/repositories/profile_repository.dart';

class GetFollowedCategoryIdsUseCase {
  final ProfileRepository repository;

  GetFollowedCategoryIdsUseCase(this.repository);

  Stream<Set<String>> call(String userId) =>
      repository.getFollowedCategoryIdsStream(userId);
}

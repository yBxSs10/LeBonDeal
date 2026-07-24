import 'package:lebondeal/features/profile/domain/repositories/profile_repository.dart';

class GetUserRoleUseCase {
  final ProfileRepository repository;

  GetUserRoleUseCase(this.repository);

  Stream<String?> call(String userId) => repository.getUserRoleStream(userId);
}

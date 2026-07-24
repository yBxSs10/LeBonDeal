import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class GetUserVoteUseCase {
  final DealRepository repository;

  GetUserVoteUseCase(this.repository);

  Stream<int> call(String userId, String dealId) =>
      repository.getUserVoteStream(userId, dealId);
}

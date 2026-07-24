import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class VoteOnDealUseCase {
  final DealRepository repository;

  VoteOnDealUseCase(this.repository);

  Future<Either<String, Unit>> call(String userId, String dealId, int vote) =>
      repository.voteOnDeal(userId, dealId, vote);
}

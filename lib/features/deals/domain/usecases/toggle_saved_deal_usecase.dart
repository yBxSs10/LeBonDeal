import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class ToggleSavedDealUseCase {
  final DealRepository repository;

  ToggleSavedDealUseCase(this.repository);

  Future<Either<String, Unit>> call(
    String userId,
    String dealId,
    bool currentlySaved,
  ) => repository.toggleSavedDeal(userId, dealId, currentlySaved);
}

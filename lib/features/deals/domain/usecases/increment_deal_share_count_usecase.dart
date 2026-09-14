import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class IncrementDealShareCountUseCase {
  final DealRepository repository;

  IncrementDealShareCountUseCase(this.repository);

  Future<Either<String, Unit>> call(String dealId) =>
      repository.incrementShareCount(dealId);
}

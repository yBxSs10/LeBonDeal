import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class DeleteDealUseCase {
  final DealRepository repository;

  DeleteDealUseCase(this.repository);

  Future<Either<String, Unit>> call(String dealId) =>
      repository.deleteDeal(dealId);
}

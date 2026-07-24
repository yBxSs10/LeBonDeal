import 'package:lebondeal/features/deals/domain/entities/deal.dart';
import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class GetDealUseCase {
  final DealRepository repository;

  GetDealUseCase(this.repository);

  Stream<Deal?> call(String dealId) => repository.getDealStream(dealId);
}

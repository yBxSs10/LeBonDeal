import 'package:lebondeal/features/deals/domain/entities/deal.dart';
import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class GetDealsByCategoryUseCase {
  final DealRepository repository;

  GetDealsByCategoryUseCase(this.repository);

  Stream<List<Deal>> call(String categoryId) =>
      repository.getDealsByCategoryStream(categoryId);
}

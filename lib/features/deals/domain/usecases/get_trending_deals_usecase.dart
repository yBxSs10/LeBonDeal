import 'package:lebondeal/features/deals/domain/entities/deal.dart';
import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class GetTrendingDealsUseCase {
  final DealRepository repository;

  GetTrendingDealsUseCase(this.repository);

  Stream<List<Deal>> call() => repository.getTrendingDealsStream();
}

import 'package:lebondeal/features/deals/domain/entities/deal.dart';
import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class GetSavedDealsUseCase {
  final DealRepository repository;

  GetSavedDealsUseCase(this.repository);

  Stream<List<Deal>> call(String userId) =>
      repository.getSavedDealsStream(userId);
}

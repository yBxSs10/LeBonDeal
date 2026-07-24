import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class GetSavedDealIdsUseCase {
  final DealRepository repository;

  GetSavedDealIdsUseCase(this.repository);

  Stream<Set<String>> call(String userId) =>
      repository.getSavedDealIdsStream(userId);
}

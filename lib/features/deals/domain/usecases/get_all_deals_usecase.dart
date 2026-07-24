import 'package:lebondeal/features/deals/domain/entities/deal.dart';
import 'package:lebondeal/features/deals/domain/repositories/deal_repository.dart';

class GetAllDealsUseCase {
  final DealRepository repository;

  GetAllDealsUseCase(this.repository);

  Stream<List<Deal>> call() => repository.getAllDealsStream();
}

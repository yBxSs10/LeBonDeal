import 'package:lebondeal/features/reports/domain/entities/report_entity.dart';
import 'package:lebondeal/features/reports/domain/repositories/report_repository.dart';

class GetReportsUseCase {
  final ReportRepository repository;

  GetReportsUseCase(this.repository);

  Stream<List<ReportEntity>> call() => repository.getReportsStream();
}

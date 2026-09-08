import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/reports/domain/repositories/report_repository.dart';

class ResolveReportUseCase {
  final ReportRepository repository;

  ResolveReportUseCase(this.repository);

  Future<Either<String, Unit>> call(
    String reportId,
    String resolvedBy, {
    String action = 'dismissed',
  }) => repository.resolveReport(reportId, resolvedBy, action: action);
}

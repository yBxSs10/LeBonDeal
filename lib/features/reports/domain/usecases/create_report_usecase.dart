import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/reports/domain/repositories/report_repository.dart';

class CreateReportUseCase {
  final ReportRepository repository;

  CreateReportUseCase(this.repository);

  Future<Either<String, Unit>> call({
    required String targetId,
    required String targetType,
    required String targetTitle,
    required String reason,
    required String authorId,
  }) => repository.createReport(
    targetId: targetId,
    targetType: targetType,
    targetTitle: targetTitle,
    reason: reason,
    authorId: authorId,
  );
}

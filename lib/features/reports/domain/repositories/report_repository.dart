import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/reports/domain/entities/report_entity.dart';

abstract class ReportRepository {
  Future<Either<String, Unit>> createReport({
    required String targetId,
    required String targetType,
    required String targetTitle,
    required String reason,
    required String authorId,
  });

  Stream<List<ReportEntity>> getReportsStream();

  Future<Either<String, Unit>> resolveReport(String reportId);
}

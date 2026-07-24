import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/reports/data/models/report.dart' as model;
import 'package:lebondeal/features/reports/domain/entities/report_entity.dart';
import 'package:lebondeal/features/reports/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final FirestoreService _firestoreService;

  ReportRepositoryImpl(this._firestoreService);

  @override
  Future<Either<String, Unit>> createReport({
    required String targetId,
    required String targetType,
    required String targetTitle,
    required String reason,
    required String authorId,
  }) async {
    try {
      await _firestoreService.createReport(
        targetId: targetId,
        targetType: targetType,
        targetTitle: targetTitle,
        reason: reason,
        authorId: authorId,
      );
      return const Right(unit);
    } catch (_) {
      return const Left('Erreur lors de l\'envoi du signalement');
    }
  }

  @override
  Stream<List<ReportEntity>> getReportsStream() {
    return _firestoreService.getReportsStream().map(
      (reports) => reports.map(_toEntity).toList(),
    );
  }

  @override
  Future<Either<String, Unit>> resolveReport(String reportId) async {
    try {
      await _firestoreService.resolveReport(reportId);
      return const Right(unit);
    } catch (_) {
      return const Left('Erreur lors du traitement du signalement');
    }
  }

  ReportEntity _toEntity(model.Report report) => ReportEntity(
    id: report.id,
    targetId: report.targetId,
    targetType: report.targetType,
    targetTitle: report.targetTitle,
    reason: report.reason,
    authorId: report.authorId,
    status: report.status,
    createdAt: report.createdAt,
  );
}

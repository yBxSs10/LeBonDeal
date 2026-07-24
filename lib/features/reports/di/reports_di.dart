import 'package:get_it/get_it.dart';

import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/reports/data/repositories/report_repository_impl.dart';
import 'package:lebondeal/features/reports/domain/repositories/report_repository.dart';

/// Configure les dépendances liées aux signalements
void configureReportsDependencies() {
  final getIt = GetIt.instance;

  if (!getIt.isRegistered<ReportRepository>()) {
    getIt.registerLazySingleton<ReportRepository>(
      () => ReportRepositoryImpl(getIt<FirestoreService>()),
    );
  }
}

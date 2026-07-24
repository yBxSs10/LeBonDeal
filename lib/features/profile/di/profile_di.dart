import 'package:get_it/get_it.dart';

import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';
import 'package:lebondeal/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:lebondeal/features/profile/domain/repositories/profile_repository.dart';

/// Configure les dépendances liées au profil utilisateur
void configureProfileDependencies() {
  final getIt = GetIt.instance;

  if (!getIt.isRegistered<ProfileRepository>()) {
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt<FirestoreService>()),
    );
  }
}

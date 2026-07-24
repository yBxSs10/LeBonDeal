import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/remote/firestore_service.dart';
import '../data/repositories/deal_repository_impl.dart';
import '../domain/repositories/deal_repository.dart';

/// Configure les dépendances liées aux deals (Firestore)
void configureDealsDependencies() {
  final getIt = GetIt.instance;

  debugPrint('[DI] configureDealsDependencies() START');

  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
    debugPrint('[DI] FirebaseFirestore registered');
  } else {
    debugPrint('[DI] FirebaseFirestore already registered');
  }

  if (!getIt.isRegistered<FirestoreService>()) {
    getIt.registerLazySingleton<FirestoreService>(
      () => FirestoreService(db: getIt<FirebaseFirestore>()),
    );
    debugPrint('[DI] FirestoreService registered');
  } else {
    debugPrint('[DI] FirestoreService already registered');
  }

  if (!getIt.isRegistered<DealRepository>()) {
    getIt.registerLazySingleton<DealRepository>(
      () => DealRepositoryImpl(getIt<FirestoreService>()),
    );
    debugPrint('[DI] DealRepository registered');
  } else {
    debugPrint('[DI] DealRepository already registered');
  }

  debugPrint('[DI] configureDealsDependencies() END');
}

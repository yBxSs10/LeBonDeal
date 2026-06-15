// Fichier de configuration pour l'injection des dépendances d'authentification

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:lebondeal/features/auth/domain/repositories/auth_repository.dart';
import 'package:lebondeal/features/auth/data/repositories/auth_repository_impl.dart';

/// Configure les dépendances liées à l'authentification
void configureAuthDependencies() {
  final getIt = GetIt.instance;

  // Enregistrer FirebaseAuth s'il n'est pas déjà enregistré
  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  // Enregistrer le repository d'authentification
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(firebaseAuth: getIt<FirebaseAuth>()),
    );
  }
}

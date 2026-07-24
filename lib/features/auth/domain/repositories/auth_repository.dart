import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  // Vérifier l'état d'authentification actuel
  Stream<UserEntity?> get authStateChanges;

  // Récupérer l'utilisateur actuel
  UserEntity? get currentUser;

  // Se connecter avec email et mot de passe
  Future<Either<String, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Créer un compte avec email et mot de passe
  Future<Either<String, UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  // Se connecter (ou s'inscrire) avec un compte Google
  Future<Either<String, UserEntity>> signInWithGoogle();

  // Se connecter en tant qu'invité (compte anonyme Firebase)
  Future<Either<String, UserEntity>> signInAnonymously();

  // Se déconnecter
  Future<Either<String, Unit>> signOut();

  // Envoyer un email de réinitialisation de mot de passe
  Future<Either<String, Unit>> sendPasswordResetEmail(String email);

  // Mettre à jour le profil utilisateur
  Future<Either<String, Unit>> updateProfile({
    String? displayName,
    String? photoUrl,
  });
}

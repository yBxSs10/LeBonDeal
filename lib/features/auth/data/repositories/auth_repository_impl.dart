import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:lebondeal/features/auth/domain/entities/user_entity.dart';
import 'package:lebondeal/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({firebase_auth.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser?.toUserEntity();
    });
  }

  @override
  UserEntity? get currentUser {
    return _firebaseAuth.currentUser?.toUserEntity();
  }

  @override
  Future<Either<String, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userCredential.user!.toUserEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapAuthExceptionToMessage(e));
    } catch (e) {
      return const Left('Une erreur inattendue est survenue');
    }
  }

  @override
  Future<Either<String, UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();

      return Right((await _firebaseAuth.currentUser)!.toUserEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapAuthExceptionToMessage(e));
    } catch (e) {
      return const Left('Une erreur inattendue est survenue');
    }
  }

  @override
  Future<Either<String, Unit>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(unit);
    } catch (e) {
      return const Left('Erreur lors de la déconnexion');
    }
  }

  @override
  Future<Either<String, Unit>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(unit);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapAuthExceptionToMessage(e));
    } catch (e) {
      return const Left(
        'Erreur lors de l\'envoi de l\'email de réinitialisation',
      );
    }
  }

  @override
  Future<Either<String, Unit>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left('Aucun utilisateur connecté');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();
      return const Right(unit);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapAuthExceptionToMessage(e));
    } catch (e) {
      return const Left('Erreur lors de la mise à jour du profil');
    }
  }

  String _mapAuthExceptionToMessage(
    firebase_auth.FirebaseAuthException exception,
  ) {
    switch (exception.code) {
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée';
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cette adresse email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'too-many-requests':
        return 'Trop de tentatives de connexion. Veuillez réessayer plus tard.';
      default:
        return 'Une erreur est survenue: ${exception.message}';
    }
  }
}

extension on firebase_auth.User {
  UserEntity toUserEntity() {
    return UserEntity(
      id: uid,
      email: email ?? '',
      displayName: displayName,
      photoUrl: photoURL,
    );
  }
}

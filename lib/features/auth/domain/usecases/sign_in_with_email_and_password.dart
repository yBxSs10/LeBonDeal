import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/auth/domain/entities/user_entity.dart';
import 'package:lebondeal/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailAndPassword {
  final AuthRepository repository;

  SignInWithEmailAndPassword(this.repository);

  Future<Either<String, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

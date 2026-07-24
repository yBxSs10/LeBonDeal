import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/auth/domain/entities/user_entity.dart';
import 'package:lebondeal/features/auth/domain/repositories/auth_repository.dart';

class SignUpWithEmailAndPassword {
  final AuthRepository repository;

  SignUpWithEmailAndPassword(this.repository);

  Future<Either<String, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await repository.createUserWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

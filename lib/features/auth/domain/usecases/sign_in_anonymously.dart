import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/auth/domain/entities/user_entity.dart';
import 'package:lebondeal/features/auth/domain/repositories/auth_repository.dart';

class SignInAnonymously {
  final AuthRepository repository;

  SignInAnonymously(this.repository);

  Future<Either<String, UserEntity>> call() async {
    return await repository.signInAnonymously();
  }
}

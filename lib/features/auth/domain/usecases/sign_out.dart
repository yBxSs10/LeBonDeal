import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<Either<String, Unit>> call() async {
    return await repository.signOut();
  }
}

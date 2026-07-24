import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordResetEmail {
  final AuthRepository repository;

  SendPasswordResetEmail(this.repository);

  Future<Either<String, Unit>> call(String email) async {
    return await repository.sendPasswordResetEmail(email);
  }
}

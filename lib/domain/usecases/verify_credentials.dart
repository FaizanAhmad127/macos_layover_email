import '../entities/credentials.dart';
import '../repositories/email_repository.dart';

class VerifyCredentials {
  const VerifyCredentials(this._repository);

  final EmailRepository _repository;

  Future<void> call(Credentials credentials) =>
      _repository.verifyCredentials(credentials);
}

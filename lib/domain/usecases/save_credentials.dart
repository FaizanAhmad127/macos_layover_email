import '../entities/credentials.dart';
import '../repositories/credential_repository.dart';

class SaveCredentials {
  const SaveCredentials(this._repository);

  final CredentialRepository _repository;

  Future<void> call(Credentials credentials) =>
      _repository.saveCredentials(credentials);
}

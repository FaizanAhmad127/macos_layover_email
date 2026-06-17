import '../entities/credentials.dart';
import '../repositories/credential_repository.dart';

class LoadCredentials {
  const LoadCredentials(this._repository);

  final CredentialRepository _repository;

  Future<Credentials?> call() => _repository.loadCredentials();
}

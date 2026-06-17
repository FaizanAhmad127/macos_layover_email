import '../repositories/credential_repository.dart';

class ClearCredentials {
  const ClearCredentials(this._repository);

  final CredentialRepository _repository;

  Future<void> call() => _repository.clearCredentials();
}

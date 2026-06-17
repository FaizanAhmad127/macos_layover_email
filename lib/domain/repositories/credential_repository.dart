import '../entities/credentials.dart';

abstract class CredentialRepository {
  Future<Credentials?> loadCredentials();
  Future<void> saveCredentials(Credentials credentials);
  Future<void> clearCredentials();
}

import '../../core/errors/failures.dart';
import '../../domain/entities/credentials.dart';
import '../../domain/repositories/credential_repository.dart';
import '../datasources/credential_data_source.dart';
import '../models/credentials_model.dart';

class CredentialRepositoryImpl implements CredentialRepository {
  const CredentialRepositoryImpl(this._dataSource);

  final CredentialDataSource _dataSource;

  @override
  Future<Credentials?> loadCredentials() async {
    try {
      final map = await _dataSource.loadCredentials();
      return map != null ? CredentialsModel.fromMap(map) : null;
    } catch (e) {
      throw StorageFailure(e.toString());
    }
  }

  @override
  Future<void> saveCredentials(Credentials credentials) async {
    try {
      await _dataSource.saveCredentials(credentials.email, credentials.password);
    } catch (e) {
      throw StorageFailure(e.toString());
    }
  }

  @override
  Future<void> clearCredentials() async {
    try {
      await _dataSource.clearCredentials();
    } catch (e) {
      throw StorageFailure(e.toString());
    }
  }
}

import '../../domain/entities/credentials.dart';
import '../../domain/entities/email.dart';
import '../../domain/repositories/email_repository.dart';
import '../datasources/imap_data_source.dart';

class EmailRepositoryImpl implements EmailRepository {
  const EmailRepositoryImpl(this._dataSource);

  final ImapDataSource _dataSource;

  @override
  Stream<Email> watchNewEmails(Credentials credentials) =>
      _dataSource.watchNewEmails(credentials.email, credentials.password);

  @override
  Future<void> stopWatching() => _dataSource.stopWatching();

  @override
  Future<void> verifyCredentials(Credentials credentials) =>
      _dataSource.verifyCredentials(credentials.email, credentials.password);
}

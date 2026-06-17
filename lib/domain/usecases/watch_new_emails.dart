import '../entities/credentials.dart';
import '../entities/email.dart';
import '../repositories/email_repository.dart';

class WatchNewEmails {
  const WatchNewEmails(this._repository);

  final EmailRepository _repository;

  Stream<Email> call(Credentials credentials) =>
      _repository.watchNewEmails(credentials);
}

import '../entities/credentials.dart';
import '../entities/email.dart';

abstract class EmailRepository {
  Stream<Email> watchNewEmails(Credentials credentials);
  Future<void> stopWatching();
}
